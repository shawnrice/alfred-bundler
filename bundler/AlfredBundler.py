#!/usr/bin/env python
# encoding: utf-8
#
# Copyright © 2014 deanishe@deanishe.net
#
# MIT Licence. See http://opensource.org/licenses/MIT
#
# Created on 2014-08-03
#

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

Simply include the ``bundler.py`` file (from the Alfred Bundler's
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

import sys
import os
import re
import subprocess
import plistlib
import json
import hashlib
import cPickle
import urllib2
import time
import shutil
import colorsys
import logging
import logging.handlers


VERSION = '0.2'


BUNDLER_VERSION = 'devel'

if os.getenv('AB_BRANCH'):
    BUNDLER_VERSION = os.getenv('AB_BRANCH')

# How often to check for updates
UPDATE_INTERVAL = 604800  # 1 week

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
# Script that updates the bundler
BUNDLER_UPDATE_SCRIPT = os.path.join(BUNDLER_DIR, 'bundler', 'meta',
                                     'update-wrapper.sh')

# Root directory under which workflow-specific Python libraries are installed
PYTHON_LIB_DIR = os.path.join(DATA_DIR, 'assets', 'python')

# Where helper scripts and metadata are stored
HELPER_DIR = os.path.join(PYTHON_LIB_DIR, BUNDLER_ID)

# Cache results of calls to `utility()`, as `bundler.sh` is pretty slow
# at the moment
UTIL_CACHE_PATH = os.path.join(HELPER_DIR, 'python_utilities.cache')

# Where colour alternatives are cached
COLOUR_CACHE = os.path.join(DATA_DIR, 'color-cache')

# Where icons will be cached
ICON_CACHE = os.path.join(DATA_DIR, 'assets', 'icons')
API_URL = 'http://icons.deanishe.net/icon/{font}/{color}/{icon}'
# Location of OS X icons
SYSTEM_ICON_DIR = ('/System/Library/CoreServices/CoreTypes.bundle'
                   '/Contents/Resources')

# The misc bash bundler bundlet script we will call to get paths to
# utilities and install them if necessary.
HELPER_PATH = os.path.join(BUNDLER_DIR, 'bundler', 'bundlets',
                           'alfred.bundler.misc.sh')

# Path to file storing update metadata (last update check, etc.)
UPDATE_JSON_PATH = os.path.join(HELPER_DIR, 'update.json')

# URL of Pip installer (`get-pip.py`)
PIP_INSTALLER_URL = ('https://raw.githubusercontent.com/pypa/pip/'
                     'develop/contrib/get-pip.py')

# Background colour (`light` or `dark`)
BACKGROUND_COLOUR_FILE = os.path.join(DATA_DIR, 'theme_background')

# Background util to determine whether background is light or dark
# Result is saved to `BACKGROUND_COLOUR_FILE`
BACKGROUND_UTIL = os.path.join(BUNDLER_DIR, 'bundler', 'includes',
                               'LightOrDark')

# Alfred's preferences file
ALFRED_PREFS_PATH = os.path.expanduser(
    '~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist')

# HTTP timeout
HTTP_TIMEOUT = 5

css_colour = re.compile(r'^[abcdef012345678]+$').match

_workflow_bundle_id = None

# These will be set at the bottom of this file
_log = None
metadata = None

# Prevent recursive calling of _update
update_running = False


########################################################################
# Helper classes/functions
########################################################################

class Metadata(object):
    """Store update metadata

    Last update time and Etags are stored in here.

    """

    def __init__(self, filepath):

        self._filepath = filepath
        self._etags = {}
        self._last_updated = 0

        if os.path.exists(self._filepath):
            self._load()

    def _load(self):
        """Load cached settings from JSON file `self._filepath`"""

        with open(self._filepath, 'rb') as file:
            data = json.load(file, encoding='utf-8')

        self._etags = data.get('etags', {})
        self._last_updated = data.get('last_updated', 0)

    def save(self):
        """Save settings to JSON file `self._filepath`"""
        data = dict(etags=self._etags, last_updated=self._last_updated)

        if not os.path.exists(os.path.dirname(self._filepath)):
            os.makedirs(os.path.dirname(self._filepath), 0755)

        with open(self._filepath, 'wb') as file:
            json.dump(data, file, sort_keys=True, indent=2, encoding='utf-8')

    def set_etag(self, url, etag):
        """Save Etag for ``url``

        :param url: URL key for Etag
        :type url: ``unicode`` or ``str``
        :param etag: Etag for URL
        :type etag: ``unicode`` or ``str``

        """

        self._etags[url] = etag
        self.save()

    def get_etag(self, url):
        """Return Etag for ``url`` or ``None``

        :param url: URL to retrieve Etag for
        :type url: ``unicode`` or ``str``
        :returns: Etag or ``None``
        :rtype: ``unicode`` or ``None``

        """

        return self._etags.get(url, None)

    def set_updated(self):
        """Record current time as last updated time"""
        self._last_updated = time.time()
        self.save()

    def get_updated(self):
        """Return last updated time"""
        return self._last_updated

    def wants_update(self):
        """Return ``True`` if update is due, else ``False``"""
        if time.time() - self._last_updated > UPDATE_INTERVAL:
            return True
        return False


class cached(object):

    def __init__(self, func):
        self.func = func
        self.cachepath = os.path.join(HELPER_DIR, '{}.{}.cache'.format(
                                      __name__, func.__name__))
        # self.func = func
        self.cache = {}

        if os.path.exists(self.cachepath):
            with open(self.cachepath, 'rb') as file:
                self.cache = cPickle.load(file)

    def __call__(self, *args, **kwargs):

        key = (args, frozenset(kwargs.items()))

        path = self.cache.get(key, None)

        # If file has disappeared, call function again
        if path is None or not os.path.exists(path):
            # Cache results
            path = self.func(*args, **kwargs)
            self.cache[key] = path
            with open(self.cachepath, 'wb') as file:
                cPickle.dump(self.cache, file, protocol=2)

        return path

    def __repr__(self):
        """Return the function's docstring."""
        return self.func.__doc__

    # def __get__(self, obj, objtype):
    #     """Support instance methods."""
    #     return functools.partial(self.__call__, obj)


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

    global _workflow_bundle_id

    if _workflow_bundle_id is not None:
        return _workflow_bundle_id

    plist = plistlib.readPlist(_find_file('info.plist'))
    _workflow_bundle_id = plist.get('bundleid', None)
    return _workflow_bundle_id


def _notify(title, message):  # pragma: no cover
    """Post a notification"""
    notifier = utility('Terminal-Notifier')

    cmd = [notifier, '-title', title, '-message', message]

    try:
        icon = _find_file('icon.png')
        cmd += ['-contentImage', icon]
    except IOError:
        pass

    subprocess.call(cmd)


#-----------------------------------------------------------------------
# Icon helpers
#-----------------------------------------------------------------------

def normalize_hex_color(color):
    """Convert CSS colour to 6-characters and lowercase

    :param css_colour: CSS colour of form XXX or XXXXXX
    :type css_colour: ``unicode`` or ``str``
    :returns: Normalised CSS colour of form xxxxxx
    :rtype: ``unicode``

    """

    color = color.lower().strip('#')

    if not css_colour(color) or not len(color) in (3, 6):
        raise ValueError('Invalid CSS colour: {}'.format(color))

    if len(color) == 3:  # Expand to 6 characters
        r, g, b = color
        color = '{r}{r}{g}{g}{b}{b}'.format(r=r, g=g, b=b)

    return color


def hex_to_rgb(color):
    """Convert CSS-style colour to ``(r, g, b)``

    :param css_colour: xxx or xxxxxx CSS colour
    :type css_colour: ``unicode`` or ``str``
    :returns: ``(r, g, b)`` tuple of ``ints`` 0-255
    :rtype: ``tuple``

    """

    color = normalize_hex_color(color)
    r = int(color[:2], 16)
    g = int(color[2:4], 16)
    b = int(color[4:6], 16)

    return (r, g, b)


def rgb_to_hex(r, g, b):
    """Return CSS hex representation of colour

    :param r: Red
    :type r: ``int`` 0-255
    :param g: Green
    :type g: ``int`` 0-255
    :param b: Blue
    :type b: ``int`` 0-255
    :returns: 6-character CSS hex
    :rtype: ``unicode``

    """

    def clamp(i):
        return int(max(0, min(i, 255)))

    color = '{:02x}{:02x}{:02x}'.format(clamp(r), clamp(g), clamp(b)).lower()

    return color


def hsv_to_rgb(h, s, v):
    """Convert HSV to RGB (for CSS, i.e. 0-255, not floats)

    :param h: Hue
    :type h: ``float``
    :param s: Saturation
    :type s: ``float``
    :param v: Value
    :type v: ``float``
    :returns: ``(r, g, b)`` tuple, where the values are ints between 0-255
    :rtype: ``tuple``

    """
    return tuple(map(lambda i: int(i * 255), colorsys.hsv_to_rgb(h, s, v)))


def rgb_to_hsv(r, g, b):
    """Convert RGB colour to HSV

    :param r: Red
    :type r: ``int`` 0-255
    :param g: Green
    :type g: ``int`` 0-255
    :param b: Blue
    :type b: ``int`` 0-255
    :returns: ``(h, s, v)`` tuple of floats
    :rtype: ``tuple``
    """

    r, g, b = map(lambda i: i / 255.0, (r, g, b))
    return colorsys.rgb_to_hsv(r, g, b)


def rgba_to_rgb(rgba):
    """Convert RGBA CSS colour to ``(r, g, b)``

    :param rgba: RGBA colour in format ``rgba(r,g,b,a)``
    :type rgba: ``unicode`` or ``str``
    :returns: ``(r, g, b)`` tuple of ``ints``
    :rtype: ``tuple``

    """

    m = re.match(r'rgba\((\d+),(\d+),(\d+),[0-9.]+\)', rgba)

    if not m:
        raise ValueError('Unparseable RGBA colour : {}'.format(rgba))

    return tuple(map(int, m.groups()))


def set_background():  # pragma: no cover
    """Determine whether background is ``light`` or ``dark`` and save the
    value to ``BACKGROUND_COLOUR_FILE``

    """

    do_update = False

    if os.path.exists(BACKGROUND_COLOUR_FILE):
        if (os.stat(ALFRED_PREFS_PATH).st_mtime >
                os.stat(BACKGROUND_COLOUR_FILE).st_mtime):
            _log.debug('Alfred prefs updated')
            do_update = True
    else:
        do_update = True

    if do_update:
        # Determine and save background colour
        if os.path.exists(BACKGROUND_UTIL):
            colour = subprocess.check_output([BACKGROUND_UTIL]).strip()
            with open(BACKGROUND_COLOUR_FILE, 'wb') as file:
                file.write(colour)
            _log.debug('Theme background : {}'.format(colour))


def background_is_dark():
    """Return ``True`` if background is dark, else ``False``"""

    background_colour = os.getenv('alfred_theme_background')

    if background_colour:
        background_colour = rgb_to_hex(*rgba_to_rgb(background_colour))

        if color_is_dark(background_colour):
            _log.debug('Background is dark')
            return True

        else:
            _log.debug('Background is light')
            return False

    set_background()

    with open(BACKGROUND_COLOUR_FILE, 'rb') as file:
        colour = file.read().strip()

    _log.debug('Background is {}'.format(colour))

    if colour == 'dark':
        return True

    return False


def background_is_light():
    """Return ``True`` if background is light, else ``False``"""

    return not background_is_dark()


def color_is_dark(color):
    """Return ``True`` if CSS ``color`` is dark, else ``False``"""

    r, g, b = hex_to_rgb(color)

    value = sum([(r * 299), (g * 587), (b * 114)]) / 1000.0

    if value < 140:
        _log.debug('{} is dark'.format(color))
        return True

    _log.debug('{} is light'.format(color))
    return False


def color_is_light(color):
    """Return ``True`` if CSS ``color`` is light, else ``False``"""

    return not color_is_dark(color)


def flip_color(color):
    """Return lightened/darkened version of CSS ``color``

    :param color: CSS colour of form XXX or XXXXXXX
    :type color: ``unicode`` or ``str``
    :returns: CSS colour
    :rtype: ``unicode``

    """

    color = normalize_hex_color(color)

    cachepath = os.path.join(COLOUR_CACHE, color)

    if os.path.exists(cachepath):
        with open(cachepath, 'rb') as file:
            return file.read().strip()

    h, s, v = rgb_to_hsv(*hex_to_rgb(color))

    v = 1 - v  # flip Value

    flipped = rgb_to_hex(*hsv_to_rgb(h, s, v))

    _log.debug('Altered `{}` to `{}`'.format(color, flipped))

    if not os.path.exists(COLOUR_CACHE):
        os.makedirs(COLOUR_CACHE, 0755)

    with open(cachepath, 'wb') as file:
        file.write(flipped)

    return flipped


#-----------------------------------------------------------------------
# Installation/update functions
#-----------------------------------------------------------------------

def _download_if_updated(url, filepath, ignore_missing=False):
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

    global metadata

    previous_etag = metadata.get_etag(url)

    _log.debug('Opening URL `{}` ...'.format(url))

    response = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)

    _log.debug('[{}] {}'.format(response.getcode(), url))

    if response.getcode() != 200:
        raise IOError(2, 'Error retrieving URL. Server returned {}'.format(
                      response.getcode()), url)

    current_etag = response.info().get('Etag')

    force_download = not os.path.exists(filepath) and not ignore_missing

    if current_etag != previous_etag or force_download:
        with open(filepath, 'wb') as file:
            file.write(response.read())
            _log.info('Saved `{}`'.format(filepath))

        metadata.set_etag(url, current_etag)

        return True

    return False


