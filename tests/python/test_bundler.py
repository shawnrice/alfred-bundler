#!/usr/bin/python
# encoding: utf-8
#
# Copyright © 2014 deanishe@deanishe.net
#
# MIT Licence. See http://opensource.org/licenses/MIT
#
# Created on 2014-08-09
#

"""
"""

from __future__ import print_function, unicode_literals

import sys
import os
import random
import shutil
import tempfile
import logging
import cPickle
import unittest
import time
import urllib2

bundler_dir = os.path.join(os.path.dirname(os.path.dirname(
                           os.path.abspath(os.path.dirname(__file__)))),
                           'bundler')

# sys.path.insert(0, bundler_dir)

from pybundler import AlfredBundler


VERSION_FILE = os.path.join(bundler_dir, 'meta', 'version_major')

if os.getenv('AB_BRANCH'):
    BUNDLER_VERSION = os.getenv('AB_BRANCH')
else:
    BUNDLER_VERSION = open(VERSION_FILE).read().strip()

BUNDLER_ID = 'net.deanishe.alfred-bundler-python'
BUNDLER_DIR = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/'
    'alfred.bundler-{}'.format(BUNDLER_VERSION))
DATA_DIR = os.path.join(BUNDLER_DIR, 'data')
ICON_CACHE = os.path.join(DATA_DIR, 'assets', 'icons')
COLOUR_CACHE = os.path.join(DATA_DIR, 'color-cache')
PYTHON_LIB_DIR = os.path.join(DATA_DIR, 'assets', 'python')
HELPER_DIR = os.path.join(PYTHON_LIB_DIR, BUNDLER_ID)
UPDATE_JSON_PATH = os.path.join(HELPER_DIR, 'update.json')
BACKGROUND_COLOUR_FILE = os.path.join(DATA_DIR, 'theme_background')
ALFRED_PREFS_PATH = os.path.expanduser(
    '~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist')
PIP_INSTALLER_URL = ('https://raw.githubusercontent.com/pypa/pip/'
                     'develop/contrib/get-pip.py')
REQUIREMENTS_TXT = os.path.join(os.path.dirname(__file__), 'requirements.txt')

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(filename)s:%(lineno)s '
                           '%(levelname)-8s %(message)s',
                    datefmt='%H:%M:%S')

log = logging.getLogger('tests')

log.debug('Bundler version : {}'.format(BUNDLER_VERSION))


def setUp():
    pass


def tearDown():
    pass


def random_color():
    size = random.choice((3, 6))
    color = []
    for i in range(size):
        color.append(random.choice('0123456789abcdef'))
    return ''.join(color)


@AlfredBundler.cached
def memoization_test(value):
    return value


class MemoizationTests(unittest.TestCase):

    def setUp(self):
        self.cachepath = os.path.join(
            HELPER_DIR,
            'pybundler.AlfredBundler.memoization_test.cache')
        self.cachepath2 = os.path.join(
            HELPER_DIR,
            'pybundler.AlfredBundler.memoization_test2.cache')
        if os.path.exists(self.cachepath):
            os.unlink(self.cachepath)
        if os.path.exists(self.cachepath2):
            os.unlink(self.cachepath2)

    def tearDown(self):
        if os.path.exists(self.cachepath):
            os.unlink(self.cachepath)
        # if os.path.exists(self.cachepath2):
        #     os.unlink(self.cachepath2)

    def test_cache_created(self):
        """Memoization cache created"""
        self.assertFalse(os.path.exists(self.cachepath))
        self.assertEqual(memoization_test('test'), 'test')
        self.assertTrue(os.path.exists(self.cachepath))
        self.assertEqual(memoization_test('test'), 'test')

    def test_cache_loaded(self):
        """Memoization cache loaded"""

        with open(self.cachepath2, 'wb') as file:
            cPickle.dump({}, file, protocol=2)

        @AlfredBundler.cached
        def memoization_test2(value):
            """test"""
            return value

        self.assertEqual(memoization_test2('test'), 'test')
        self.assertTrue(os.path.exists(self.cachepath2))

        self.assertEqual(repr(memoization_test2), 'test')


