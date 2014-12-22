#!/usr/bin/python
# encoding: utf-8
#
# Copyright © 2014 The Alfred Bundler Team
# MIT Licence. See http://opensource.org/licenses/MIT

from __future__ import unicode_literals
import sys
import os
import imp
import random
import shutil
import tempfile
import logging
import cPickle
import unittest
import time
import urllib2

import common

if not os.path.exists(common.BUNDLER_PATH):
    bundlet = imp.load_source(
        os.path.splitext(common.BUNDLET)[0],
        common.BUNDLET_PATH
    ).AlfredBundler()

log = logging.getLogger('test.bundler')
log.debug('BUNDLER VERSION : {}'.format(common.MAJOR_VERSION))

AlfredBundlerScript = imp.load_source(
    os.path.splitext(common.BUNDLER)[0],
    common.BUNDLER_PATH
)
AlfredBundler = AlfredBundlerScript.Main(
    os.path.dirname(os.path.abspath(__file__))
)


@AlfredBundlerScript.Cached
def memoization_test(value):
    return value


class MemoizationTests(unittest.TestCase):

    def setUp(self):
        self.cachepath = os.path.join(
            common.HELPER_DIRECTORY,
            'AlfredBundler.memoization_test.cache')
        self.cachepath2 = os.path.join(
            common.HELPER_DIRECTORY,
            'AlfredBundler.memoization_test2.cache')
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
        # raw_input('')
        self.assertTrue(os.path.exists(self.cachepath))
        self.assertEqual(memoization_test('test'), 'test')

    def test_cache_loaded(self):
        """Memoization cache loaded"""

        with open(self.cachepath2, 'wb') as file:
            cPickle.dump({}, file, protocol=2)

        @AlfredBundlerScript.Cached
        def memoization_test2(value):
            """test"""
            return value

        self.assertEqual(memoization_test2('test'), 'test')
        self.assertTrue(os.path.exists(self.cachepath2))

        self.assertEqual(repr(memoization_test2), 'test')


class MetadataTests(unittest.TestCase):

    def setUp(self):
        if os.path.exists(AlfredBundlerScript.UPDATE_JSON):
            os.unlink(AlfredBundlerScript.UPDATE_JSON)

    def tearDown(self):
        if os.path.exists(AlfredBundlerScript.UPDATE_JSON):
            os.unlink(AlfredBundlerScript.UPDATE_JSON)

    def test_creation(self):
        """Metadata file created"""
        AlfredBundler.metadata.save()
        self.assertTrue(os.path.exists(AlfredBundlerScript.UPDATE_JSON))

    def test_saving(self):
        """Update saved"""
        AlfredBundler.metadata.set_updated()
        m2 = AlfredBundlerScript.Metadata(AlfredBundlerScript.UPDATE_JSON)
        self.assertEqual(AlfredBundler.metadata.get_updated(), m2.get_updated())

    def test_etags(self):
        """Etags saved"""
        url = 'http://www.example.com'
        etag = 'nG8zqCNMWn1uPgLYl6qQiD'

        AlfredBundler.metadata.set_etag(url, etag)
        self.assertEqual(AlfredBundler.metadata.get_etag(url), etag)

        m2 = AlfredBundlerScript.Metadata(AlfredBundlerScript.UPDATE_JSON)
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
        dirpath = os.path.dirname(AlfredBundlerScript.UPDATE_JSON)
        if os.path.exists(dirpath):
            shutil.rmtree(dirpath)
        m2 = AlfredBundlerScript.Metadata(AlfredBundlerScript.UPDATE_JSON)
        m2.set_updated()
        self.assertTrue(os.path.exists(dirpath))


class HelperTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_lookback(self):
        """Find file"""
        # Non-existent file
        self.assertEqual(
            AlfredBundlerScript._lookback('JX63OkRLRgcxUZ8ZAJQTaUksQPuGHUGt'),
            None
        )
        # Existing file
        path = AlfredBundlerScript._lookback(
            'info.plist',
            start_path=os.path.dirname(os.path.abspath(__file__)),
        )
        self.assertEqual(os.path.abspath(path), os.path.abspath('info.plist'))


