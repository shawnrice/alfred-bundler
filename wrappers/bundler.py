#!/usr/bin/env python
# encoding: utf-8


"""
#########################
Alfred Bundler for Python
#########################

Alfred Bundler is a framework to help workflow authors manage external
utilities and libraries required by their workflows without having to
include them with each and every workflow.

`Alfred Bundler Homepage/Documentation <http://shawnrice.github.io/alfred-bundler/>`_.

**NOTE**: By necessity, this Python implementation does not work in
exactly the same way as the reference PHP/bash implementations by
Shawn Rice.

The purpose of the Bundler is to enable workflow authors to easily
access utilites and libraries that are commonly used without having to
include a copy in every ``.alfredworkflow`` file or worry about installing
them themselves. This way, we can hopefully avoid having, say, 15 copies
of ``cocaoDialog`` clogging up users' Dropboxes, and also allow authors to
distribute workflows with sizeable requirements without their exceeding
GitHub's 10 MB limit for ``.alfredworkflow`` files or causing authors
excessive bandwidth costs.

Unfortunately, due to the nature of Python's import system, it isn't
possible to provide versioned libraries in the way that the PHP Bundler
does, so this version of the Bundler creates an individual library
directory for each workflow and adds it to ``sys.path`` with one simple call.

It is based on `Pip <http://pip.readthedocs.org/en/latest/index.html>`_,
the de facto Python library installer, and you must create a
``requirements.txt`` file in `the format required by pip <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_
in order to take advantage of automatic dependency installation.

Usage
======

The Python Bundler provides two main features: the ability to use common
utility programs (e.g. `cocaoDialog <http://mstratman.github.io/cocoadialog/>`_
or `Pashua <http://www.bluem.net/en/mac/pashua/>`_) simply by asking for
them by name (they will automatically be installed if necessary), and the
ability to automatically install and update any Python libraries required
by your workflows.

Simply include this ``bundler.py`` file (from the Alfred Bundler's ``wrappers``
directory) alongside your workflow's Python code where it can be imported.

Using utilities/assets
----------------------

The basic interface for utilities is::

    import bundler
    util_path = bundler.utility('utilityName')

which will return the path to the appropriate executable, installing
it first if necessary. You may optionally specify a version number
and/or your own JSON file that defines a non-standard utility.

Please see `the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_
for details of the JSON file format and how the Bundler works in general.

Handling Python dependencies
----------------------------

The Python Bundler can also take care of your workflow's dependencies for
you if you create a `requirements.txt <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_
file in your workflow root directory and put the following in your Python
source files before trying to import any of those dependencies::

    import bundler
    bundler.init()

:func:`~bundler.init()` will find your ``requirements.txt``  file (you may alternatively
specify the path explicitly—see :func:`~bundler.init()`)
and call Pip with it (installing Pip first if necessary). Then it will
add the directory it's installed the libraries in to ``sys.path``, so you
can immediately ``import`` those libraries::

    import bundler
    bundler.init()
    import requests  # specified in `requirements.txt`

The Bundler doesn't define any explicit exceptions, but may raise any number
of different ones (e.g. :class:`~exceptions.IOError` if a file doesn't
exist or if the computer or PyPi is offline).

By and large, these are not recoverable errors, but if you'd like to ensure
your workflow's users are notified, I recommend (shameless plug) building
your Python workflow with
`Alfred-Workflow <http://www.deanishe.net/alfred-workflow/>`_,
which can catch workflow errors and warn the user (amongst other cool stuff).

Any problems with the Bundler may be raised on
`Alfred's forum <http://www.alfredforum.com/topic/4255-alfred-dependency-downloader-framework/>`_
or on `GitHub <https://github.com/shawnrice/alfred-bundler>`_. **Note:**
This Python version currently only exists in `this fork <https://github.com/deanishe/alfred-bundler>`_, so it's
currently better to raise problems specific to the Python version there.

Alfred Bundler Methods
======================

"""

from __future__ import print_function, unicode_literals

