#!/usr/bin/env python
# encoding: utf-8

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

BUNDLER_ID = 'alfredbundler.default'
BUNDLER_DIRECTORY = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{}'
)
BUNDLER_LOGFILE = 'data/logs/bundler-{}.log'
BUNDLER_LOGGER = None
BUNDLER_UPDATER = os.path.join(
    BUNDLER_DIRECTORY, 'bundler', 'meta', 'update-wrapper.sh'
)
CACHE_DIRECTORY = os.path.expanduser(
    '~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'
    'alfred.bundler-{}'
)
PREFERENCES_PLIST = os.path.expanduser(
    '~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist'
)
SYSTEM_ICONS = (
    '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/'
    '{name}.icns'
)

UPDATE_JSON = os.path.join(
    BUNDLER_DIRECTORY, 'data', 'assets', 'python', BUNDLER_ID, 'update.json'
)
HTTP_TIMEOUT = 5
UPDATE_INTERVAL = 604800
GET_PIP = (
    'https://raw.githubusercontent.com/pypa/pip/develop/contrib/get-pip.py'
)
CWD = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
PYTHON_LIBRARY = os.path.join(
    BUNDLER_DIRECTORY, 'data', 'assets', 'python', BUNDLER_ID
)


class Metadata(object):

    def __init__(self, filepath):
        self._filepath = filepath
        self._etags = {}
        self._last_updated = 0
        if os.path.exists(self._filepath):
            self._load()

    def _load(self):
        with open(self._filepath, 'rb') as _file:
            _data = json.load(_file, encoding='utf-8')
        self._etags = _data.get('etags', {})
        self._last_updated = _data.get('last_updated', 0)

    def _save(self):
        _data = dict(etags=self._etags, last_updated=self._last_updated)
        if not os.path.exists(os.path.dirname(self._filepath)):
            os.makedirs(os.path.dirname(self._filepath), 0775)
        with open(self._filepath, 'wb') as _file:
            json.dump(_data, _file, sort_keys=True, indent=2, encoding='utf-8')

    def _set_etag(self, url, etag):
        self._etags[url] = etag
        self._save()

    def _get_etag(self, url):
        return self._etags.get(url, None)

    def _set_updated(self):
        self._last_updated = time.time()
        self._save()

    def _get_updated(self):
        return self._last_updated

    def _wants_update(self):
        return (time.time() - self._last_updated) > UPDATE_INTERVAL


class Cached(object):

    def __init__(self, function):
        self.function = function
        self._cachepath = os.path.join(
            os.path.dirname(CWD), 'data', 'assets', 'python', BUNDLER_ID,
            '{}.{}.cache'.format(__name__, self.function.__name__)
        )
        self.cache = {}
        if os.path.exists(self._cachepath):
            with open(self._cachepath, 'rb') as _file:
                self.cache = cPickle.load(_file)

    def __call__(self, *args, **kwargs):
        key = (args, frozenset(kwargs.items()))
        _path = self.cache.get(key, None)
        if _path is None or not os.path.exists(_path):
            _path = self.function(*args, **kwargs)
            self.cache[key] = _path
            _dirpath = os.path.dirname(self._cachepath)
            if not os.path.exists(_dirpath):
                os.makedirs(_dirpath, 0775)
            with open(self._cachepath, 'wb') as _file:
                cPickle.dump(self.cache, _file, protocol=2)
        return _path

    def __repr__(self):
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
        _start_path = os.path.split(start_path)[0]
        return _lookback(
            filename, start_path=_start_path, end_path=end_path
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
        _response = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)
    except urllib2.HTTPError:
        BUNDLER_LOGGER.error('`{}` could not be found'.format(url))
        return False

    if _response.getcode() != 200:
        BUNDLER_LOGGER.error('error connecting to `{}`'.format(url))
        return False

    if not os.path.exists(os.path.dirname(save_path)):
        os.makedirs(os.path.dirname(save_path), 0775)
    with open(save_path, 'wb') as _file:
        BUNDLER_LOGGER.info('downloading to `{}` ...'.format(save_path))
        _file.write(_response.read())
    return True