class MetadataTests(unittest.TestCase):

    def setUp(self):
        if os.path.exists(UPDATE_JSON_PATH):
            os.unlink(UPDATE_JSON_PATH)

    def tearDown(self):
        if os.path.exists(UPDATE_JSON_PATH):
            os.unlink(UPDATE_JSON_PATH)

    def test_creation(self):
        """Metadata file created"""
        AlfredBundler.metadata.save()
        self.assertTrue(os.path.exists(UPDATE_JSON_PATH))

    def test_saving(self):
        """Update saved"""
        AlfredBundler.metadata.set_updated()
        m2 = AlfredBundler.Metadata(UPDATE_JSON_PATH)
        self.assertEqual(AlfredBundler.metadata.get_updated(), m2.get_updated())

    def test_etags(self):
        """Etags saved"""
        url = 'http://www.example.com'
        etag = 'nG8zqCNMWn1uPgLYl6qQiD'

        AlfredBundler.metadata.set_etag(url, etag)
        self.assertEqual(AlfredBundler.metadata.get_etag(url), etag)

        m2 = AlfredBundler.Metadata(UPDATE_JSON_PATH)
        self.assertEqual(m2.get_etag(url), etag)

    def test_missing_etag(self):
        """Missing Etag"""
        self.assertIsNone(AlfredBundler.metadata.get_etag('http://www.example.com/'))

    def test_update(self):
        """Wants update"""
        AlfredBundler.metadata.set_updated()
        self.assertFalse(AlfredBundler.metadata.wants_update())
        AlfredBundler.metadata._last_updated = 0
        self.assertTrue(AlfredBundler.metadata.wants_update())

    def test_makedir(self):
        """Create metadata dir"""
        dirpath = os.path.dirname(UPDATE_JSON_PATH)
        if os.path.exists(dirpath):
            shutil.rmtree(dirpath)
        m2 = AlfredBundler.Metadata(UPDATE_JSON_PATH)
        m2.set_updated()
        self.assertTrue(os.path.exists(dirpath))


class HelperTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_find_file(self):
        """Find file"""
        # Non-existent file
        with self.assertRaises(IOError):
            AlfredBundler._find_file('JX63OkRLRgcxUZ8ZAJQTaUksQPuGHUGt')
        # Existing file
        path = AlfredBundler._find_file('info.plist')
        self.assertEqual(os.path.abspath(path), os.path.abspath('info.plist'))

    def test_bundle_id(self):
        """Bundle ID"""
        bid = AlfredBundler._bundle_id()
        self.assertEqual(bid, 'net.deanishe.alfred-bundler-python-test')
        # Call again to test against cached value
        self.assertEqual(AlfredBundler._bundle_id(),
                         'net.deanishe.alfred-bundler-python-test')


