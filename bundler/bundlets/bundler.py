#!/usr/bin/env python
# encoding: utf-8
#
# Copyright © 2014 The Alfred Bundler Team
# MIT License. <http://opensource.org/licenses/MIT>

"""
Python Alfred Bundler for workflow distribution.

.. module:: bundler
    :platform: MacOSX
    :synopsis: Python Alfred Bundler for workflow distribution.
.. moduleauthor:: deanishe
.. moduleauthor:: ritashugisha

Alfred Bundler is a framework to help workflow authors manage external
utilities and libraries required by their workflows without having to
include them with each and every workflow.

`Alfred Bundler Homepage/Documentation <http://shawnrice.github.io/alfred-bundler/>`_.

**NOTE**: By necessity, this Python implementation does not work in
exactly the same way as the reference PHP/bash implementations by
Shawn Rice.

The purpose of the Bundler is to enable workflow authors to easily
access utilites, icons, and libraries that are commonly used without having to
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

Usage
======

Simply include this ``bundler.py`` file (from the Alfred Bundler's
``bundler/bundlets`` directory) alongside your workflow's Python code
where it can be imported.

Here is a simple construction for a new AlfredBundler instance::

    import bundler
    my_bundler = bundler.AlfredBundler()

The :class:`~AlfredBundler.Main` class provides the methods to access utilities, icons, wrappers, and
required Python libraries. Both icons and requirements are managed by their
own nested classes AlfredBundlerIcon and AlfredBundlerRequirements.
The main features of the Python Bundler are the following:

Loading common utility programs simply by asking for them by name.
(e.g. `cocoaDialog <http://mstratman.github.io/cocoadialog/>`_).

Along the same line as utilities, wrappers have been built for the easy use of
interacting with specific utilities. Loading these wrappers can be done by
simply asking for the wrapper of some utility, by name.
(e.g. (e.g. `cocoaDialog <http://mstratman.github.io/cocoadialog/>`_ and
`Terminal-Notifier <https://github.com/alloy/terminal-notifier>`_).)

Loading icons from either the system or popular webfonts of any color simply
by requesting some icon of type `font`, `name`, and `color`.
System retrieved icons are not modified by any passed `color`.

The ability to automatically install and update any required non-standard
Python libraries by your workflow. This is achieved through the use of both
`Pip <http://pip.readthedocs.org/en/latest/index.html>`_ (the de facto Python
library installer) and the Pip `requirements <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_ file.

Loading utilities
-----------------

From the point where `my_bundler` has be attributed to a new instance of type
AlfredBundler.Main, we can load the path to an available utility by::

    utility_path = my_bundler.utility('utilityName')

which will return the path to the appropriate executable, installing
it first if necessary. You may optionally specify a version number
and/or your own JSON file that defines a non-standard utility.

Please see `the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_
for details of the JSON file format and how the Bundler works in general.

Loading wrappers
----------------

Wrappers are accessed in virtually the same way that utilities are.
Instead of returning the path to the wrapper,
the :func:`~AlfredBundler.Main().wrapper()` method returns an instance of the
wrapper already loaded with the utility::

    wrapper_instance = my_bundler.wrapper('wrapperName')

Loading icons
-------------

Icons are managed by the AlfredBundlerIcon nested class.

Icons can be loaded in from either the system icons or any of the supported
webfonts. Webfont icon's color can be manipulated through a passed hex color,
while system icon retrieval will ignore this argument. If the requested icon
does not exist in any of the supported webfonts, the path to the `default.png`
(broken IE) icon will be returned instead.

    icon_path = my_bundler.icon('fontName', 'iconName', 'colorHex')


Handling Python dependencies
----------------------------

Python dependencies are managed by the AlfredBundlerRequirements nested class.

The Python Bundler automatically handles your workflow dependencies through
the created instance of the AlfredBundlerRequirements. This is achieved through
the use of Pip's `requirements <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_ file in your workflow's root directory.

Because the bundler handles gathering those modules, you will have to load the
bundler before trying to import any non-standard Python modules specified in
the requirements file.

:func:`~AlfredBundler.AlfredBundlerRequirements.__init__()` will find your
``requirements`` file (AlfredBundlerRequirements will create this file if not
present`) and call Pip with it (installing Pip first if necessary).
Then it will add the directory it's installed the libraries in to ``sys.path``,
so you can immediately ``import`` those libraries.

The Bundler doesn't define any explicit exceptions, but may raise any number
of different ones (e.g. :class:`~exceptions.IOError` if a file doesn't
exist or if the computer or PyPi is offline).

Any problems with the Bundler may be raised on
`Alfred's forum <http://www.alfredforum.com/topic/4255-alfred-dependency-downloader-framework/>`_
or on `GitHub <https://github.com/shawnrice/alfred-bundler>`_.

"""

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