def _run_subprocess(process):
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


@Cached
def _utility(name, version='latest', json_path=None, workflow_id=None):
        json_path = json_path or ''
        _utility = _run_subprocess([
            '/bin/bash', os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'bundlets', 'alfred.bundler.sh'
            ), 'utility', name, version, json_path
        ])
        if workflow_id:
            _register_asset(name, version, workflow_id=workflow_id)
        return _utility.split('\n')[0]


def _register_asset(asset, version, workflow_id=None):
    if not workflow_id:
        # TODO: log error
        return False
    _registry_path = os.path.join(
        BUNDLER_DIRECTORY, 'data', 'registry.json'
    )
    _registry = {}
    _update = False
    if os.path.exists(_registry_path):
        _registry = json.loads(open(_registry_path, 'rb').read())
    else:
        json.dump(_registry, open(_registry_path, 'wb'))
    if asset in _registry.keys():
        if version not in _registry[asset].keys():
            _registry[asset][version] = []
            _update = True
        if workflow_id not in _registry[asset][version]:
            _registry[asset][version].append(workflow_id)
            _update = True
    else:
        _registry[asset] = {version: [workflow_id]}
        _update = True
    if _update:
        json.dump(_registry, open(_registry_path, 'wb'))
    return True


# TODO: Make sure the modern and deprecated setups are built on both bundlers
class Main:

    def __init__(self, calling_path):

        global BUNDLER_DIRECTORY, CACHE_DIRECTORY, BUNDLER_LOGFILE
        global BUNDLER_UPDATER, UPDATE_JSON, PYTHON_LIBRARY, BUNDLER_LOGGER

        self._called = calling_path
        self.major_version = os.getenv('AB_BRANCH')
        if not self.major_version:
            self.major_version = open(
                os.path.join(CWD, 'meta', 'version_major')
            ).readline()
        # TODO: Make sure minor version is correctly formatted
        self.minor_version = open(
            os.path.join(CWD, 'meta', 'version_minor')
        ).readline()

        BUNDLER_DIRECTORY = BUNDLER_DIRECTORY.format(self.major_version)
        BUNDLER_UPDATER = BUNDLER_UPDATER.format(self.major_version)
        UPDATE_JSON = UPDATE_JSON.format(self.major_version)
        CACHE_DIRECTORY = CACHE_DIRECTORY.format(self.major_version)
        PYTHON_LIBRARY = PYTHON_LIBRARY.format(self.major_version)
        BUNDLER_LOGFILE = os.path.join(
            BUNDLER_DIRECTORY, BUNDLER_LOGFILE.format(self.major_version)
        )
        BUNDLER_LOGGER = self.logger(self.__class__.__name__, BUNDLER_LOGFILE)

        self.workflow_id = None
        self.workflow_name = None
        self.workflow_data = None
        self.workflow_log = None

        if os.getenv('alfred_version'):
            self.workflow_id = os.getenv('alfred_workflow_bundleid')
            self.workflow_name = os.getenv('alfred_workflow_name')
            self.workflow_data = os.getenv('alfred_workflow_data')
        else:
            _info_plist = _lookback(
                'info.plist',
                start_path=self._called, end_path=os.path.dirname(self._called)
            )
            if _info_plist:
                _info_plist = plistlib.readPlist(_info_plist)
                self.workflow_id = _info_plist['bundleid']
                self.workflow_name = _info_plist['name']
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
        self.log = self.logger(
            self.workflow_name,
            os.path.join(
                self.workflow_data, 'logs',
                '{}.log'.format(self.workflow_id)
            )
        )

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

        self.wrappers = None
        (_file, _name, _data) = imp.find_module(
            'wrappers', [
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'includes',
                    'wrappers', 'python'
                )
            ]
        )
        self.wrappers = imp.load_module('wrappers', _file, _name, _data)
        self._running_update = False
        self.metadata = Metadata(UPDATE_JSON)
        self.requirements = self.AlfredBundlerRequirements(
            _lookback(
                'requirements', start_path=self._called,
                end_path=os.path.dirname(self._called)
            )
        )
        self.requirements._handle_requirements()

    def _update(self):
        if self._running_update:
            return
        if not self.metadata._wants_update():
            return
        self._running_update = True
        try:
            self.notify(
                'Updating Workflow Libraries',
                'Your workflow will continue momentarily'
            )
            _proc = subprocess.Popen(['/bin/bash', BUNDLER_UPDATER])
            self.requirements._install_pip()
            _retcode = _proc.wait()
            if _retcode:
                BUNDLER_LOGGER.error(
                    'error updating bundler `{}`'.format(_retcode)
                )
            self.metadata._set_updated()
        finally:
            self._running_update = False

    def _download_update(self, url, filepath, ignore_missing=False):
        _prev_etag = self.metadata._get_etag(url)
        BUNDLER_LOGGER.info('retrieving `{}` ...'.format(url))
        _resp = urllib2.urlopen(url, timeout=HTTP_TIMEOUT)
        if _resp.getcode() != 200:
            raise IOError(
                2, 'Error retrieving url. Server returned {}'.format(
                    _resp.getcode()
                ), url
            )
        _curr_etag = _resp.info().get('Etag')
        force = not os.path.exists(filepath) and not ignore_missing
        if _curr_etag != _prev_etag or force:
            with open(filepath, 'wb') as _file:
                BUNDLER_LOGGER.info('saving to `{}` ...'.format(filepath))
                _file.write(_resp.read())
            self.metadata._set_etag(url, _curr_etag)
            return True
        return False

    def logger(self, name, log_path=None):

        if not log_path:
            log_path = os.path.join(
                os.path.split(BUNDLER_DIRECTORY)[0],
                self.workflow_id, 'logs',
                '{}.log'.format(self.workflow_id)
            )
        log_dir = os.path.dirname(log_path)
        if not os.path.exists(log_dir):
            os.makedirs(log_dir, 0755)

        _logger = logging.getLogger(name)
        if not _logger.handlers:
            _logfile = logging.handlers.RotatingFileHandler(
                log_path, maxBytes=(1024 * 1024), backupCount=1
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
            _logger.addHandler(_logfile)
            _logger.addHandler(_console)

        _logger.setLevel(logging.DEBUG)
        return _logger

    def notify(self, title, message, icon=None):
        """ Send a notification to the desktop.
        Note: wrappers must be on the system for this method to work.

        :param title: Title of notification
        :type title: ``str`` or ``unicode``
        :param message: Message of notification
        :type message: ``str`` or ``unicode``
        :param icon: Absolute path to icon for notification
        :type icon: ``str`` or ``unicode``
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
        return self.AlfredBundlerIcon(
            font, icon, color=color, alter=alter
        ).icon

    def icns(self):
        _info_plist = _lookback(
            'info.plist',
            start_path=self._called, end_path=os.path.dirname(self._called)
        )
        if not os.path.exists(os.path.join(
            os.path.dirname(_info_plist), 'icon.png'
        )):
            BUNDLER_LOGGER.error((
                'cannot convert to icns, '
                'icon.png does not exist in `{}`'
            ).format(os.path.dirname(_info_plist)))
            return False
        _cache_icon = os.path.join(
            CACHE_DIRECTORY, 'icns', '{}.icns'.format(self.workflow_id)
        )
        if os.path.exists(_cache_icon):
            return os.path.join(
                CACHE_DIRECTORY, 'icns', '{}.icns'.format(self.workflow_id)
            )
        else:
            if not os.path.exists(os.path.dirname(_cache_icon)):
                os.makedirs(os.path.dirname(_cache_icon), 0775)
            _run_subprocess([
                '/bin/bash',
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'includes', 'png_to_icns.sh'
                ),
                os.path.join(os.path.dirname(_info_plist), 'icon.png'),
                _cache_icon
            ])
            if os.path.exists(_cache_icon):
                return _cache_icon
            else:
                BUNDLER_LOGGER.error(
                    'could not convert `icon.png` to .icns , unknown reason'
                )
                return False

    def wrapper(self, wrapper, debug=False):
        return self.wrappers.wrapper(
            wrapper.lower(), debug=debug, workflow_id=self.workflow_id
        )

    def utility(self, name, version='latest', json_path=None):
        _retn = _utility(name, version, json_path=json_path)
        self.register_asset(name, version)
        return _retn

    def register_asset(self, asset, version, workflow_id=None):
        if not workflow_id:
            workflow_id = self.workflow_id
        return _register_asset(asset, version, workflow_id=self.workflow_id)

    @NestedAccess
    class AlfredBundlerIcon:

        def __init__(self, font, name, color='000000', alter=False):
            (self.font, self.name, self.color, self.alter,) = (
                font, name, color, alter
            )
            self.cache = os.path.join(CACHE_DIRECTORY, 'color')
            self.background = None
            self.fallback = os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'meta', 'icons', 'default.png'
            )
            if not os.path.exists(os.path.join(BUNDLER_DIRECTORY, 'data')):
                os.makedirs(os.path.join(BUNDLER_DIRECTORY, 'data'), 0775)
            if not os.path.exists(self.cache):
                os.makedirs(self.cache, 0775)
            self._set_background()

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

            self.icon = None
            if self.font.lower() == 'system':
                self.icon = self.system_icon(self.name)
            else:
                _icon = os.path.join(
                    BUNDLER_DIRECTORY, 'data', 'assets', 'icons',
                    self.font, self.color, self.name
                )
                if os.path.exists('{}.png'.format(_icon)):
                    self.icon = '{}.png'.format(_icon)
                else:
                    self.icon = self.retrieve_icon(
                        self.font, self.color, self.name
                    )
            if not os.path.exists(self.icon):
                self.icon = self.fallback

        def __repr__(self):
            return (
                '{}(\n  font=`{}`\n  name=`{}`\n  '
                'color=`{}`\n  icon=`{}`\n)'
            ).format(
                self.__class__.__name__, self.font, self.name,
                self.color, self.icon
            )

        def _set_background(self):
            if os.getenv('alfred_version'):
                _pattern = re.match(
                    r'rgba\((\d+),(\d+),(\d+),([0-9.]+)\)',
                    os.getenv('alfred_theme_background')
                )
                self.background = 'dark' if (
                    self.luminance(*_pattern.groups()[0:-1]) < 140
                ) else 'light'
            else:
                _cache = os.path.join(
                    CACHE_DIRECTORY, 'misc', 'theme_background'
                )
                if not os.path.exists(os.path.dirname(_cache)):
                    os.makedirs(os.path.dirname(_cache), 0775)
                if os.path.exists(_cache) and (
                    os.stat(_cache).st_mtime >
                    os.stat(PREFERENCES_PLIST).st_mtime
                ):
                    self.background = open(_cache, 'rb').read()
                    return True
                self.background = _run_subprocess([
                    '/bin/bash',
                    os.path.join(
                        BUNDLER_DIRECTORY, 'bundler', 'includes', 'LightOrDark'
                    )
                ])
                with open(_cache, 'wb') as _file:
                    _file.write(self.background)

        def _normalize_hex(self, hex_color):
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

            def _normalize(i):
                return int(max(0, min(round(int(i)), 255)))

            return '{:02x}{:02x}{:02x}'.format(
                _normalize(r), _normalize(g), _normalize(b)
            )

        def hex_to_rgb(self, hex_color):
            _color = self._normalize_hex(hex_color)
            (r, g, b,) = (
                int(_color[:2], 16),
                int(_color[2:4], 16),
                int(_color[4:6], 16),
            )
            return (r, g, b,)

        def rgb_to_hsv(self, r, g, b):
            (r, g, b,) = map(lambda i: i / 255.0, (r, g, b,))
            return colorsys.rgb_to_hsv(r, g, b)

        def hsv_to_rgb(self, h, s, v):
            return tuple(map(
                lambda i: int(round(i * 255.0)),
                colorsys.hsv_to_rgb(h, s, v)
            ))

        def luminance(self, r, g, b):
            return sum([
                (299 * int(r)) + (587 * int(g)) + (114 * int(b))
            ]) / 1000.0

        def altered(self, r, g, b):
            (h, s, v,) = self.rgb_to_hsv(r, g, b)
            v = 1 - v
            return self.hsv_to_rgb(h, s, v)

        def system_icon(self, icon_name):
            _icon = SYSTEM_ICONS.format(name=icon_name)
            if os.path.exists(_icon):
                return _icon
            BUNDLER_LOGGER.warning(
                'system icon `{}` could not be found, passing default'.format(
                    icon_name.lower()
                )
            )
            return os.path.join(
                BUNDLER_DIRECTORY, 'bundler', 'meta', 'icons', 'default.icns'
            )

        def retrieve_icon(self, font, color, name):
            _save_dir = os.path.join(
                BUNDLER_DIRECTORY, 'data', 'assets', 'icons', font, color
            )
            if not os.path.exists(_save_dir):
                os.makedirs(_save_dir, 0775)
            _icon = os.path.join(_save_dir, '{}.png'.format(name))
            _sub_url = 'icon/{font}/{color}/{name}'.format(
                font=font, color=color, name=name
            )
            for i in open(
                os.path.join(
                    BUNDLER_DIRECTORY, 'bundler', 'meta', 'icon_servers'
                )
            ).read().split('\n')[:-1]:
                if _download('{}/{}'.format(i, _sub_url), _icon):
                    break
            return _icon

    @NestedAccess
    class AlfredBundlerRequirements:

        def __init__(self, reqpath=None):
            self.reqpath = reqpath or os.path.join(
                self.outer._called, 'requirements'
            )
            if not self.reqpath or not os.path.exists(self.reqpath):
                BUNDLER_LOGGER.info(
                    'generating `requirements` at `{}`'.format(self.reqpath)
                )
                with open(self.reqpath, 'wb') as _file:
                    _file.close()

        def _handle_requirements(self):
            self.outer._update()
            _metadata_path = os.path.join(PYTHON_LIBRARY, 'requirements.json')
            (_last_updated, _last_hash, _metadata_changed, _metadata,) = (
                0, '', False, {}
            )
            if os.path.exists(_metadata_path):
                with open(_metadata_path, 'rb') as _file:
                    _metadata = json.load(_file, encoding='utf-8')
                _last_updated = _metadata.get('updated', 0)
                _last_hash = _metadata.get('hash', '')

            _req_mtime = os.stat(self.reqpath).st_mtime
            if _req_mtime > _last_updated:
                _metadata['updated'] = _req_mtime
                _metadata_changed = True

                md5hash = hashlib.md5()
                with open(self.reqpath, 'rb') as _file:
                    md5hash.update(_file.read())
                _digest = md5hash.hexdigest()
                if _digest != _last_hash and \
                        len(open(self.reqpath, 'rb').read()) > 0:
                    _metadata['hash'] = _digest
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
            if _metadata_changed:
                with open(_metadata_path, 'wb') as _file:
                    json.dump(_metadata, _file, encoding='utf-8', indent=2)
            sys.path.insert(0, PYTHON_LIBRARY)

        def _install_pip(self):
            _ignore = False
            _installer = os.path.join(PYTHON_LIBRARY, 'get-pip.py')

            if os.path.exists(os.path.join(PYTHON_LIBRARY, 'pip')):
                _ignore = True

            _updated = self.outer._download_update(
                GET_PIP, _installer, ignore_missing=_ignore
            )

            if _updated:
                if not os.path.exists(_installer):
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
                    'running pip installer `{}` ...'.format(_installer)
                )
                subprocess.check_output([
                    '/usr/bin/python', _installer, '--target', PYTHON_LIBRARY
                ])

            if not os.path.exists(os.path.join(PYTHON_LIBRARY, 'pip')):
                BUNDLER_LOGGER.error('pip installation failed')
                return False

            if os.path.exists(_installer):
                os.unlink(_installer)

        def _pip_path(self):
            if not os.path.exists(os.path.join(PYTHON_LIBRARY, 'pip')):
                self._install_pip()
            if PYTHON_LIBRARY not in sys.path:
                BUNDLER_LOGGER.info(
                    'inserting `{}` to system path '.format(PYTHON_LIBRARY)
                )
                sys.path.insert(0, PYTHON_LIBRARY)