class ColourTests(unittest.TestCase):

    def setUp(self):
        os.environ['alfred_theme_background'] = 'rgba(255,255,255,1.00)'

    def tearDown(self):
        if 'alfred_theme_background' in os.environ:
            del os.environ['alfred_theme_background']

    def test_convert_color(self):
        """Convert colour"""
        color = 'fff'
        rgb = AlfredBundler.hex_to_rgb(color)
        hsv = AlfredBundler.rgb_to_hsv(*rgb)
        self.assertEqual(rgb, (255, 255, 255))
        self.assertEqual(hsv, (0.0, 0.0, 1.0))

        # Round-trip hex
        self.assertEqual('ffffff', AlfredBundler.rgb_to_hex(
                         *AlfredBundler.hsv_to_rgb(
                         *AlfredBundler.rgb_to_hsv(
                         *AlfredBundler.hex_to_rgb('fff')))))

    def test_normalize_color(self):
        """Normalize colour"""
        pairs = [
            ('fff', 'ffffff'),
            ('FFF', 'ffffff'),
            ('FFFFFF', 'ffffff'),
            ('01d', '0011dd'),
            ('DE1F4A', 'de1f4a'),
        ]
        for color, expected in pairs:
            self.assertEqual(AlfredBundler.normalize_hex_color(color), expected)

        bad_colors = ['dave', 'dd', 'ddddddd', 'fffffg', 'PANTS!']
        for color in bad_colors:
            with self.assertRaises(ValueError):
                AlfredBundler.normalize_hex_color(color)

    def test_flip_color(self):
        """Flip colour"""
        self.assertEqual(AlfredBundler.flip_color('000000'), 'ffffff')
        self.assertEqual(AlfredBundler.flip_color('ffffff'), '000000')

        if os.path.exists(COLOUR_CACHE):
            shutil.rmtree(COLOUR_CACHE)

        self.assertEqual(AlfredBundler.flip_color('000000'), 'ffffff')
        self.assertEqual(AlfredBundler.flip_color('ffffff'), '000000')

    def test_rgba_colors(self):
        """RGBA colours"""
        pairs = [
            ('rgba(255,255,255,1.0)', (255, 255, 255)),
            ('rgba(0,0,0,1.0)', (0, 0, 0)),
        ]

        for rgba, expected in pairs:
            self.assertEqual(expected, AlfredBundler.rgba_to_rgb(rgba))

        with self.assertRaises(ValueError):
            AlfredBundler.rgba_to_rgb('panties')

    def test_background(self):
        """Theme background"""
        # Test against `alfred_theme_background` set in
        # `setUp()`
        self.assertTrue(AlfredBundler.background_is_light())
        self.assertFalse(AlfredBundler.background_is_dark())

        # Change background to black
        os.environ['alfred_theme_background'] = 'rgba(0,0,0,1.0)'

        self.assertTrue(AlfredBundler.background_is_dark())
        self.assertFalse(AlfredBundler.background_is_light())

        # Test fallback background value from file
        del os.environ['alfred_theme_background']

        with open(BACKGROUND_COLOUR_FILE, 'wb') as file:
            file.write('light')

        self.assertTrue(AlfredBundler.background_is_light())
        self.assertFalse(AlfredBundler.background_is_dark())

        with open(BACKGROUND_COLOUR_FILE, 'wb') as file:
            file.write('dark')

        self.assertTrue(AlfredBundler.background_is_dark())
        self.assertFalse(AlfredBundler.background_is_light())

    def test_dark_light_colors(self):
        """Dark and light colours"""
        black = '000'
        white = 'fff'
        self.assertTrue(AlfredBundler.color_is_dark(black))
        self.assertFalse(AlfredBundler.color_is_light(black))

        self.assertTrue(AlfredBundler.color_is_light(white))
        self.assertFalse(AlfredBundler.color_is_dark(white))


