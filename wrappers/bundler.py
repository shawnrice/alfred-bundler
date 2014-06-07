#!/usr/bin/env python
# encoding: utf-8


"""
Python implementation of the Alfred Bundler.

NOTE: The installation of Python libraries is currently unfinished due
to the bundler.sh script it depends on being broken.

"""

from __future__ import print_function, unicode_literals

import sys
import os
import plistlib
from urllib import urlretrieve
import subprocess

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
# Where helper scripts will be installed
HELPER_DIR = os.path.join(DATA_DIR, 'python-helpers')
# Where installer.sh can be downloaded from
HELPER_URL = ('https://raw.githubusercontent.com/shawnrice/alfred-bundler/'
              '{}/wrappers/alfred.bundler.misc.sh'.format(BUNDLER_VERSION))
# The bundler script we will call to get paths to utilities and
# install them if necessary. This is actually the bash wrapper, not
# the bundler.sh file in the repo
HELPER_PATH = os.path.join(HELPER_DIR, 'bundler.sh')
# Root directory under which workflow-specific Python libraries are installed
PYTHON_LIB_DIR = os.path.join(DATA_DIR, 'assets', 'python-libs')
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


def _load_pip():
    """Import ``pip``, installing it if necessary.

    :returns: ``None``

    """
    if not os.path.exists(PIP_JSON_PATH):
        urlretrieve(PIP_JSON_URL, PIP_JSON_PATH)

    assert os.path.exists(PIP_JSON_PATH), ('Error retrieving Pip recipe '
                                           'from GitHub.')

    # This isn't working. `bundler.sh` appears to drop custom JSON
    # paths on the floor and only work with things specified in
    # its own `meta/defaults`
    pip_path = utility('Pip', json_path=PIP_JSON_PATH)
    print('pip_path : {}'.format(pip_path))

    sys.path.insert(0, pip_path)
    import pip


def _bootstrap():
    """Check if bundler bash wrapper and ``pip`` are installed
    and install them if not.

    NOTE: This will not actuall install the bundler. That will happen the
    first time `~bundler.utility()`, `~bundler.init()` or
    `~bundler._load_pip()` is called.

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
    """Get path to specified utility or asset, installing it if necessary.

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
    path = subprocess.check_output(cmd).strip()
    # bundler.sh is broken and returns an error message if something goes
    # wrong instead of exiting uncleanly, so check that path exists, else
    # treat it as an error message
    if not os.path.exists(path):  # Is probably an error message
        # Simulate error that would be raised if `bundler.sh`
        # behaved properly
        raise subprocess.CalledProcessError(-1, cmd, path)
    return path


def asset(name, version='default', json_path=None):
    """Synonym for `~bundler.utility()`"""
    return utility(name, version, json_path)


def init(requirements=None):
    """Install dependencies from ``requirements.txt``.

    Will search directory tree for ``requirements.txt`` if ``requirements``
    is not specified.

    :param requirements: Path to ``requirements.txt``
    :type requirements: ``unicode`` or `str``
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

    # Call ``pip``
    _load_pip()