# Python bundler filename
BUNDLER = 'AlfredBundler.py'
# Path to bundler's data directory
BUNDLER_DIRECTORY = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{}'
)
# Path to bundler's log, appended to end of $BUNDLER_DIRECTORY
BUNDLER_LOGFILE = 'data/logs/bundler-{}.log'
# Path to the bundler's cache directory
CACHE_DIRECTORY = os.path.expanduser(
    '~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'
    'alfred.bundler-{}'
)
# Bundler's install servers
BUNDLER_SERVERS = [
    'https://github.com/shawnrice/alfred-bundler/archive/{}{suffix}',
    'https://bitbucket.org/shawnrice/alfred-bundler/get/{}{suffix}'
]
# Bundler's `More Info` resource URL
INFO_RESOURCE = (
    'https://github.com/shawnrice/alfred-bundler/wiki/'
    'What-is-the-Alfred-Bundler'
)
# Downloads connection timeout
HTTP_TIMEOUT = 5
# Major version to default to if AB_BRANCH cannot be loaded
DEFAULT_MAJOR_VERSION = 'devel'


class InstallationError(Exception):

    """ Raised if bundler installation fails.

    .. note::
            Code value corresponds to the type of error.
                default - 1000
                `More Info` pressed - 1001
                `Cancel` pressed - 1002
                corrupt zip file - 1003
    """

    def __init__(self, code=1000, message=''):
        """ Initialize InstallationError instance.

        :param code: Error code
        :type code: ``int``
        :param message: Error message
        :type mesage: ``str`` or ``unicode``
        """
        self.code = code
        self.message = message

    def __str__(self):
        """ Return a representation of the error.

        :returns: String representation of error
        :rtype: str
        """
        return repr('{} (code : {})'.format(self.message, self.code))


def AlfredBundler():
    """ Return an instance of bootstrapped bundler.

    .. note::
        Installs AlfredBundler if neccessary for bootstrap

    :returns: Loaded AlfredBundler object
    :rtype: AlfredBundler.Main()
    """

    return AlfredBundlerBootstrap().bundler


