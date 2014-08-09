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

Simply include this ``bundler.py`` file (from the Alfred Bundler's
``bundler/bundlets`` directory) alongside your workflow's Python code
where it can be imported.

The Python Bundler provides two main features: the ability to use common
utility programs (e.g. `cocaoDialog <http://mstratman.github.io/cocoadialog/>`_
or `Pashua <http://www.bluem.net/en/mac/pashua/>`_) simply by asking for
them by name (they will automatically be installed if necessary), and the
ability to automatically install and update any Python libraries required
by your workflows.

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
or on `GitHub <https://github.com/shawnrice/alfred-bundler>`_.

Alfred Bundler Methods
======================

"""

from __future__ import print_function, unicode_literals

import os
import subprocess
import urllib2
import imp
import logging
import logging.handlers

VERSION = '0.2'

BUNDLER_VERSION = 'devel'

if os.getenv('AB_BRANCH'):
    BUNDLER_VERSION = os.getenv('AB_BRANCH')

# Used for notifications, paths
BUNDLER_ID = 'net.deanishe.alfred-bundler-python'

# Bundler paths
BUNDLER_DIR = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/'
    'alfred.bundler-{}'.format(BUNDLER_VERSION))
DATA_DIR = os.path.join(BUNDLER_DIR, 'data')
CACHE_DIR = os.path.expanduser(
    '~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'
    'alfred.bundler-{}'.format(BUNDLER_VERSION))

# Main Python library
BUNDLER_PY_LIB = os.path.join(BUNDLER_DIR, 'bundler', 'AlfredBundler.py')

# Root directory under which workflow-specific Python libraries are installed
PYTHON_LIB_DIR = os.path.join(DATA_DIR, 'assets', 'python')

# Where helper scripts and metadata are stored
HELPER_DIR = os.path.join(PYTHON_LIB_DIR, BUNDLER_ID)

# Where colour alternatives are cached
COLOUR_CACHE = os.path.join(DATA_DIR, 'color-cache')

# Where installer.sh can be downloaded from
BASH_BUNDLET_URL = (
    'https://raw.githubusercontent.com/shawnrice/alfred-bundler/'
    '{}/bundler/bundlets/alfred.bundler.sh'.format(
    BUNDLER_VERSION))

# Bundler log file
BUNDLER_LOGFILE = os.path.join(DATA_DIR, 'logs', 'python.log')

# HTTP timeout
HTTP_TIMEOUT = 5

# The actual bundler module will be imported into this variable
_bundler = None


#-----------------------------------------------------------------------
# Logging
#-----------------------------------------------------------------------

_logdir = os.path.dirname(BUNDLER_LOGFILE)
if not os.path.exists(_logdir):
    os.makedirs(_logdir, 0755)

_log = logging.getLogger('bundler')
_logfile = logging.handlers.RotatingFileHandler(BUNDLER_LOGFILE,
                                                maxBytes=1024*1024,
                                                backupCount=0)
_console = logging.StreamHandler()
_fmt = logging.Formatter('%(asctime)s %(filename)s:%(lineno)s '
                         '%(levelname)-8s %(message)s',
                         datefmt='%H:%M:%S')

_logfile.setFormatter(_fmt)
_console.setFormatter(_fmt)
_log.addHandler(_logfile)
_log.addHandler(_console)
_log.setLevel(logging.DEBUG)

_log.debug('Bundler version : {}'.format(BUNDLER_VERSION))


#-----------------------------------------------------------------------
# Installation/update functions
#-----------------------------------------------------------------------

class InstallationError(Exception):
    """Raised if installation of the bash helper script fails"""


def _download(url, filepath):
    """Download ``url`` to ``filepath``

    May raise IOError or urllib2.HTTPError

    :param url: URL to download
    :type url: ``unicode`` or ``str``
    :param filepath: Path to download URL to
    :type filepath: ``unicode`` or ``str``
    :returns: None

    """

    _log.debug('Opening URL `{}` ...'.format(url))

    response = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)

    _log.debug('[{}] {}'.format(response.getcode(), url))

    if response.getcode() != 200:
        raise IOError(2, 'Error retrieving URL. Server returned {}'.format(
                      response.getcode()), url)

    dirpath = os.path.dirname(filepath)

    if not os.path.exists(dirpath):
        os.makedirs(dirpath, 0755)

    with open(filepath, 'wb') as file:
        _log.info('Downloading `{}` ...'.format(url))
        file.write(response.read())

    _log.info('Saved `{}`'.format(filepath))


def _bootstrap():
    """Check if bundler bash bundlet is installed and install it if not.

    :returns: ``None``

    """

    global _bundler

    if _bundler is not None:  # Already bootstrapped
        return

    # Create local directories if they don't exist
    for dirpath in (HELPER_DIR, CACHE_DIR, COLOUR_CACHE):
        if not os.path.exists(dirpath):
            _log.debug('Creating directory `{}`'.format(dirpath))
            os.makedirs(dirpath)

    if not os.path.exists(BUNDLER_PY_LIB):  # Install bundler

        _log.info('Installing Alfred Dependency Bundler '
                  'version `{}` ...'.format(BUNDLER_VERSION))

        # Install bash bundlet from GitHub
        bundlet_path = os.path.join(CACHE_DIR,
                                    'bundlet-{}.sh'.format(os.getpid()))

        bash_code = 'source "{}"'.format(bundlet_path)

        try:
            _download(BASH_BUNDLET_URL, bundlet_path)

        except Exception as err:
            _log.exception(err)
            raise InstallationError(
                'Error downloading `{}` to `{}`: {}'.format(
                BASH_BUNDLET_URL, bundlet_path, err))

        _log.debug('Executing script : `{}`'.format(bash_code))

        try:
            proc = subprocess.Popen(['/bin/bash'], stdin=subprocess.PIPE)

            proc.communicate(bash_code)

            if proc.returncode:
                raise InstallationError(
                    'Install script failed (code : {})'.format(proc.returncode))
        finally:
            os.unlink(bundlet_path)

        if not os.path.exists(BUNDLER_PY_LIB):
            raise InstallationError(
                'Error bootstrapping bundler. Bundler installation failed.')

    # Import bundler
    _bundler = imp.load_source('AlfredBundler', BUNDLER_PY_LIB)
    _log.debug('AlfredBundler.py imported')
    _bundler.metadata.set_updated()


def icon(font, icon, color='000000', alter=False):
    """Get path to specified icon, downloading it first if necessary.

    ``font``, ``icon`` and ``color`` are normalised to lowercase. In
    addition, ``color`` is expanded to 6 characters if only 3 are passed.

    :param font: name of the font
    :type font: ``unicode`` or ``str``
    :param icon: name of the font character
    :type icon: ``unicode`` or ``str``
    :param color: CSS colour in format "xxxxxx" (no preceding #)
    :type color: ``unicode`` or ``str``
    :param alter: Automatically adjust icon colour to light/dark theme
        background
    :type alter: ``Boolean``
    :returns: path to icon file
    :rtype: ``unicode``

    See http://icons.deanishe.net to view available icons.

    """

    _bootstrap()
    return _bundler.icon(font, icon, color, alter)


def utility(name, version='latest', json_path=None):
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
    return _bundler.utility(name, version, json_path)


def asset(name, version='latest', json_path=None):
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
    return _bundler.init(requirements)


if __name__ == '__main__':
    for name, args in [
            ('Terminal-Notifier',
                ['-title', 'Test', '-message', 'Test']),
            ('cocoaDialog',
                ['msgbox', '--text', 'Test', '--timeout', '2'])]:
        path = utility(name)
        subprocess.call([path] + args)
        print('{} : {}'.format(name, path))
    for font, char, colour in [('fontawesome', 'adjust', 'fff')]:
        path = icon(font, char, colour)
        print('{}/{}/{}: {}'.format(font, char, colour, path))
        subprocess.call(['open', path])