class BundlerTest(unittest.TestCase):

    def setUp(self):
        os.environ['alfred_theme_background'] = 'rgba(255,255,255,1.00)'
        self.tempdir = tempfile.mkdtemp()
        self.tempfile = os.path.join(
            self.tempdir, 'test-{}.test'.format(os.getpid())
        )
        self.testurl = (
            'https://raw.githubusercontent.com/deanishe/alfred-workflow'
            '/master/README.md'
        )
        self.badurl = 'http://eu.httpbin.org/status/201'
        self.install_dir = common.HELPER_DIRECTORY
        if os.path.exists(self.install_dir):
            shutil.rmtree(self.install_dir)
        if self.install_dir in sys.path:
            sys.path.remove(self.install_dir)
        common.HELPER_DIRECTORY = common.HELPER_DIRECTORY.format(
            AlfredBundler.workflow_id
        )

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
        AlfredBundler._download_update(self.testurl, self.tempfile)
        self.assertTrue(os.path.exists(self.tempfile))

        # Do not download unchanged file
        mtime = os.stat(self.tempfile).st_mtime
        AlfredBundler._download_update(self.testurl, self.tempfile)
        self.assertEqual(os.stat(self.tempfile).st_mtime, mtime)

        # Do not download non-existent files if `ignore_missing` is `True`
        os.unlink(self.tempfile)
        AlfredBundler._download_update(
            self.testurl, self.tempfile, ignore_missing=True
        )
        self.assertFalse(os.path.exists(self.tempfile))
        # self.assertTrue(os.path.exists(self.tempfile))

        # Exception raised when trying to download a bad URL
        with self.assertRaises(IOError):
            AlfredBundler._download_update(self.badurl, self.tempfile)

    def test_update(self):
        """Bundler update"""

        # `_update()` exits if `update_running` == `True`
        AlfredBundler.metadata._last_updated = 0
        AlfredBundler.running_update = True
        AlfredBundler._update()
        self.assertEqual(AlfredBundler.metadata.get_updated(), 0)
        AlfredBundler.running_update = False

        # `_update()` exits if recently updated
        now = time.time()
        AlfredBundler.metadata._last_updated = now
        AlfredBundler._update()
        self.assertEqual(AlfredBundler.metadata.get_updated(), now)

        # Run actual update
        AlfredBundler.metadata._last_updated = 0
        AlfredBundler._update()

        # Metadata updated
        self.assertTrue(AlfredBundler.metadata.get_updated() > 0)

        # Update script fails
        script = AlfredBundlerScript.BUNDLER_UPDATER
        AlfredBundlerScript.BUNDLER_UPDATER = 'nonexistant-program'
        AlfredBundler.metadata._last_updated = 0
        AlfredBundler._update()
        AlfredBundlerScript.BUNDLER_UPDATER = script

    def test_install_pip(self):
        """Install pip"""
        pip_path = os.path.join(common.HELPER_DIRECTORY, 'pip')
        log.critical(pip_path)
        installer_path = os.path.join(common.HELPER_DIRECTORY, 'get-pip.py')

        # Ensure pip isn't installed
        if os.path.exists(pip_path):
            shutil.rmtree(pip_path)

        if os.path.exists(AlfredBundlerScript.UPDATE_JSON):
            os.unlink(AlfredBundlerScript.UPDATE_JSON)

        # Test that updater removes old data
        pip_test_path = os.path.join(common.HELPER_DIRECTORY, 'pip-test')
        os.makedirs(pip_test_path, 0775)

        self.assertFalse(os.path.exists(pip_path))
        self.assertFalse(os.path.exists(installer_path))
        self.assertFalse(os.path.exists(AlfredBundlerScript.UPDATE_JSON))

        # Install pip
        AlfredBundler.metadata.set_etag(common.GET_PIP_URL, 'blah')
        AlfredBundler.requirements._install_pip()

        # Pip installed
        self.assertTrue(os.path.exists(pip_path))
        # Installer was deleted
        self.assertFalse(os.path.exists(installer_path))
        # Metadata saved
        self.assertTrue(os.path.exists(AlfredBundlerScript.UPDATE_JSON))

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
        pip_path = os.path.join(common.HELPER_DIRECTORY, 'pip')
        if os.path.exists(pip_path):
            shutil.rmtree(pip_path)
        if common.HELPER_DIRECTORY in sys.path:
            sys.path.remove(common.HELPER_DIRECTORY)

        # Install pip and add its path to `sys.path`
        AlfredBundler.requirements._pip_path()
        self.assertTrue(common.HELPER_DIRECTORY in sys.path)

    def test_logger(self):
        """Logger"""
        logpath = os.path.join(
            os.path.dirname(common.BUNDLER_DIRECTORY),
            AlfredBundler.workflow_id,
            'logs', '{}.log'.format(AlfredBundler.workflow_id)
        )
        # Ensure directory is created
        logdir = os.path.dirname(logpath)
        if os.path.exists(logdir):
            shutil.rmtree(logdir)
        l = AlfredBundler.logger('demo')
        l.debug('testing message ...')
        self.assertTrue(os.path.exists(logpath))

    def test_icons(self):
        """Web icons"""
        # Default.png for invalid font
        self.assertTrue(
            AlfredBundler.icon('spaff', 'adjust') ==
            AlfredBundler.icon('', '')
        )
        # Default.png for invalid font
        self.assertTrue(
            AlfredBundler.icon('fontawesome', 'banditry!') ==
            AlfredBundler.icon('', '')
        )
        # Default.png for invalid font
        self.assertTrue(
            AlfredBundler.icon('fontawesome', 'adjust', 'hubbahubba') ==
            AlfredBundler.icon('', '')
        )
        # Ensure directories are created, valid icon is downloaded and retruned
        path = os.path.join(
            common.ICON_CACHE, 'fontawesome', 'ffffff', 'adjust.png'
        )
        dirpath = os.path.dirname(path)
        if os.path.exists(dirpath):
            shutil.rmtree(dirpath)

        icon = AlfredBundler.icon('fontawesome', 'adjust', 'ffffff')
        self.assertEqual(icon, path)
        self.assertTrue(os.path.exists(path))

        if os.path.exists(path):
            os.unlink(path)

        # Returns correctly altered icon. Here: dark icon on dark background
        # returns light icon instead
        os.environ['alfred_theme_background'] = 'rgba(0,0,0,1.0)'
        path = os.path.join(
            common.ICON_CACHE, 'fontawesome', 'ffffff', 'ambulance.png'
        )
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
        icondir = (
            '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources'
        )
        good = ('Accounts', 'AirDrop', 'BookmarkIcon',)
        bad = ('WindowLicker', 'Wolpertinger',)
        for name in good:
            path = os.path.join(icondir, '{}.icns'.format(name))
            icon = AlfredBundler.icon('system', name)
            self.assertEqual(icon, path)
        for name in bad:
            self.assertEqual(
                AlfredBundler.icon('system', name), AlfredBundler.icon('', '')
            )

    def test_utility(self):
        """Load utility"""
        path = os.path.join(
            common.BUNDLER_DIRECTORY, 'data', 'assets', 'utility',
            'Terminal-Notifier', 'latest', 'terminal-notifier.app', 'Contents',
            'MacOS', 'terminal-notifier'
        )
        self.assertEqual(
            AlfredBundler.utility('Terminal-Notifier', 'latest'), path
        )
        self.assertEqual(
            AlfredBundler.utility('Terminal-Notifier', 'latest'), path
        )

    def test_requirements(self):
        """Install Python libraries"""

        # Ensure library isn't installed
        with self.assertRaises(ImportError):
            import html
        with open(common.REQUIREMENTS, 'wb') as f:
            f.write('html==1.15')

        # Install requirements
        AlfredBundler.requirements._handle_requirements()

        # Correct version is installed
        import html
        self.assertTrue(html.__version__ == '1.15')
        self.assertTrue(os.path.exists(self.install_dir))

        # Update requirements with newer version
        with open(common.REQUIREMENTS, 'wb') as f:
            f.write('html==1.16')

        # Update installed libraries
        AlfredBundler.requirements._handle_requirements()
        reload(html)
        self.assertTrue(html.__version__ == '1.16')

        # reset file
        with open(common.REQUIREMENTS, 'wb') as f:
            f.write('html==1.15')


if '__main__' in __name__:
    unittest.main()