class AlfredBundlerBootstrap:

    """ Class used for installing and importing $BUNDLER.

    ..note::
        Requires `info.plist` to exist in `bundler.py`'s root directory
    """

    def __init__(self):
        """ Initialize the bundler's bootstrap client.

        :raises: EnvironmentError
        """

        # Globalize variables that require major_version formatting
        global BUNDLER_DIRECTORY, CACHE_DIRECTORY, BUNDLER_LOGFILE
        global BUNDLER_SERVERS

        self.log = logging.getLogger(self.__class__.__name__)

        # Grab the current file's directory, inspect.getfile() is used for
        # compatability with relative imports
        self.cwd = os.path.dirname(os.path.abspath(
            inspect.getfile(inspect.currentframe())
        ))
        self.bundler = None

        # Validate that the workflow's info.plist is present and active
        self.workflow = self._lookback(
            'info.plist', end_path=os.path.split(self.cwd)[0]
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
        logfile = logging.handlers.RotatingFileHandler(
            BUNDLER_LOGFILE, maxBytes=(1024 * 1024), backupCount=1
        )
        console = logging.StreamHandler()
        # Setup logfile logging format
        logfile.setFormatter(
            logging.Formatter(
                '[%(asctime)s] [%(filename)s:%(lineno)s] '
                '[%(levelname)s] %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S'
            )
        )
        # Setup console logging format
        console.setFormatter(
            logging.Formatter(
                '[%(asctime)s] [%(filename)s:%(lineno)s] '
                '[%(levelname)s] %(message)s',
                datefmt='%H:%M:%S'
            )
        )
        self.log.addHandler(logfile)
        self.log.addHandler(console)
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
                raise InstallationError('Unkown installation error')
                sys.exit(1)
        # Reference the bundler with imp
        if not self.bundler:
            self.bundler = imp.load_source(
                os.path.splitext(BUNDLER)[0],
                os.path.join(BUNDLER_DIRECTORY, 'bundler', BUNDLER)
            ).Main(self.cwd)
        # Call the wrapper to update itself, subprocess required for speed
        self._run_subprocess([
            '/bin/bash',
            os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'meta', 'update-wrapper.sh'
            )
        ])

    def _lookback(self, filename, start_path=None, end_path=None):
        """ Recursively walks directory path in reverse looking for a filename.

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
            start_path = self.cwd
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
            new_start = os.path.split(start_path)[0]
            return self._lookback(
                filename, start_path=new_start, end_path=end_path
            )
        else:
            return None

    def _run_subprocess(self, process):
        """ Run an unwaiting subprocess.

        :param process: A split subprocess
        :type process: ``list`` or ``str``
        :returns: Subprocess output
        :rtype: ``str``
        """

        if isinstance(process, list):
            proc = subprocess.Popen(process, stdout=subprocess.PIPE)
        elif isinstance(process, str) or isinstance(process, unicode):
            proc = subprocess.Popen([
                process], stdout=subprocess.PIPE, shell=True
            )
        else:
            return False
        (proc, proc_e,) = proc.communicate()
        return proc

    def _download(self, url, save_path):
        """ Download the response from some given ``url``.

        :param url: A valid accessable file url
        :type url: ``unicode`` or ``str``
        :param save_path: A valid file path
        :type save_path: ``unicode`` or ``str``
        :returns: True if successful download, otherwise False
        """

        self.log.info('retrieving url `{}` ...'.format(url))
        try:
            resp = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)
        except urllib2.HTTPError:
            self.log.error('`{}` could not be found'.format(url))
            return False

        if resp.getcode() != 200:
            self.log.error('error connecting to `{}`'.format(url))
            return False

        if not os.path.exists(os.path.dirname(save_path)):
            os.makedirs(os.path.dirname(save_path), 0775)
        with open(save_path, 'wb') as f:
            self.log.info('downloading to `{}` ...'.format(save_path))
            f.write(resp.read())
        return True

    def _AS_dialog(self):
        """ Prompt user with AppleScript installation informational dialog.

        :raises: InstallationError
        """

        # Look for the `icon.png` for the current workflow
        icon = self._lookback(
            'icon.png', end_path=os.path.split(self.cwd)[0]
        )
        if icon and os.path.exists(icon):
            icon = ':'.join(icon.split(os.sep)[1:])
        else:
            # Default icon to this system icon
            icon = (
                'System:Library:CoreServices:CoreTypes.bundle:'
                'Contents:Resources:SideBarDownloadsFolder.icns'
            )
        text = (
            '{name} needs to install additional components, which will be '
            'placed in the Alfred storage directory and will not interfere '
            'with your system.\n\nYou may be asked to allow some components '
            'to run, depending on your security settings.\n\nYou can decline '
            'this installation, but {name} may not work without them.\n'
            'There will be a slight delay ater accepting.'
        ).format(name=self.workflow)
        script = (
            'display dialog "%s" buttons {"More Info", "Cancel", "Proceed"} '
            'default button 3 with title "%s Setup" with icon file "%s"'
        ) % (text, self.workflow, icon,)

        # Run the subprocess (_script)
        retn = self._run_subprocess(
            'osascript -e \'{}\''.format(script)
        ).replace('\n', '').split(':')[-1].lower()

        # Handle buttons, raises InstallationError if `More Info` or `Cancel`
        if retn == 'proceed':
            return True
        elif retn == 'more info':
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
        """ Download and install the bundler from BUNDLER_SERVERS."""

        # Prompt the user with the AS informational dialog
        if self._AS_dialog():
            suffix = '-latest.zip'
            if os.getenv('AB_BRANCH'):
                suffix = '.zip'
            bundler_zip = os.path.join(CACHE_DIRECTORY, 'bundler.zip')

            # Walk through our bundler servers looking for an installation
            for server in BUNDLER_SERVERS:
                self.log.info(
                    'trying bundler installation from `{}` ...'.format(
                        server.format(suffix)
                    )
                )
                if self._download(server.format(suffix), bundler_zip):
                    break

            # Extract and move the `bundler.zip` to the bundler directory
            try:
                self.log.info('extracting `{}` ...'.format(bundler_zip))
                with zipfile.ZipFile(open(bundler_zip, 'rb')) as z:
                    zip_name = None
                    for i in z.namelist():
                        if not zip_name:
                            zip_name = i.split(os.sep)[0]
                        ext_dir = os.path.dirname(bundler_zip)
                        if i.split(os.sep)[1].lower() == 'bundler':
                            z.extract(i, ext_dir)
                    shutil.copytree(
                        os.path.join(
                            os.path.dirname(bundler_zip),
                            zip_name, 'bundler'
                        ),
                        os.path.join(BUNDLER_DIRECTORY, 'bundler')
                    )
            except zipfile.BadZipfile:
                raise InstallationError(1003, 'Corrupt bundler zip downloaded')

            # Successful installation, clean up left over files
            self.log.info('Alfred Bundler successfuly installed, cleaning...')
            os.remove(bundler_zip)
            shutil.rmtree(
                os.path.join(os.path.dirname(bundler_zip), zip_name)
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
            ).Main(self.cwd)
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
