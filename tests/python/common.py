# encoding: utf-8
#
# Copyright © 2014 deanishe@deanishe.net
#
# MIT Licence. See http://opensource.org/licenses/MIT
#
# Created on 2014-08-10
#

"""
"""

from __future__ import print_function, unicode_literals

import logging
import logging.handlers
import os


bundler_dir = os.path.join(os.path.dirname(os.path.dirname(
                           os.path.abspath(os.path.dirname(__file__)))),
                           'bundler')

# sys.path.insert(0, bundler_dir)

VERSION_FILE = os.path.join(bundler_dir, 'meta', 'version_major')

if os.getenv('AB_BRANCH'):
    BUNDLER_VERSION = os.getenv('AB_BRANCH')
else:
    BUNDLER_VERSION = open(VERSION_FILE).read().strip()

BUNDLER_ID = 'net.deanishe.alfred-bundler-python'
BUNDLER_DIR = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/'
    'alfred.bundler-{}'.format(BUNDLER_VERSION))
BUNDLER_PY_LIB = os.path.join(BUNDLER_DIR, 'bundler', 'AlfredBundler.py')
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

_log = logging.getLogger('tests')

if not len(_log.handlers):
    _hdlr = logging.StreamHandler()
    _fmt = logging.Formatter(
        fmt='[%(asctime)s] [%(name)s] [%(filename)s:%(lineno)s] '
        '[%(levelname)s] %(message)s',
        datefmt='%H:%M:%S')

    _log.setLevel(logging.DEBUG)
    _hdlr.setFormatter(_fmt)
    _log.addHandler(_hdlr)