import sys
import os
import plistlib
from urllib import urlretrieve
import subprocess
import json
import hashlib

# Used to bump Pip recipe
__version__ = '0.1'

# Bundler paths
BUNDLER_VERSION = 'aries'
DATA_DIR = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/'
    'alfred.bundler-{}'.format(BUNDLER_VERSION))
CACHE_DIR = os.path.expanduser(
    '~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'
    'alfred.bundler-{}'.format(BUNDLER_VERSION))
# Root directory under which workflow-specific Python libraries are installed
PYTHON_LIB_DIR = os.path.join(DATA_DIR, 'assets', 'python')
# Where helper scripts will be installed
HELPER_DIR = os.path.join(PYTHON_LIB_DIR, 'bundler-helpers')
# Where installer.sh can be downloaded from
HELPER_URL = ('https://raw.githubusercontent.com/shawnrice/alfred-bundler/'
              '{}/wrappers/alfred.bundler.misc.sh'.format(BUNDLER_VERSION))
# The bundler script we will call to get paths to utilities and
# install them if necessary. This is actually the bash wrapper, not
# the bundler.sh file in the repo
HELPER_PATH = os.path.join(HELPER_DIR, 'bundlerwrapper.sh')
# Path to locally cached version of Pip JSON recipe
PIP_JSON_PATH = os.path.join(HELPER_DIR, 'pip-{}.json'.format(__version__))
# JSON recipe for installing Pip
PIP_JSON_URL = ('https://raw.githubusercontent.com/deanishe/'
                'alfred-bundler/aries/meta/defaults/Pip.json')


def _find_file(filename, start_dir=None):
    """Find file named ``filename`` in the directory tree at ``start_dir``.

    Climb up directory tree until ``filename`` is found. Raises IOError
    if file is not found.

    If ``start_dir`` is ``None``, start at current working directory.

    :param filename: Name of the file to search for
    :type filename: ``unicode`` or ``str``
    :param start_dir: Path to starting directory. Default is current
        working directory
    :type start_dir: ``unicode`` or ``str``
    :returns: Path to file or ``None``
    :rtype: ``unicode`` or ``str``

    """

    curdir = start_dir or os.getcwd()
    filepath = None
    while True:
        path = os.path.join(curdir, filename)
        if os.path.exists(path):
            filepath = path
            break
        if curdir == '/':
            break
        curdir = os.path.dirname(curdir)

    if not filepath:
        raise IOError(2, 'No such file or directory', filename)
    return filepath


def _bundle_id():
    """Return bundle ID of current workflow

    :returns: Bundle ID or ``None``
    :rtype: ``unicode``

    """

    plist = plistlib.readPlist(_find_file('info.plist'))
    return plist.get('bundleid', None)


def _add_pip_path():
    """Install ``pip`` if necessary and add its directory to ``sys.path``

    :returns: ``None``

    """
    if not os.path.exists(PIP_JSON_PATH):
        urlretrieve(PIP_JSON_URL, PIP_JSON_PATH)

    assert os.path.exists(PIP_JSON_PATH), ('Error retrieving Pip recipe '
                                           'from GitHub.')

    pip_path = utility('Pip', json_path=PIP_JSON_PATH)

    sys.path.insert(0, pip_path)


def _bootstrap():
    """Check if bundler bash wrapper and ``pip`` are installed
    and install them if not.

    NOTE: This will not actually install the bundler. That will happen the
    first time :func:`~bundler.utility()`, `~bundler.init()` or
    :func:`~bundler._add_pip_path()` is called.

    :returns: ``None``

    """

    if os.path.exists(HELPER_PATH):  # Already installed
        return

    # Create local directory if necessary
    if not os.path.exists(HELPER_DIR):
        os.makedirs(HELPER_DIR)

    # Install installer.sh from GitHub
    urlretrieve(HELPER_URL, HELPER_PATH)

    assert os.path.exists(HELPER_PATH), ('Error bootstrapping bundler. '
                                         'Could not download helper script '
                                         'from GitHub.')


