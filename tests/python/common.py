#!/usr/bin/env python
# encoding: utf-8
#
# Copyright © 2014 The Alfred Bundler Team
# MIT Licence. See http://opensource.org/licenses/MIT

"""
"""

from __future__ import unicode_literals

import logging
import logging.handlers
import os

BUNDLER_ID = 'alfredbundler.default'
LOCAL_BUNDLER_DIRECTORY = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(
        os.path.dirname(__file__)))
    ),
    'bundler'
)
if os.getenv('AB_BRANCH'):
    MAJOR_VERSION = os.getenv('AB_BRANCH')
else:
    MAJOR_VERSION = open(
        os.path.join(LOCAL_BUNDLER_DIRECTORY, 'meta', 'version_major'),
        'rb'
    ).read().split('\n')[0]
BUNDLER = 'AlfredBundler.py'
BUNDLET = 'bundler.py'
BUNDLER_DIRECTORY = os.path.expanduser(
    '~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{}'
).format(MAJOR_VERSION)
BUNDLER_PATH = os.path.join(BUNDLER_DIRECTORY, 'bundler', BUNDLER)
BUNDLET_PATH = os.path.join(LOCAL_BUNDLER_DIRECTORY, 'bundlets', BUNDLET)
PYTHON_LIBRARY_DIRECTORY = os.path.join(
    BUNDLER_DIRECTORY, 'data', 'assets', 'python'
)
HELPER_DIRECTORY = os.path.join(PYTHON_LIBRARY_DIRECTORY, BUNDLER_ID)
GET_PIP_URL = (
    'https://raw.githubusercontent.com/pypa/pip/develop/contrib/get-pip.py'
)
ICON_CACHE = os.path.join(BUNDLER_DIRECTORY, 'data', 'assets', 'icons')
COLOUR_CACHE = os.path.join(BUNDLER_DIRECTORY, 'data', 'color-cache')
REQUIREMENTS = os.path.join(os.path.dirname(__file__), 'requirements')
WRAPPERS_DIRECTORY = os.path.join(
    BUNDLER_DIRECTORY, 'bundler', 'includes', 'wrappers', 'python', 'wrappers'
)