def _update():
    """Check for periodical updates of bundler and pip"""

    global metadata, update_running

    if update_running:
        return

    if not metadata.wants_update():
        return

    update_running = True

    try:
        _notify('Workflow libraries are being updated',
                'Your workflow will continue momentarily')

        # Call bundler updater
        cmd = ['/bin/bash', BUNDLER_UPDATE_SCRIPT]
        _log.debug('Running command: {} ...'.format(cmd))
        proc = subprocess.Popen(cmd)

        _install_pip()

        # Wait for `update.sh` to complete
        retcode = proc.wait()
        if retcode:
            _log.error('Error updating bundler. `{}` returned {}'.format(
                       BUNDLER_UPDATE_SCRIPT, retcode))

        metadata.set_updated()

    finally:
        update_running = False


def _install_pip():
    """Retrieve ``get-pip.py`` script and install ``pip`` in
    ``PYTHON_LIB_DIR``

    """

    ignore_missing = False
    if os.path.exists(os.path.join(HELPER_DIR, 'pip')):
        ignore_missing = True

    installer_path = os.path.join(HELPER_DIR, 'get-pip.py')
    updated = _download_if_updated(PIP_INSTALLER_URL,
                                   installer_path,
                                   ignore_missing)

    if updated:
        assert os.path.exists(installer_path), \
            'Error retrieving Pip installer from GitHub.'
        # Remove existing pip
        for filename in os.listdir(HELPER_DIR):
            if filename.startswith('pip'):
                p = os.path.join(HELPER_DIR, filename)
                if os.path.isdir(p):
                    shutil.rmtree(p)

        cmd = ['/usr/bin/python', installer_path, '--target', HELPER_DIR]

        _log.debug('Running command: {} ...'.format(cmd))

        subprocess.check_output(cmd)

    assert os.path.exists(os.path.join(HELPER_DIR, 'pip')), \
        'Pip  installation failed'

    if os.path.exists(installer_path):
        os.unlink(installer_path)