def utility(name, version='default', json_path=None):
    """Get path to specified utility or asset, installing it first if necessary.

    Use this method to access common command line utilities, such as
    `cocaoDialog <http://mstratman.github.io/cocoadialog/>`_ or
    `Terminal-Notifier <https://github.com/alloy/terminal-notifier>`_.

    This function will return the path to the appropriate executable
    (installing it first if necessary), which you can then utilise via
    :mod:`subprocess`.

    You can easily add your own utilities by means of JSON configuration
    files specified with the ``json_path`` argument. Please see
    `the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_
    for details of the JSON file format.

    :param name: Name of the utility/asset to install
    :type name: ``unicode`` or ``str``
    :param version: Desired version of the utility/asset.
    :type version: ``unicode`` or ``str``
    :param json_path: Path to bundler configuration file
    :type json_path: ``unicode`` or ``str``
    :returns: Path to utility
    :rtype: ``unicode``

    """

    _bootstrap()
    # Call bash wrapper with specified arguments
    json_path = json_path or ''
    cmd = ['/bin/bash', HELPER_PATH, name, version, 'utility', json_path]
    path = subprocess.check_output(cmd).strip().decode('utf-8')
    # bundler.sh is broken and returns an error message if something goes
    # wrong instead of exiting uncleanly, so check that path exists, else
    # treat it as an error message
    if not os.path.exists(path):  # Is probably an error message
        # Simulate error that would be raised if `bundler.sh`
        # behaved properly
        raise subprocess.CalledProcessError(-1, cmd, path)
    return path


def asset(name, version='default', json_path=None):
    """Synonym for :func:`~bundler.utility()`"""
    return utility(name, version, json_path)


def init(requirements=None):
    """Install dependencies from ``requirements.txt`` to your workflow's
    custom bundler directory and add this directory to ``sys.path``.

    Will search up the directory tree for ``requirements.txt`` if
    ``requirements`` argument is not specified.

    **Note:** Your workflow must have a bundle ID set in order to use
    this function. (You should set one anyway, especially if you intend
    to distribute your workflow.)

    Your ``requirements.txt`` file must be in the
    `format required by Pip <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_.

    :param requirements: Path to Pip requirements file
    :type requirements: ``unicode`` or ``str``
    :returns: ``None``

    """
    _bootstrap()
    bundle_id = _bundle_id()
    if not bundle_id:
        raise ValueError('You *must* set a bundle ID in your workflow '
                         'to use this library.')

    install_dir = os.path.join(PYTHON_LIB_DIR, bundle_id)
    if not os.path.exists(install_dir):
        os.makedirs(install_dir)

    requirements = requirements or _find_file('requirements.txt')
    req_metadata_path = os.path.join(install_dir, 'requirements.json')
    last_updated = 0
    last_hash = ''
    metadata_changed = False
    metadata = {}

    # Load cached metadata if it exists
    if os.path.exists(req_metadata_path):
        with open(req_metadata_path, 'rb') as file:
            metadata = json.load(file, encoding='utf-8')
        last_updated = metadata.get('updated', 0)
        last_hash = metadata.get('hash', '')

    # compare requirements.txt to saved metadata
    req_mtime = os.stat(requirements).st_mtime
    if req_mtime > last_updated:
        metadata['updated'] = req_mtime
        metadata_changed = True

        # compare MD5 hash
        m = hashlib.md5()
        with open(requirements, 'rb') as file:
            m.update(file.read())
        h = m.hexdigest()

        if h != last_hash:  # requirements.txt has changed
            metadata['hash'] = h
            _add_pip_path()
            import pip
            args = ['install',
                    '--upgrade',
                    '--requirement', requirements,
                    '--target', install_dir]
            pip.main(args)

    if metadata_changed:  # Save new metadata
        with open(req_metadata_path, 'wb') as file:
            json.dump(metadata, file, encoding='utf-8', indent=2)

    # Add workflow library directory to front of `sys.path`
    sys.path.insert(0, install_dir)
