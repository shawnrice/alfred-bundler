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
    b = bundler.AlfredBundler()
    util_path = b.utility('utilityName')

which will return the path to the appropriate executable, installing
it first if necessary. You may optionally specify a version number
and/or your own JSON file that defines a non-standard utility.

Please see `the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_
for details of the JSON file format and how the Bundler works in general.

Handling Python dependencies
----------------------------

The Python Bundler can also take care of your workflow's dependencies for
you if you create a `requirements <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_
file in your workflow root directory and put the following in your Python
source files before trying to import any of those dependencies::

    import bundler
    b = bundler.AlfredBundler()

:func:`~AlfredBundler.__init__()` will find your ``requirements``  file (AlfredBundlerRequirements will create this file if not present`)
and call Pip with it (installing Pip first if necessary). Then it will
add the directory it's installed the libraries in to ``sys.path``, so you
can immediately ``import`` those libraries::

    import bundler
    b = bundler.AlfredBundler()
    import requests  # specified in `requirements`

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

"""

from __future__ import unicode_literals
import os
import re
import sys
import imp
import time
import json
import shutil
import inspect
import urllib2
import hashlib
import cPickle
import logging
import logging.handlers
import colorsys
import plistlib
import subprocess

# Bundler id for storing Python libraries in $BUNDLER_DIRECTORY
BUNDLER_ID = 'alfredbundler.default'
# Path to bundler's data directory, requires formatting
BUNDLER_DIRECTORY = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{}'
)
# Path to bundler's log, appended to end of $BUNDLER_DIRECTORY
BUNDLER_LOGFILE = 'data/logs/bundler-{}.log'
# AlfredBundler's global logger object
BUNDLER_LOGGER = None
# Path to the bundler's shell script update wrapper
BUNDLER_UPDATER = os.path.join(
    BUNDLER_DIRECTORY, 'bundler', 'meta', 'update-wrapper.sh'
)
# Path to the bundler's cache directory, requires formatting
CACHE_DIRECTORY = os.path.expanduser(
    '~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'
    'alfred.bundler-{}'
)
# Path to Alfred's preferences plist
PREFERENCES_PLIST = os.path.expanduser(
    '~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist'
)
# Path to MacOSX system icons, requires formatting
SYSTEM_ICONS = (
    '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/'
    '{name}.icns'
)
# Path to bundler's `update.json`
UPDATE_JSON = os.path.join(
    BUNDLER_DIRECTORY, 'data', 'assets', 'python', BUNDLER_ID, 'update.json'
)
# Downloads connection timeout
HTTP_TIMEOUT = 5
# Update checking interval, 604800 = 1 week
UPDATE_INTERVAL = 604800
# `get-pip.py` installation url
GET_PIP = (
    'https://raw.githubusercontent.com/pypa/pip/develop/contrib/get-pip.py'
)
# Global current file's directory
CWD = os.path.dirname(os.path.abspath(__file__))
# Path to bundler's Python library directory
PYTHON_LIBRARY = os.path.join(
    BUNDLER_DIRECTORY, 'data', 'assets', 'python', BUNDLER_ID
)


class Metadata(object):

    """ Stores update metadata.

    Last update time and Etags are stored in this object

    """

    def __init__(self, filepath):
        """ Initialize the Metadata instance.

        :param filepath: Path to metadata storage
        :type filepath: ``str`` or ``unicode``

        """
        self._filepath = filepath
        self._etags = {}
        self._last_updated = 0
        if os.path.exists(self._filepath):
            self._load()

    def _load(self):
        """ Load cached settings from json in `self._filepath`."""
        with open(self._filepath, 'rb') as f:
            data = json.load(f, encoding='utf-8')
        self._etags = data.get('etags', {})
        self._last_updated = data.get('last_updated', 0)

    def save(self):
        """ Save settings to json file in `self._filepath`."""
        data = dict(etags=self._etags, last_updated=self._last_updated)
        if not os.path.exists(os.path.dirname(self._filepath)):
            os.makedirs(os.path.dirname(self._filepath), 0775)
        with open(self._filepath, 'wb') as f:
            json.dump(data, f, sort_keys=True, indent=2, encoding='utf-8')

    def set_etag(self, url, etag):
        """ Save Etag for `url`.

        :param url: URL key for Etag
        :type url: ``str`` or ``unicode``
        :param etag: Etag for URL
        :type etag: ``str`` or ``unicode``

        """
        self._etags[url] = etag
        self.save()

    def get_etag(self, url):
        """ Return Etag for `url` or `None`.

        :param url: URL to retrieve Etag for
        :type url: ``str`` or ``unicode``
        :returns: Etag or ``None``
        :rtype: ``unicode`` or ``None``

        """
        return self._etags.get(url, None)

    def set_updated(self):
        """ Record current time as last updated time."""
        self._last_updated = time.time()
        self.save()

    def get_updated(self):
        """ Return last updated time."""
        return self._last_updated

    def wants_update(self):
        """ Returns `True` if update is due, else `False`."""
        return (time.time() - self._last_updated) > UPDATE_INTERVAL


class Cached(object):

    """ Decorator used to cache function calls."""

    def __init__(self, function):
        """ Initialize decorator with the function descriptor.

        :param function: Function reference

        """
        self.function = function
        self.cachepath = os.path.join(
            os.path.dirname(CWD), 'data', 'assets', 'python', BUNDLER_ID,
            '{}.{}.cache'.format(__name__, self.function.__name__)
        )
        self.cache = {}
        if os.path.exists(self.cachepath):
            with open(self.cachepath, 'rb') as _file:
                self.cache = cPickle.load(_file)

    def __call__(self, *args, **kwargs):
        """ Return path to function cache on call.

        :param *args: Arguments
        :type *args: List of arguments
        :param **kwargs: Equal arguments
        :type **kwargsL Dictionary of arguments
        :returns: Path to function cache
        :rtype: ``str`` or ``unicode``

        """
        key = (args, frozenset(kwargs.items()))
        _path = self.cache.get(key, None)
        if _path is None or not os.path.exists(_path):
            _path = self.function(*args, **kwargs)
            self.cache[key] = _path
            _dirpath = os.path.dirname(self.cachepath)
            if not os.path.exists(_dirpath):
                os.makedirs(_dirpath, 0775)
            with open(self.cachepath, 'wb') as _file:
                cPickle.dump(self.cache, _file, protocol=2)
        return _path

    def __repr__(self):
        """ Represent the function through the function's docstring."""
        return self.function.__doc__


class NestedAccess(object):

    """Decorator used to provide child classes with access to their parent."""

    def __init__(self, cls):
        """Initialize decorator with the class descriptor.

        :param cls: Parent class initializing wrapper class

        """
        self.cls = cls

    def __get__(self, instance, outer_class):
        """Grab the parent class's object and returns in a Wrapper class.

        :param instance: Instance of child class
        :param outer_class: Parent class object
        :returns: Parent object in object variable *outer*

        """
        class Wrapper(self.cls):
            outer = instance

        Wrapper.__name__ = self.cls.__name__
        return Wrapper


def _lookback(filename, start_path=None, end_path=None):
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
        start_path = os.path.dirname(os.path.abspath(
            inspect.getfile(inspect.currentframe())
        ))
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
        return _lookback(
            filename, start_path=new_start, end_path=end_path
        )
    else:
        return None


def _download(url, save_path):
    """ Download the response from some given ``url``

    :param url: A valid accessable file url
    :type url: ``unicode`` or ``str``
    :param save_path: A valid file path
    :type save_path: ``unicode`` or ``str``
    :returns: True if successful download, otherwise False

    """

    BUNDLER_LOGGER.info('retrieving url `{}` ...'.format(url))
    try:
        resp = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)
    except urllib2.HTTPError:
        BUNDLER_LOGGER.error('`{}` could not be found'.format(url))
        return False

    if resp.getcode() != 200:
        BUNDLER_LOGGER.error('error connecting to `{}`'.format(url))
        return False

    if not os.path.exists(os.path.dirname(save_path)):
        os.makedirs(os.path.dirname(save_path), 0775)
    with open(save_path, 'wb') as f:
        BUNDLER_LOGGER.info('downloading to `{}` ...'.format(save_path))
        f.write(resp.read())
    return True


def _run_subprocess(process):
    """ Run a unwaiting subprocess

    :param process: A split subprocess
    :type process: ``list`` or ``str``
    :returns: Subprocess output

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


@Cached
def _utility(name, version='latest', json_path=None, workflow_id=None):
    """ Global private function used to install, register and return a utility.

    @cached function

    :param name: Name of the desired utility/asset to isntall
    :type name: ``str`` or ``unicode``
    :param version: Desired version of the utility/asset
    :type version: ``str`` or ``unicode``
    :param json_path: Path to bundler configuration file
    :type json_path: ``str`` or ``unicode``
    :param workflow_id: Current workflow bundle id
    :type workflow_id: ``str`` or ``unicode``
    :returns: Path to isntalled utility/asset
    :rtype: ``unicode``

    """
    json_path = json_path or ''
    # Run the `/bundlets/alfred.bundler.sh utility` to handle installation
    utility = _run_subprocess([
        '/bin/bash', os.path.join(
            BUNDLER_DIRECTORY, 'bundler', 'bundlets', 'alfred.bundler.sh'
        ), 'utility', name, version, json_path
    ])
    # If passed an workflow id, register the asset (used for wrapper import)
    if workflow_id:
        _register_asset(name, version, workflow_id=workflow_id)
    return utility.split('\n')[0]


def _register_asset(asset, version, workflow_id=None):
    """ Global private function used to register an asset/utility.

    :param asset: Name of the desired utility/asset
    :type asset: ``str`` or ``unicode``
    :param version: Desired version of the utility/asset
    :type version: ``str`` or ``unicode``
    :param workflow_id: Current workflow bundle id
    :type workflow_id: ``str`` or ``unicode``
    :returns: `True`
    :rtype: ``bool``

    """
    if not workflow_id:
        BUNDLER_LOGGER.error(
            'cannot register asset without a passed workflow id'
        )
        return False
    registry_path = os.path.join(
        BUNDLER_DIRECTORY, 'data', 'registry.json'
    )
    registry = {}
    update = False
    # Create the registry if it doesn't exist, otherwise read it in to registry
    if os.path.exists(registry_path):
        registry = json.loads(open(registry_path, 'rb').read())
    else:
        json.dump(registry, open(registry_path, 'wb'))
    # Add the workflow id to the passed asset, registry layout:
    # {'asset': [{'version': [workflow_id, ...]}, ...]}
    if asset in registry.keys():
        if version not in registry[asset].keys():
            registry[asset][version] = []
            update = True
        if workflow_id not in registry[asset][version]:
            registry[asset][version].append(workflow_id)
            update = True
    else:
        registry[asset] = {version: [workflow_id]}
        update = True
    if update:
        json.dump(registry, open(registry_path, 'wb'))
    return True


class Main:

    """ Main AlfredBundler internal classed, passed through bundler.py to workflow.

    """

    def __init__(self, calling_path):
        """ Initialize the AlfredBundler.Main instance.

        :param calling_path: Path to the workflow directory of the calling bundler
        :type calling_path: ``str`` or ``unicode``

        """

        global BUNDLER_DIRECTORY, CACHE_DIRECTORY, BUNDLER_LOGFILE
        global BUNDLER_UPDATER, UPDATE_JSON, PYTHON_LIBRARY, BUNDLER_LOGGER

        # Saved the calling workflow's directory
        self.called = calling_path
        # Grab the major and minor versions from environment or defaults
        self.major_version = os.getenv('AB_BRANCH')
        if not self.major_version:
            self.major_version = open(
                os.path.join(CWD, 'meta', 'version_major')
            ).readline()
        self.minor_version = open(
            os.path.join(CWD, 'meta', 'version_minor')
        ).readline()

        # Format the required globals with the major version name
        BUNDLER_DIRECTORY = BUNDLER_DIRECTORY.format(self.major_version)
        BUNDLER_UPDATER = BUNDLER_UPDATER.format(self.major_version)
        UPDATE_JSON = UPDATE_JSON.format(self.major_version)
        CACHE_DIRECTORY = CACHE_DIRECTORY.format(self.major_version)
        PYTHON_LIBRARY = PYTHON_LIBRARY.format(self.major_version)
        BUNDLER_LOGFILE = os.path.join(
            BUNDLER_DIRECTORY, BUNDLER_LOGFILE.format(self.major_version)
        )
        BUNDLER_LOGGER = self.logger(self.__class__.__name__, BUNDLER_LOGFILE)

        # Get workflow information from either environment or info.plist
        self.workflow_id = None
        self.workflow_name = None
        self.workflow_data = None
        self.workflow_log = None

        if os.getenv('alfred_version'):
            # Grab workflow information from environment variables
            self.workflow_id = os.getenv('alfred_workflow_bundleid')
            self.workflow_name = os.getenv('alfred_workflow_name')
            self.workflow_data = os.getenv('alfred_workflow_data')
        else:
            # Grab workflow information from `info.plist`
            info_plist = _lookback(
                'info.plist',
                start_path=self.called, end_path=os.path.dirname(self.called)
            )
            if info_plist:
                info_plist = plistlib.readPlist(info_plist)
                self.workflow_id = info_plist['bundleid']
                self.workflow_name = info_plist['name']
                self.workflow_data = os.path.expanduser(
                    '~/Library/Application Support/Alfred 2/Workflow Data/{}'
                    .format(self.workflow_id)
                )
            else:
                raise EnvironmentError(
                    'The Alfred Bundler cannot be used without an '
                    '`info.plist` file present'
                )
                sys.exit(1)
        # Build default workflow logging object
        self.log = self.logger(
            self.workflow_name,
            os.path.join(
                self.workflow_data, 'logs',
                '{}.log'.format(self.workflow_id)
            )
        )

        # Ensure the creation of required directories
        for i in [
            os.path.join(BUNDLER_DIRECTORY, 'data'),
            CACHE_DIRECTORY,
            os.path.join(CACHE_DIRECTORY, 'color'),
            os.path.join(CACHE_DIRECTORY, 'misc'),
            os.path.join(CACHE_DIRECTORY, 'php'),
            os.path.join(CACHE_DIRECTORY, 'ruby'),
            os.path.join(CACHE_DIRECTORY, 'python'),
            os.path.join(CACHE_DIRECTORY, 'utilities'),
            PYTHON_LIBRARY,
        ]:
            if not os.path.exists(i):
                os.makedirs(i, 0775)

        # Grab the wrappers object using imp
        self.wrappers = None
        (f, n, d,) = imp.find_module(
            'wrappers', [
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'includes',
                    'wrappers', 'python'
                )
            ]
        )
        self.wrappers = imp.load_module('wrappers', f, n, d)

        # Handle metadata for updates and requirements installation
        self.running_update = False
        self.metadata = Metadata(UPDATE_JSON)
        self.requirements = self.AlfredBundlerRequirements(
            _lookback(
                'requirements', start_path=self.called,
                end_path=os.path.dirname(self.called)
            )
        )
        self.requirements._handle_requirements()

    def _update(self):
        """ Check for periodical updates of bundler and pip."""
        if self.running_update:
            return
        if not self.metadata.wants_update():
            return
        self.running_update = True
        try:
            self.notify(
                'Updating Workflow Libraries',
                'Your workflow will continue momentarily'
            )
            proc = subprocess.Popen(['/bin/bash', BUNDLER_UPDATER])
            self.requirements._install_pip()
            retcode = proc.wait()
            if retcode:
                BUNDLER_LOGGER.error(
                    'error updating bundler `{}`'.format(retcode)
                )
            self.metadata.set_updated()
        finally:
            self.running_update = False

    def _download_update(self, url, filepath, ignore_missing=False):
        """Replace ``filepath`` with file at ``url`` if it has been updated
        as determined by ``etag`` read from ``UPDATE_JSON_PATH``.

        :param url: URL to remote resource
        :type url: ``unicode`` or ``str``
        :param filepath: Local filepath to save URL at
        :type filepath: ``unicode`` or ``str``
        :param ignore_missing: If ``True``, do not automatically download the
            file just because it is missing.
        :type ignore_missing: ``boolean``
        :returns: ``True`` if updated, else ``False``
        :rtype: ``boolean``

        """
        prev_etag = self.metadata.get_etag(url)
        BUNDLER_LOGGER.info('retrieving `{}` ...'.format(url))
        resp = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)
        if resp.getcode() != 200:
            raise IOError(
                2, 'Error retrieving url. Server returned {}'.format(
                    resp.getcode()
                ), url
            )
        curr_etag = resp.info().get('Etag')
        force = not os.path.exists(filepath) and not ignore_missing
        if curr_etag != prev_etag or force:
            with open(filepath, 'wb') as f:
                BUNDLER_LOGGER.info('saving to `{}` ...'.format(filepath))
                f.write(resp.read())
            self.metadata.set_etag(url, curr_etag)
            return True
        return False

    def logger(self, name, log_path=None):
        """ Return ``~logging.Logger`` object that logs to ``log_path`` and STDERR.

        :param name: Name of logger
        :type name: ``unicode`` or ``str``
        :param log_path: Path to logfile. If ``None``, a default logfile in the
            workflow's data directory will be used.
        :type log_path: ``unicode`` or ``str``
        :returns: Configured ``~logging.Logger`` object

        """

        # Ensure log path exists for workflow log
        if not log_path:
            log_path = os.path.join(
                os.path.split(BUNDLER_DIRECTORY)[0],
                self.workflow_id, 'logs',
                '{}.log'.format(self.workflow_id)
            )
        log_dir = os.path.dirname(log_path)
        if not os.path.exists(log_dir):
            os.makedirs(log_dir, 0755)

        logger = logging.getLogger(name)
        if not logger.handlers:
            # Setup logging to logfile and console
            logfile = logging.handlers.RotatingFileHandler(
                log_path, maxBytes=(1024 * 1024), backupCount=1
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
            logger.addHandler(logfile)
            logger.addHandler(console)

        logger.setLevel(logging.DEBUG)
        return logger

    def notify(self, title, message, icon=None):
        """ Send a notification to the desktop.
        Note: wrappers must be on the system for this method to work.

        :param title: Title of notification
        :type title: ``str`` or ``unicode``
        :param message: Message of notification
        :type message: ``str`` or ``unicode``
        :param icon: Absolute path to icon for notification
        :type icon: ``str`` or ``unicode``
        :returns: `True` if displayed, `False` otherwise
        :rtype: ``bool``

        """
        if (isinstance(title, str) or isinstance(title, unicode)) and \
           (isinstance(message, str) or isinstance(message, unicode)):
            client = self.wrapper('cocoadialog', debug=True)
            icon_type = 'icon'
            if icon and (isinstance(icon, str) or isinstance(icon, unicode)):
                if not os.path.exists(icon):
                    if icon not in client.global_icons:
                        icon_type = None
                else:
                    icon_type = 'icon_file'
            else:
                icon_type = None
            notification = {
                'title': title,
                'description': message
            }
            if icon_type:
                notification[icon_type] = icon
            client.notify(**notification)
            return True
        else:
            return False

    def icon(self, font, icon, color='000000', alter=False):
        """ Return a retrieved `icon` from the given `font` of color `color`.

        ``font``, ``icon`` and ``color`` are normalised to lowercase. In
        addition, ``color`` is expanded to 6 characters if only 3 are passed.

        :param font: name of the font
        :type font: ``unicode`` or ``str``
        :param icon: name of the font character
        :type icon: ``unicode`` or ``str``
        :param color: CSS colour in format "xxxxxx" (no preceding #)
        :type color: ``unicode`` or ``str``
        :param alter: Automatically adjust icon color to light/dark theme
            background if ``bool``, if ``list`` then apply (r, g, b) values
        :type alter: ``bool``
        :returns: path to icon file
        :rtype: ``unicode``

        See http://icons.deanishe.net to view available icons.

        """
        return self.AlfredBundlerIcon(
            font, icon, color=color, alter=alter
        ).icon

    def icns(self):
        """ Creates and return an .icns file out of the workflow's `icon.png`.

        :returns: Path to created .icns file
        :rtype: ``unicode``

        """
        info_plist = _lookback(
            'info.plist',
            start_path=self.called, end_path=os.path.dirname(self.called)
        )
        # Check that `icon.png` exists next to `info.plist`
        if not os.path.exists(os.path.join(
            os.path.dirname(info_plist), 'icon.png'
        )):
            BUNDLER_LOGGER.error((
                'cannot convert to icns, '
                'icon.png does not exist in `{}`'
            ).format(os.path.dirname(info_plist)))
            return False
        # Get cache icon file path
        cache_icon = os.path.join(
            CACHE_DIRECTORY, 'icns', '{}.icns'.format(self.workflow_id)
        )
        if os.path.exists(cache_icon):
            return os.path.join(
                CACHE_DIRECTORY, 'icns', '{}.icns'.format(self.workflow_id)
            )
        else:
            if not os.path.exists(os.path.dirname(cache_icon)):
                os.makedirs(os.path.dirname(cache_icon), 0775)
            # Run the `/includes/png_to_icns.sh` to convert the .png to .icns
            _run_subprocess([
                '/bin/bash',
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'includes', 'png_to_icns.sh'
                ),
                os.path.join(os.path.dirname(info_plist), 'icon.png'),
                cache_icon
            ])
            if os.path.exists(cache_icon):
                return cache_icon
            else:
                BUNDLER_LOGGER.error(
                    'could not convert `icon.png` to .icns , unknown reason'
                )
                return False

    def wrapper(self, wrapper, debug=False):
        """ Return a loaded wrapper for an available utility.

        :param wrapper: Name of the desired wrapper to load
        :type wrapper: ``str`` or ``unicode``
        :param debug: `True` if debug is enabled
        :type debug: ``bool``
        :returns: Initialized wrapper instance

        """
        return self.wrappers.wrapper(
            wrapper.lower(), debug=debug, workflow_id=self.workflow_id
        )

    def utility(self, name, version='latest', json_path=None):
        """ Install, register and return a utility.

        @Cached function.

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

        :param name: Name of the desired utility/asset to install
        :type name: ``str`` or ``unicode``
        :param version: Desired version of the utility/asset
        :type version: ``str`` or ``unicode``
        :param json_path: Path to bundler configuration file
        :type json_path: ``str`` or ``unicode``
        :param workflow_id: Current workflow bundle id
        :type workflow_id: ``str`` or ``unicode``
        :returns: Path to isntalled utility/asset
        :rtype: ``unicode``

        """
        retn = _utility(name, version, json_path=json_path)
        self.register_asset(name, version)
        return retn

    def register_asset(self, asset, version, workflow_id=None):
        """ Register an asset to the workflow.

        :param asset: Name of the desired asset
        :type asset: ``str`` or ``unicode``
        :param version: Desired version of the asset
        :type version: ``str`` or ``unicode``
        :param workflow_id: Current workflow bundle id
        :type workflow_id: ``str`` or ``unicode``
        :returns: `True`
        :rtype: ``bool``

        """
        if not workflow_id:
            workflow_id = self.workflow_id
        return _register_asset(asset, version, workflow_id=self.workflow_id)

    @NestedAccess
    class AlfredBundlerIcon:

        """ Class used for downloading and returning pased icons.

        @NestedAccess class

        """

        def __init__(self, font, name, color='000000', alter=False):
            """ Initialize an AlfredBundlerIcon instance.

            :param font: name of the font
            :type font: ``unicode`` or ``str``
            :param icon: name of the font character
            :type icon: ``unicode`` or ``str``
            :param color: CSS colour in format "xxxxxx" (no preceding #)
            :type color: ``unicode`` or ``str``
            :param alter: Automatically adjust icon color to light/dark theme
                background if ``bool``, if ``list`` then apply (r, g, b) values
            :type alter: ``bool``

            See http://icons.deanishe.net to view available icons.

            """
            (self.font, self.name, self.color, self.alter,) = (
                font, name, color, alter
            )
            self.cache = os.path.join(CACHE_DIRECTORY, 'color')
            self.background = None
            self.fallback = os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'meta', 'icons', 'default.png'
            )
            # Ensure the required directories exist
            if not os.path.exists(os.path.join(BUNDLER_DIRECTORY, 'data')):
                os.makedirs(os.path.join(BUNDLER_DIRECTORY, 'data'), 0775)
            if not os.path.exists(self.cache):
                os.makedirs(self.cache, 0775)

            # Set the `theme_background` file to dark/light
            self._set_background()

            # Handle multiple alter arguments
            if self.alter:
                if isinstance(self.alter, bool):
                    self.color = self.rgb_to_hex(
                        *self.altered(*self.hex_to_rgb(self.color))
                    )
                elif ((
                    isinstance(self.alter, tuple) or
                    isinstance(self.alter, list)
                ) and len(self.alter) == 3):
                    self.color = self.rgb_to_hex(*self.alter)
                elif isinstance(self.alter, str) or \
                        isinstance(self.alter, unicode):
                    self.color = self.rgb_to_hex(
                        *self._normalize_hex(self.alter)
                    )

            # Save the retrieved icon to `self.icon`
            self.icon = None
            if self.font.lower() == 'system':
                self.icon = self.system_icon(self.name)
            else:
                icon_path = os.path.join(
                    BUNDLER_DIRECTORY, 'data', 'assets', 'icons',
                    self.font, self.color, self.name
                )
                if os.path.exists('{}.png'.format(icon_path)):
                    self.icon = '{}.png'.format(icon_path)
                else:
                    self.icon = self.retrieve_icon(
                        self.font, self.color, self.name
                    )
            # Fallback to the default icon if the icon couldn't be retrieved
            if not os.path.exists(self.icon):
                self.icon = self.fallback

        def __repr__(self):
            """ Represent the AlfredBundlerIcon instance as a string.

            :returns: String representation of the instance
            :rtype: ``unicode``

            """
            return (
                '{}(\n  font=`{}`\n  name=`{}`\n  '
                'color=`{}`\n  icon=`{}`\n)'
            ).format(
                self.__class__.__name__, self.font, self.name,
                self.color, self.icon
            )

        def _set_background(self):
            """ Determine whether background is ``light`` or ``dark`` and save
            the value.

            """
            if os.getenv('alfred_version'):
                # Grab the background from environment
                pattern = re.match(
                    r'rgba\((\d+),(\d+),(\d+),([0-9.]+)\)',
                    os.getenv('alfred_theme_background')
                )
                self.background = 'dark' if (
                    self.luminance(*pattern.groups()[0:-1]) < 140
                ) else 'light'
            else:
                # Run the `LightOrDark` utility to save brightness to background
                background_cache = os.path.join(
                    CACHE_DIRECTORY, 'misc', 'theme_background'
                )
                if not os.path.exists(os.path.dirname(background_cache)):
                    os.makedirs(os.path.dirname(background_cache), 0775)
                if os.path.exists(background_cache) and (
                    os.stat(background_cache).st_mtime >
                    os.stat(PREFERENCES_PLIST).st_mtime
                ):
                    self.background = open(background_cache, 'rb').read()
                    return True
                self.background = _run_subprocess([
                    '/bin/bash',
                    os.path.join(
                        BUNDLER_DIRECTORY, 'bundler', 'includes', 'LightOrDark'
                    )
                ])
                with open(background_cache, 'wb') as f:
                    f.write(self.background)

        def _normalize_hex(self, hex_color):
            """ Convert CSS colour to 6-characters and lowercase.

            :param color: CSS colour of form XXX or XXXXXX
            :type color: ``unicode`` or ``str``
            :returns: Normalised CSS colour of form xxxxxx
            :rtype: ``unicode``

            """
            if not re.match(
                r'^(?:[a-fA-F0-9]{3}){1,2}$',
                hex_color.lower().strip('#')
            ):
                raise ValueError(
                    'invalid passed hex color : {}'.format(hex_color)
                )
            if len(hex_color) == 3:
                (r, g, b,) = hex_color
                hex_color = '{r}{r}{g}{g}{b}{b}'.format(r=r, g=g, b=b)
            return hex_color

        def rgb_to_hex(self, r, g, b):
            """ Return CSS hex representation of colour.

            :param r: Red
            :type r: ``int`` 0-255
            :param g: Green
            :type g: ``int`` 0-255
            :param b: Blue
            :type b: ``int`` 0-255
            :returns: 6-character CSS hex
            :rtype: ``unicode``

            """

            def _normalize(i):
                return int(max(0, min(round(int(i)), 255)))

            return '{:02x}{:02x}{:02x}'.format(
                _normalize(r), _normalize(g), _normalize(b)
            )

        def hex_to_rgb(self, hex_color):
            """ Convert CSS-style colour to ``(r, g, b)``.

            :param colour: xxx or xxxxxx CSS colour
            :type colour: ``unicode`` or ``str``
            :returns: ``(r, g, b)`` tuple of ``ints`` 0-255
            :rtype: ``tuple``

            """
            color = self._normalize_hex(hex_color)
            (r, g, b,) = (
                int(color[:2], 16),
                int(color[2:4], 16),
                int(color[4:6], 16),
            )
            return (r, g, b,)

        def rgb_to_hsv(self, r, g, b):
            """ Convert RGB colour to HSV.

            :param r: Red
            :type r: ``int`` 0-255
            :param g: Green
            :type g: ``int`` 0-255
            :param b: Blue
            :type b: ``int`` 0-255
            :returns: ``(h, s, v)`` tuple of floats
            :rtype: ``tuple``

            """
            (r, g, b,) = map(lambda i: i / 255.0, (r, g, b,))
            return colorsys.rgb_to_hsv(r, g, b)

        def hsv_to_rgb(self, h, s, v):
            """ Convert HSV to RGB (for CSS, i.e. 0-255, not floats).

            :param h: Hue
            :type h: ``float``
            :param s: Saturation
            :type s: ``float``
            :param v: Value
            :type v: ``float``
            :returns: ``(r, g, b)`` tuple, where the values are ints between 0-255
            :rtype: ``tuple``

            """
            return tuple(map(
                lambda i: int(round(i * 255.0)),
                colorsys.hsv_to_rgb(h, s, v)
            ))

        def luminance(self, r, g, b):
            """ Return the luminance of an (r, g, b,) color.

            :param r: Red
            :type r: ``int`` 0-255
            :param g: Green
            :type g: ``int`` 0-255
            :param b: Blue
            :type b: ``int`` 0-255
            :returns: 0.0-255.0 luminance
            :rtype: ``int``

            """
            return sum([
                (299 * int(r)) + (587 * int(g)) + (114 * int(b))
            ]) / 1000.0

        def altered(self, r, g, b):
            """ Return lightened/darkened version of passed (r, g, b,).

            :param r: Red
            :type r: ``int`` 0-255
            :param g: Green
            :type g: ``int`` 0-255
            :param b: Blue
            :type b: ``int`` 0-255
            :returns: ``(h, s, v)`` tuple of floats
            :rtype: ``tuple``
            :returns: CSS colour
            :rtype: ``unicode``

            """
            (h, s, v,) = self.rgb_to_hsv(r, g, b)
            v = 1 - v
            return self.hsv_to_rgb(h, s, v)

        def system_icon(self, icon_name):
            """ Try to retrieve the icon ``icon_name`` from the system font.

            :param icon_name: Name of a system icon
            :type icon_name: ``str`` or ``unicode``
            :returns: Path to either found system icon or default icon
            :rtype: ``unicode``

            """
            icon = SYSTEM_ICONS.format(name=icon_name)
            if os.path.exists(icon):
                return icon
            BUNDLER_LOGGER.warning(
                'system icon `{}` could not be found, passing default'.format(
                    icon_name.lower()
                )
            )
            return os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'meta', 'icons', 'default.icns'
            )

        def retrieve_icon(self, font, color, name):
            """ Try to retrieve the icon from any of the urls in icon_servers.

            :param font: name of the font
            :type font: ``unicode`` or ``str``
            :param icon: name of the font character
            :type icon: ``unicode`` or ``str``
            :param color: CSS colour in format "xxxxxx" (no preceding #)
            :type color: ``unicode`` or ``str``
            :param alter: Automatically adjust icon color to light/dark theme
                background if ``bool``, if ``list`` then apply (r, g, b) values
            :type alter: ``bool``
            :returns: path to icon file
            :rtype: ``unicode``

            See http://icons.deanishe.net to view available icons.

            """
            save_dir = os.path.join(
                BUNDLER_DIRECTORY, 'data', 'assets', 'icons', font, color
            )
            if not os.path.exists(save_dir):
                os.makedirs(save_dir, 0775)
            icon = os.path.join(save_dir, '{}.png'.format(name))
            sub_url = 'icon/{font}/{color}/{name}'.format(
                font=font, color=color, name=name
            )
            # Walk through icon_servers with sub_url looking for matching icons
            for i in open(
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'meta', 'icon_servers'
                )
            ).read().split('\n')[:-1]:
                if _download('{}/{}'.format(i, sub_url), icon):
                    break
            return icon

    @NestedAccess
    class AlfredBundlerRequirements:

        """ Class to handle the workflow's required Python libraries.

        Install dependencies from ``requirements`` to your workflow's
        custom bundler directory and add this directory to ``sys.path``.

        If ``requirements`` cannot be found, instance will create empty ``requirements``

        **Note:** Your workflow must have a bundle ID set in order to use
        this function. (You should set one anyway, especially if you intend
        to distribute your workflow.)

        Your ``requirements`` file must be in the
        `format required by Pip <http://pip.readthedocs.org/en/latest/user_guide.html#requirements-files>`_.

        """

        def __init__(self, reqpath=None):
            """ Create instance of AlfredBundlerRequirements.

            :param reqpath: Path to ``requirements`` if not in root
            :type reqpath: ``str`` or ``unicode``

            """
            self.reqpath = reqpath or os.path.join(
                self.outer.called, 'requirements'
            )
            if not self.reqpath or not os.path.exists(self.reqpath):
                BUNDLER_LOGGER.info(
                    'generating `requirements` at `{}`'.format(self.reqpath)
                )
                with open(self.reqpath, 'wb') as f:
                    f.close()

        def _handle_requirements(self):
            """ Handle updating the requried Python libraries if ``requirements`` has been changed.

            """

            self.outer._update()
            metadata_path = os.path.join(PYTHON_LIBRARY, 'requirements.json')
            (last_updated, last_hash, metadata_mod, metadata,) = (
                0, '', False, {}
            )
            if os.path.exists(metadata_path):
                with open(metadata_path, 'rb') as f:
                    metadata = json.load(f, encoding='utf-8')
                last_updated = metadata.get('updated', 0)
                last_hash = metadata.get('hash', '')

            req_mtime = os.stat(self.reqpath).st_mtime
            if req_mtime > last_updated:
                metadata['updated'] = req_mtime
                metadata_mod = True

                md5hash = hashlib.md5()
                with open(self.reqpath, 'rb') as f:
                    md5hash.update(f.read())
                digest = md5hash.hexdigest()
                if digest != last_hash and \
                        len(open(self.reqpath, 'rb').read()) > 0:
                    metadata['hash'] = digest
                    self.outer.notify(
                        'Installing Workflow Dependencies',
                        'Your workflow will run momentarily'
                    )
                    self._pip_path()
                    import pip
                    pip.main([
                        'install', '--upgrade', '--requirement',
                        self.reqpath, '--target',
                        PYTHON_LIBRARY
                    ])
            if metadata_mod:
                with open(metadata_path, 'wb') as _file:
                    json.dump(metadata, _file, encoding='utf-8', indent=2)
            sys.path.insert(0, PYTHON_LIBRARY)

        def _install_pip(self):
            """ Retrieve ``get-pip.py`` script and install ``pip`` in ``PYTHON_LIBRARY``.

            """
            ignore = False
            installer = os.path.join(PYTHON_LIBRARY, 'get-pip.py')

            if os.path.exists(os.path.join(PYTHON_LIBRARY, 'pip')):
                ignore = True

            updated = self.outer._download_update(
                GET_PIP, installer, ignore_missing=ignore
            )

            if updated:
                if not os.path.exists(installer):
                    BUNDLER_LOGGER.error(
                        'Error retrieving pip installer from `{}`'.format(
                            GET_PIP
                        )
                    )
                    return False
                for i in os.listdir(PYTHON_LIBRARY):
                    if i.startswith('pip'):
                        if os.path.isdir(os.path.join(PYTHON_LIBRARY, i)):
                            shutil.rmtree(os.path.join(PYTHON_LIBRARY, i))
                BUNDLER_LOGGER.info(
                    'running pip installer `{}` ...'.format(installer)
                )
                subprocess.check_output([
                    '/usr/bin/python', installer, '--target', PYTHON_LIBRARY
                ])

            if not os.path.exists(os.path.join(PYTHON_LIBRARY, 'pip')):
                BUNDLER_LOGGER.error('pip installation failed')
                return False

            if os.path.exists(installer):
                os.unlink(installer)

        def _pip_path(self):
            """ Install ``pip`` if necessary and add its directory to ``sys.path``.

            """
            if not os.path.exists(os.path.join(PYTHON_LIBRARY, 'pip')):
                self._install_pip()
            if PYTHON_LIBRARY not in sys.path:
                BUNDLER_LOGGER.info(
                    'inserting `{}` to system path '.format(PYTHON_LIBRARY)
                )
                sys.path.insert(0, PYTHON_LIBRARY)