def _add_pip_path():
    """Install ``pip`` if necessary and add its directory to ``sys.path``

    :returns: ``None``

    """

    if not os.path.exists(os.path.join(HELPER_DIR, 'pip')):
        # Pip's not installed, let's install it
        _install_pip()

    if HELPER_DIR not in sys.path:
        sys.path.insert(0, HELPER_DIR)


########################################################################
# API functions
########################################################################

def logger(name, logpath=None):
    """Return ``~logging.Logger`` object that logs to ``logpath`` and STDERR.

    :param name: Name of logger
    :type name: ``unicode`` or ``str``
    :param logpath: Path to logfile. If ``None``, a default logfile in the
        workflow's data directory will be used.
    :type logpath: ``unicode`` or ``str``
    :returns: Configured ``~logging.Logger`` object

    """

    if name == 'bundler' and logpath is None:
        logpath = os.path.join(DATA_DIR, 'logs', 'python.log')

    if not logpath:
        logpath = os.path.join(
            os.path.expanduser(
                '~/Library/Application Support/Alfred 2/Workflow Data/'),
            _bundle_id(), 'logs', '{}.log'.format(_bundle_id()))

    logdir = os.path.dirname(logpath)
    if not os.path.exists(logdir):
        os.makedirs(logdir, 0755)

    logger = logging.getLogger(name)

    if not logger.handlers:
        logfile = logging.handlers.RotatingFileHandler(logpath,
                                                       maxBytes=1024*1024,
                                                       backupCount=0)
        console = logging.StreamHandler()
        fmt = logging.Formatter('%(asctime)s %(filename)s:%(lineno)s '
                                '%(levelname)-8s %(message)s',
                                datefmt='%H:%M:%S')

        logfile.setFormatter(fmt)
        console.setFormatter(fmt)
        logger.addHandler(logfile)
        logger.addHandler(console)

    logger.setLevel(logging.DEBUG)
    return logger


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

    if font == 'system':
        path = os.path.join(SYSTEM_ICON_DIR, '{}.icns'.format(icon))
        if not os.path.exists(path):
            raise ValueError('Unknown system icon : {}'.format(icon))

        return path

    # Normalise arguments
    font = font.lower()
    icon = icon.lower()

    color = normalize_hex_color(color)

    # Invert colour if necessary
    if alter:

        if background_is_dark() == color_is_dark(color):  # Both are dark/light
            color = flip_color(color)

    icondir = os.path.join(ICON_CACHE, font, color)
    path = os.path.join(icondir, '{}.png'.format(icon))

    if os.path.exists(path):
        return path

    if not os.path.exists(icondir):
        os.makedirs(icondir, 0755)

    url = API_URL.format(font=font, color=color, icon=icon)
    _log.debug('Retrieving URL `{}` ...'.format(url))

    response = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)

    code = response.getcode()

    _log.debug('[{}] {}'.format(code, url))

    if code > 399:  # pragma: no cover
        error = response.read()
        raise ValueError(error)

    elif code != 200:  # pragma: no cover
        raise IOError('Could not retrieve icon : {}/{}/{{'.format(font,
                                                                  icon,
                                                                  color))

    with open(path, 'wb') as file:
        file.write(response.read())

    return path


@cached
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

    _update()

    # Call bash bundlet with specified arguments
    json_path = json_path or ''
    cmd = ['/bin/bash', HELPER_PATH, 'utility', name, version, json_path]
    path = subprocess.check_output(cmd).strip().decode('utf-8')

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

    _update()

    bundle_id = _bundle_id()
    if not bundle_id:  # pragma: no cover
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

        if h != last_hash:  # requirements.txt has changed, let's install
            # Update metadata
            metadata['hash'] = h

            # Notify user of updates
            _notify('Installing workflow dependencies',
                    'Your worklow will run momentarily')

            # Install dependencies with Pip
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

_log = logger('bundler')
metadata = Metadata(UPDATE_JSON_PATH)
