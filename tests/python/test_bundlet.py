#!/usr/bin/python
# encoding: utf-8
#
# Copyright © 2014 The Alfred Bundler Team
# MIT Licence. See http://opensource.org/licenses/MIT

from __future__ import unicode_literals
import sys
import os
import imp
import shutil
import tempfile
import logging
import unittest
import urllib2

import common

log = logging.getLogger('test.bundlet')
log.debug('BUNDLER VERSION : {}'.format(common.MAJOR_VERSION))

bundlet = imp.load_source(
    os.path.splitext(common.BUNDLET)[0],
    common.BUNDLET_PATH
)

AlfredBundlerScript = imp.load_source(
    os.path.splitext(common.BUNDLER)[0],
    common.BUNDLER_PATH
)


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


class BundletTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_bootstrap(self):
        if os.path.exists(common.BUNDLER_DIRECTORY):
            shutil.rmtree(common.BUNDLER_DIRECTORY)
        self.assertFalse(os.path.exists(common.BUNDLER_DIRECTORY))
        b = bundlet.AlfredBundler()
        self.assertTrue(os.path.exists(common.BUNDLER_DIRECTORY))
        self.assertTrue(os.path.exists(common.BUNDLER_PATH))
        AlfredBundlerScript = imp.load_source(
            os.path.splitext(common.BUNDLER)[0],
            common.BUNDLER_PATH
        )
        AlfredBundler = AlfredBundlerScript.Main(
            os.path.dirname(os.path.abspath(__file__))
        )
        self.assertEqual(type(b), type(AlfredBundler))


if '__main__' in __name__:
    unittest.main()