class BundlerTests(unittest.TestCase):

    def setUp(self):
        os.environ['alfred_theme_background'] = 'rgba(255,255,255,1.00)'
        self.tempdir = tempfile.mkdtemp()
        self.tempfile = os.path.join(self.tempdir,
                                     'test-{}.test'.format(os.getpid()))
        self.testurl = 'https://raw.githubusercontent.com/deanishe/alfred-workflow/master/README.md'
        self.badurl = 'http://eu.httpbin.org/status/201'
        self.install_dir = os.path.join(PYTHON_LIB_DIR, AlfredBundler._bundle_id())
        if os.path.exists(self.install_dir):
            shutil.rmtree(self.install_dir)
        if self.install_dir in sys.path:
            sys.path.remove(self.install_dir)

    def tearDown(self):
        if 'alfred_theme_background' in os.environ:
            del os.environ['alfred_theme_background']
        if os.path.exists(self.tempdir):
            shutil.rmtree(self.tempdir)
        if os.path.exists(self.install_dir):
            shutil.rmtree(self.install_dir)
        if self.install_dir in sys.path:
            sys.path.remove(self.install_dir)

    def test_download(self):
        """Download"""
        # Download a file
        self.assertFalse(os.path.exists(self.tempfile))
        AlfredBundler._download_if_updated(self.testurl, self.tempfile)
        self.assertTrue(os.path.exists(self.tempfile))

        # Do not download unchanged file
        mtime = os.stat(self.tempfile).st_mtime
        AlfredBundler._download_if_updated(self.testurl, self.tempfile)
        self.assertEqual(os.stat(self.tempfile).st_mtime, mtime)

        # Do not download non-existent files if `ignore_missing` is `True`
        os.unlink(self.tempfile)
        AlfredBundler._download_if_updated(self.testurl, self.tempfile,
                                           ignore_missing=True)
        self.assertFalse(os.path.exists(self.tempfile))
        # self.assertTrue(os.path.exists(self.tempfile))

        # Exception raised when trying to download a bad URL
        with self.assertRaises(IOError):
            AlfredBundler._download_if_updated(self.badurl, self.tempfile)

    def test_update(self):
        """Bundler update"""

        # `_update()` exits if `update_running` == `True`
        AlfredBundler.metadata._last_updated = 0
        AlfredBundler.update_running = True
        AlfredBundler._update()
        self.assertEqual(AlfredBundler.metadata.get_updated(), 0)
        AlfredBundler.update_running = False

        # `_update()` exits if recently updated
        now = time.time()
        AlfredBundler.metadata._last_updated = now
        AlfredBundler._update()
        self.assertEqual(AlfredBundler.metadata.get_updated(), now)

        # Run actual update
        AlfredBundler.metadata._last_updated = 0
        AlfredBundler._update()

        # Metadata updated
        self.assertTrue(AlfredBundler.metadata.get_updated() > 0)

        # Update script fails
        script = AlfredBundler.BUNDLER_UPDATE_SCRIPT
        AlfredBundler.BUNDLER_UPDATE_SCRIPT = 'nonexistant-program'
        AlfredBundler.metadata._last_updated = 0
        AlfredBundler._update()

        AlfredBundler.BUNDLER_UPDATE_SCRIPT = script

    def test_install_pip(self):
        """Install pip"""
        pip_path = os.path.join(HELPER_DIR, 'pip')
        installer_path = os.path.join(HELPER_DIR, 'get-pip.py')

        # Ensure pip isn't installed
        if os.path.exists(pip_path):
            shutil.rmtree(pip_path)

        if os.path.exists(UPDATE_JSON_PATH):
            os.unlink(UPDATE_JSON_PATH)

        # Test that updater removes old data
        pip_test_path = os.path.join(HELPER_DIR, 'pip-test')
        os.makedirs(pip_test_path, 0755)

        self.assertFalse(os.path.exists(pip_path))
        self.assertFalse(os.path.exists(installer_path))
        self.assertFalse(os.path.exists(UPDATE_JSON_PATH))

        # Install pip
        AlfredBundler.metadata.set_etag(PIP_INSTALLER_URL, 'blah')
        AlfredBundler._install_pip()
        # Pip installed
        self.assertTrue(os.path.exists(pip_path))
        # Installer was deleted
        self.assertFalse(os.path.exists(installer_path))
        # Metadata saved
        self.assertTrue(os.path.exists(UPDATE_JSON_PATH))

        # # Ensure pip is updated
        # AlfredBundler.metadata.set_etag(PIP_INSTALLER_URL, 'blah')
        # AlfredBundler._install_pip()
        # self.assertTrue(os.path.exists(pip_path))
        # self.assertFalse(os.path.exists(installer_path))
        # self.assertTrue(os.path.exists(UPDATE_JSON_PATH))

        # Old data was removed
        self.assertFalse(os.path.exists(pip_test_path))

    def test_pip_path(self):
        """Pip path"""
        # Delete pip and remove it from `sys.path`
        pip_path = os.path.join(HELPER_DIR, 'pip')
        if os.path.exists(pip_path):
            shutil.rmtree(pip_path)

        if HELPER_DIR in sys.path:
            sys.path.remove(HELPER_DIR)

        # Install pip and add its path to `sys.path`
        AlfredBundler._add_pip_path()
        self.assertTrue(HELPER_DIR in sys.path)

    def test_logger(self):
        """Logger"""
        bid = AlfredBundler._bundle_id()
        logpath = os.path.join(
            os.path.expanduser(
                '~/Library/Application Support/Alfred 2/Workflow Data/'),
            bid, 'logs', '{}.log'.format(bid))
        logdir = os.path.dirname(logpath)

        # Ensure directory is created
        if os.path.exists(logdir):
            shutil.rmtree(logdir)

        l = AlfredBundler.logger('demo')
        l.debug('test message')
        self.assertTrue(os.path.exists(logpath))

    def test_icons(self):
        """Web icons"""
        # 404 for invalid font
        with self.assertRaises(urllib2.HTTPError):
            AlfredBundler.icon('spaff', 'adjust')

        # 404 for invalid character
        with self.assertRaises(urllib2.HTTPError):
            AlfredBundler.icon('fontawesome', 'banditry!')

        # ValueError for invalid colour
        with self.assertRaises(ValueError):
            AlfredBundler.icon('fontawesome', 'adjust', 'hubbahubba')

        # Ensure directories are created, valid icon is downloaded and returned
        path = os.path.join(ICON_CACHE, 'fontawesome', 'ffffff', 'adjust.png')
        dirpath = os.path.dirname(path)
        if os.path.exists(dirpath):
            shutil.rmtree(dirpath)

        icon = AlfredBundler.icon('fontawesome', 'adjust', 'fff')
        self.assertEqual(icon, path)
        self.assertTrue(os.path.exists(path))

        if os.path.exists(path):
            os.unlink(path)

        # Returns correctly altered icon. Here: dark icon on dark background
        # returns light icon instead
        os.environ['alfred_theme_background'] = 'rgba(0,0,0,1.0)'
        path = os.path.join(ICON_CACHE, 'fontawesome', 'ffffff',
                            'ambulance.png')
        icon = AlfredBundler.icon('fontawesome', 'ambulance', '000', True)

        self.assertEqual(icon, path)
        self.assertTrue(os.path.exists(path))

        # Icon is returned from cache
        icon = AlfredBundler.icon('fontawesome', 'ambulance', '000', True)
        self.assertEqual(icon, path)

        if os.path.exists(path):
            os.unlink(path)

    def test_system_icons(self):
        """System icons"""
        icondir = '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources'
        good = ('Accounts', 'AirDrop', 'BookmarkIcon')
        bad = ('WindowLicker', 'Wolpertinger')
        for name in good:
            path = os.path.join(icondir, '{}.icns'.format(name))
            icon = AlfredBundler.icon('system', name)
            self.assertEqual(icon, path)
        for name in bad:
            with self.assertRaises(ValueError):
                AlfredBundler.icon('system', name)

    def test_asset(self):
        """Load asset"""
        path = os.path.join(DATA_DIR, 'assets', 'utility',
                            'Terminal-Notifier', 'latest',
                            'terminal-notifier.app', 'Contents', 'MacOS',
                            'terminal-notifier')
        self.assertEqual(AlfredBundler.utility('Terminal-Notifier', 'latest'), path)
        self.assertEqual(AlfredBundler.asset('Terminal-Notifier', 'latest'), path)
        self.assertEqual(AlfredBundler.utility('Terminal-Notifier'), path)
        self.assertEqual(AlfredBundler.asset('Terminal-Notifier'), path)

    def test_init(self):
        """Install Python libraries"""

        # Ensure library isn't installed
        with self.assertRaises(ImportError):
            import html

        with open(REQUIREMENTS_TXT, 'wb') as file:
            file.write('html==1.15')

        # Install requirements
        AlfredBundler.init(REQUIREMENTS_TXT)

        # Correct version is installed
        import html
        self.assertTrue(html.__version__ == '1.15')
        self.assertTrue(os.path.exists(self.install_dir))

        # Update requirements with newer version
        with open(REQUIREMENTS_TXT, 'wb') as file:
            file.write('html==1.16')

        # Update installed libraries
        AlfredBundler.init(REQUIREMENTS_TXT)
        reload(html)
        self.assertTrue(html.__version__ == '1.16')

        # reset file
        with open(REQUIREMENTS_TXT, 'wb') as file:
            file.write('html==1.15')

if __name__ == '__main__':  # pragma: no cover
    unittest.main()
