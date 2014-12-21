#!/usr/bin/env python
# encoding: utf-8

from __future__ import unicode_literals
import os
import re
import imp
import sys
import shutil
import zipfile
import inspect
import urllib2
import logging
import logging.handlers
import plistlib
import subprocess


BUNDLER = 'AlfredBundler.py'
BUNDLER_DIRECTORY = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{}'
)
BUNDLER_LOGFILE = 'data/logs/bundler-{}.log'
CACHE_DIRECTORY = os.path.expanduser(
    '~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'
    'alfred.bundler-{}'
)

BUNDLER_SERVERS = [
    'https://github.com/shawnrice/alfred-bundler/archive/{}{suffix}',
    'https://bitbucket.org/shawnrice/alfred-bundler/get/{}{suffix}'
]

INFO_RESOURCE = (
    'https://github.com/shawnrice/alfred-bundler/wiki/'
    'What-is-the-Alfred-Bundler'
)

HTTP_TIMEOUT = 5
DEFAULT_MAJOR_VERSION = 'devel'


class InstallationError(Exception):

    """ Raised if bundler installation failed"""

    def __init__(self, code=1000, message=''):
        self.code = code
        self.message = message

    def __str__(self):
        return repr('{} (code : {})'.format(self.message, self.code))


def AlfredBundler():
    """ Return an instance of bootstrapped bundler"""

    return AlfredBundlerBootstrap().bundler


