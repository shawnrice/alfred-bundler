#!/usr/bin/env python
# encoding: utf-8
#
# Copyright © 2014 The Alfred Bundler Team
# MIT Licence. See http://opensource.org/licenses/MIT

from __future__ import print_function, unicode_literals

import os
import sys
import time
import types
import inspect
import logging
import unittest

from common import *
from pybundler import bundler

LOG = logging.getLogger('tests.wrapper')
LOG.debug('bundler version: {}-{}'.format(
    bundler.VERSION, bundler.BUNDLER_VERSION
))


class DeveloperTesting:

    def __init__(self):
        self._wrappers_dir = os.path.join(bundler.WRAPPERS_DIR, 'wrappers')
        self._wrappers = [
            os.path.splitext(i)[0] for i in os.listdir(self._wrappers_dir) if (
                os.path.splitext(i)[1].lower() == '.py') and
            ('__init__' not in i.lower())
        ]


class CocoaDialogTest(unittest.TestCase):

    def setUp(self):
        self.wrapper_name = 'cocoadialog'
        self.testing = DeveloperTesting()

    def tearDown(self):
        pass

    def test_wrapper_exists(self):
        self.assertTrue(
            self.wrapper_name in self.testing._wrappers,
            'Could not find {} wrapper in {}'.format(
                self.wrapper_name, self.testing._wrappers_dir
            )
        )

    def test_wrapper_function(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name)
        self.assertTrue(
            hasattr(_wrapper_load, '__class__'),
            'returned wrapper is not a class object'
        )
        self.assertTrue(
            isinstance(_wrapper_load, types.InstanceType),
            'returned wrapper is not a valid wrapper instance'
        )

    def test_msgbox(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name, debug=True)
        _test_msgbox = _wrapper_load.msgbox(
            title='Bundler::{}'.format(self.test_msgbox.__name__),
            text='Please click the indicated button...',
            button1='Click Me'
        )
        self.assertTrue(
            isinstance(_test_msgbox, list),
            'msgbox did not return list'
        )
        self.assertTrue(
            len(_test_msgbox) > 0,
            'msgbox did not return any values'
        )
        self.assertTrue(
            _test_msgbox[0] == '1',
            ' '.join([
                'msgbox returned invalid value for no string_output',
                'actual: "{}", required: "{}"'
            ]).format('1', _test_msgbox[0])
        )
        _test_msgbox = _wrapper_load.msgbox(
            title='Bundler::{}'.format(self.test_msgbox.__name__),
            text='Please click the indicated button...',
            button1='Click Me',
            string_output=True
        )
        self.assertTrue(
            isinstance(_test_msgbox, list),
            'msgbox did not return list'
        )
        self.assertTrue(
            len(_test_msgbox) > 0,
            'msgbox did not return any values'
        )
        self.assertTrue(
            _test_msgbox[0] == 'Click Me',
            ' '.join([
                'msgbox returned invalid value for string_output',
                'actual: "{}", required: "{}"'
            ]).format('Click Me', _test_msgbox[0])
        )

    def test_notify(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name, debug=True)
        _test_notify = _wrapper_load.notify(
            title='Bundler::{}'.format(self.test_notify.__name__),
            description='This is just a test notification...'
        )
        self.assertIsNone(
            _test_notify,
            'notify returned value, must return nothing'
        )

    def test_progressbar(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name, debug=True)
        _test_progressbar = _wrapper_load.progressbar(
            title='Bundler::{}'.format(self.test_progressbar.__name__),
            text='Testing progress bar...',
            percent=0
        )
        self.assertTrue(
            hasattr(_test_progressbar, '__class__'),
            'returned progressbar is not a class object'
        )
        self.assertEquals(
            type(_test_progressbar).__name__, 'progressbar',
            'returned object is not a valid progressbar instance'
        )
        for i in range(101):
            _test_progressbar.update(percent=i)
            time.sleep(0.01)
        _test_progressbar.finish()

    def test_stoppable_progressbar(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name, debug=True)
        _test_progressbar = _wrapper_load.progressbar(
            title='Bundler::{}'.format(
                self.test_stoppable_progressbar.__name__
            ),
            text='Please press the stoppable button...',
            percent=0,
            stoppable=True
        )
        self.assertTrue(
            hasattr(_test_progressbar, '__class__'),
            'returned progressbar is not a class object'
        )
        self.assertEquals(
            type(_test_progressbar).__name__, 'progressbar',
            'returned object is not a valid progressbar instance'
        )
        for i in range(101):
            _running_progress = _test_progressbar.update(percent=i)
            if _running_progress == 0:
                break
            else:
                self.assertEquals(
                    _running_progress, 1,
                    ' '.join([
                        'invalid return from stoppable progress bar update,',
                        'actual: {}, required: {}'
                    ]).format(_running_progress, '1')
                )
            time.sleep(1)
        _killed_progress = _test_progressbar.update(percent=0)
        self.assertEquals(
            _killed_progress, 0,
            ' '.join([
                'invalid return from stoppable progress bar update,',
                'actual: {}, required: {}'
            ]).format(_killed_progress, '0')
        )


class TerminalNotifierTest(unittest.TestCase):

    def setUp(self):
        self.wrapper_name = 'terminalnotifier'
        self.testing = DeveloperTesting()

    def tearDown(self):
        pass

    def test_wrapper_exists(self):
        self.assertTrue(
            self.wrapper_name in self.testing._wrappers,
            'Could not find {} wrapper in {}'.format(
                self.wrapper_name, self.testing._wrappers_dir
            )
        )

    def test_wrapper_function(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name)
        self.assertTrue(
            hasattr(_wrapper_load, '__class__'),
            'returned wrapper is not a class object'
        )
        self.assertTrue(
            isinstance(_wrapper_load, types.InstanceType),
            'returned wrapper is not a valid wrapper instance'
        )

    def test_notification(self):
        _wrapper_load = bundler.wrapper(self.wrapper_name)
        _test_notification = _wrapper_load.notify(
            title='Bundler::{}'.format(self.test_notification.__name__),
            message='This is just a test notification...'
        )
        self.assertIsNone(
            _test_notification,
            'notification returned value, must return nothing'
        )


if __name__ in '__main__':
    unittest.main()