class AlfredBundlerBootstrap:

    """ AlfredBundler bootstrap class"""

    def __init__(self):
        """ Initialize the bundler's bootstrap client"""

        global BUNDLER_DIRECTORY, CACHE_DIRECTORY, BUNDLER_LOGFILE
        global BUNDLER_SERVERS

        self.log = logging.getLogger(self.__class__.__name__)
        self._cwd = os.path.dirname(os.path.abspath(
            inspect.getfile(inspect.currentframe())
        ))
        self.bundler = None

        # Validate that the workflow's info.plist is present and active
        self.workflow = self._lookback(
            'info.plist', end_path=os.path.split(self._cwd)[0]
        )
        if not self.workflow:
            raise EnvironmentError(
                'The Alfred Bundler cannot be used without an `info.plist` '
                'file present'
            )
            sys.exit(1)

        # Grab the bundler's major version for path manipulation
        self.major_version = os.getenv('AB_BRANCH')
        if not self.major_version:
            self.major_version = DEFAULT_MAJOR_VERSION

        # Apply the newly found major version to the neccessary paths
        for i in range(0, len(BUNDLER_SERVERS)):
            BUNDLER_SERVERS[i] = BUNDLER_SERVERS[i].format(
                self.major_version, suffix='{}'
            )
        BUNDLER_DIRECTORY = BUNDLER_DIRECTORY.format(self.major_version)
        CACHE_DIRECTORY = CACHE_DIRECTORY.format(self.major_version)
        BUNDLER_LOGFILE = os.path.join(
            BUNDLER_DIRECTORY, BUNDLER_LOGFILE.format(self.major_version)
        )
        # Ensure the creation of required directories
        for i in (
            BUNDLER_DIRECTORY, CACHE_DIRECTORY,
            os.path.dirname(BUNDLER_LOGFILE),
        ):
            if not os.path.exists(i):
                os.makedirs(i, 0775)

        # Setup logging to _logfile and _console
        _logfile = logging.handlers.RotatingFileHandler(
            BUNDLER_LOGFILE, maxBytes=(1024 * 1024), backupCount=1
        )
        _console = logging.StreamHandler()
        _logfile.setFormatter(
            logging.Formatter(
                '[%(asctime)s] [%(filename)s:%(lineno)s] '
                '[%(levelname)s] %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S'
            )
        )
        _console.setFormatter(
            logging.Formatter(
                '[%(asctime)s] [%(filename)s:%(lineno)s] '
                '[%(levelname)s] %(message)s',
                datefmt='%H:%M:%S'
            )
        )
        self.log.addHandler(_logfile)
        self.log.addHandler(_console)
        self.log.setLevel(logging.DEBUG)

        # Check if bundler isn't currently installed
        if not os.path.exists(
            os.path.join(BUNDLER_DIRECTORY, 'bundler', BUNDLER)
        ):
            # Get the name of the workflow for versions used in Alfredv2.4:277+
            if os.getenv('alfred_version'):
                self.workflow = os.getenv('alfred_workflow_name')
            else:
                # Get the name of the workflow for versions < Alfredv2.4:277
                self.workflow = plistlib.readPlist(self.workflow)['name']
            if not self._install_bundler():
                # If we couldn't handle some exception, raise it here
                raise InstallationError(1005, 'Unkown installation error')
                sys.exit(1)
        # Reference the bundler with imp
        if not self.bundler:
            self.bundler = imp.load_source(
                os.path.splitext(BUNDLER)[0],
                os.path.join(BUNDLER_DIRECTORY, 'bundler', BUNDLER)
            ).Main(self._cwd)
        # Call the wrapper to update itself, subprocess required for speed
        self._run_subprocess([
            '/bin/bash',
            os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'meta', 'update-wrapper.sh'
            )
        ])

    def _lookback(self, filename, start_path=None, end_path=None):
        """ Recursively walks directory path in reverse looking for a filename

        :param filename: Filename to discover
        :type filename: ``unicode`` or ``str``
        :param start_path: File path to start the reverse walk
        :type start_path: ``unicode`` or ``str``
        :param end_path: File path to end the reverse walk
        :type end_path: ``unicode`` or ``str``
        :returns: None if file is not found, otherwise full file path
        """

        if not (
            (isinstance(start_path, str) or isinstance(start_path, unicode))
                and os.path.exists(start_path)
        ):
            start_path = self._cwd
        if not (
            (isinstance(end_path, str) or isinstance(end_path, unicode))
                and os.path.exists(end_path)
        ):
            end_path = '/'

        # While our path's are not referencing the same space
        if start_path != end_path:
            for i in os.listdir(start_path):
                if filename.lower() == i.lower():
                    return os.path.join(start_path, i)
            # Recurse using a shrunken start path
            _start_path = os.path.split(start_path)[0]
            return self._lookback(
                filename, start_path=_start_path, end_path=end_path
            )
        else:
            return None

    def _run_subprocess(self, process):
        """ Run a unwaiting subprocess

        :param process: A split subprocess
        :type process: ``list`` or ``str``
        :returns: Subprocess output
        """

        if isinstance(process, list):
            _proc = subprocess.Popen(process, stdout=subprocess.PIPE)
        elif isinstance(process, str) or isinstance(process, unicode):
            _proc = subprocess.Popen([
                process], stdout=subprocess.PIPE, shell=True
            )
        else:
            return False
        (_proc, _proc_e) = _proc.communicate()
        return _proc

    def _download(self, url, save_path):
        """ Download the response from some given ``url``

        :param url: A valid accessable file url
        :type url: ``unicode`` or ``str``
        :param save_path: A valid file path
        :type save_path: ``unicode`` or ``str``
        :returns: True if successful download, otherwise False
        """

        self.log.info('retrieving url `{}` ...'.format(url))
        try:
            _response = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)
        except urllib2.HTTPError:
            self.log.error('`{}` could not be found'.format(url))
            return False

        if _response.getcode() != 200:
            self.log.error('error connecting to `{}`'.format(url))
            return False

        if not os.path.exists(os.path.dirname(save_path)):
            os.makedirs(os.path.dirname(save_path), 0775)
        with open(save_path, 'wb') as _file:
            self.log.info('downloading to `{}` ...'.format(save_path))
            _file.write(_response.read())
        return True

    def _AS_dialog(self):
        """ Prompt user with AppleScript informational dialog"""

        # Look for the `icon.png` for the current workflow
        _icon = self._lookback(
            'icon.png', end_path=os.path.split(self._cwd)[0]
        )
        if _icon and os.path.exists(_icon):
            _icon = ':'.join(_icon.split(os.sep)[1:])
        else:
            # Default icon to this system icon
            _icon = (
                'System:Library:CoreServices:CoreTypes.bundle:'
                'Contents:Resources:SideBarDownloadsFolder.icns'
            )
        _text = (
            '{name} needs to install additional components, which will be '
            'placed in the Alfred storage directory and will not interfere '
            'with your system.\n\nYou may be asked to allow some components '
            'to run, depending on your security settings.\n\nYou can decline '
            'this installation, but {name} may not work without them.\n'
            'There will be a slight delay ater accepting.'
        ).format(name=self.workflow)
        _script = (
            'display dialog "%s" buttons {"More Info", "Cancel", "Proceed"} '
            'default button 3 with title "%s Setup" with icon file "%s"'
        ) % (_text, self.workflow, _icon,)

        # Run the subprocess (_script)
        _retn = self._run_subprocess(
            'osascript -e \'{}\''.format(_script)
        ).replace('\n', '').split(':')[-1].lower()

        # Handle buttons
        if _retn == 'proceed':
            return True
        elif _retn == 'more info':
            self._run_subprocess('open {}'.format(INFO_RESOURCE))
            raise InstallationError(
                1001, 'Bundler installation was interrupted by `info resource`'
            )
        else:
            self.log.critical(
                'User canceled installation of Alfred Bundler. '
                'Unknown and possibly catastrophic events to follow.'
            )
            raise InstallationError(1002, 'Bundler installation canceled')
        return True

    def _install_bundler(self):
        """ Install the bundler to the valid `BUNDLER_DIRECTORY`"""

        # Prompt the user with the AS informational dialog
        if self._AS_dialog():
            _suffix = '-latest.zip'
            if os.getenv('AB_BRANCH'):
                _suffix = '.zip'
            _bundler_zip = os.path.join(CACHE_DIRECTORY, 'bundler.zip')

            # Walk through our bundler servers looking for an installation
            for server in BUNDLER_SERVERS:
                self.log.info(
                    'trying bundler installation from `{}` ...'.format(
                        server.format(_suffix)
                    )
                )
                if self._download(server.format(_suffix), _bundler_zip):
                    break

            # Extract and move the `bundler.zip` to the bundler directory
            try:
                self.log.info('extracting `{}` ...'.format(_bundler_zip))
                with zipfile.ZipFile(open(_bundler_zip, 'rb')) as _zip:
                    _zip_name = None
                    for i in _zip.namelist():
                        if not _zip_name:
                            _zip_name = i.split(os.sep)[0]
                        _ext_dir = os.path.dirname(_bundler_zip)
                        if i.split(os.sep)[1].lower() == 'bundler':
                            _zip.extract(i, _ext_dir)
                    shutil.copytree(
                        os.path.join(
                            os.path.dirname(_bundler_zip),
                            _zip_name, 'bundler'
                        ),
                        os.path.join(BUNDLER_DIRECTORY, 'bundler')
                    )
            except zipfile.BadZipfile:
                raise InstallationError(1003, 'Corrupt bundler zip downloaded')

            # Successful installation, clean up left over files
            self.log.info('Alfred Bundler successfuly installed, cleaning...')
            os.remove(_bundler_zip)
            shutil.rmtree(
                os.path.join(os.path.dirname(_bundler_zip), _zip_name)
            )
            # Ensure that the LightOrDark binary is executable
            os.chmod(
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'includes', 'LightOrDark'
                ),
                0775
            )

            # Reference the bundler and display a nice little installation
            # complete notification
            self.bundler = imp.load_source(
                os.path.splitext(BUNDLER)[0],
                os.path.join(BUNDLER_DIRECTORY, 'bundler', BUNDLER)
            ).Main(self._cwd)
            self.bundler.notify(
                'Alfred Bundler',
                'Installation successful. Thank you for waiting.',
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'meta', 'icons', 'bundle.png'
                )
            )
            return True
        else:
            return False
