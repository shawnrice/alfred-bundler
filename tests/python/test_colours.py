#!/usr/bin/python
# -*- coding: utf-8 -*-
# vim: fileencoding=utf-8
"""
test_colours.py

Created by deanishe@deanishe.net on 2014-08-10.
Copyright (c) 2014 deanishe@deanishe.net

MIT Licence. See http://opensource.org/licenses/MIT

"""

from __future__ import print_function, unicode_literals


import os
import random
import logging
import shutil
import unittest

from common import BACKGROUND_COLOUR_FILE, BUNDLER_VERSION, COLOUR_CACHE
from pybundler import AlfredBundler


ITERATIONS = 10000


log = logging.getLogger('tests.colours')

log.debug('Bundler version : {}'.format(BUNDLER_VERSION))


def setUp():
    pass


def tearDown():
    pass


def random_color():

    r = random.randint(0, 255)
    g = random.randint(0, 255)
    b = random.randint(0, 255)

    return '{:02x}{:02x}{:02x}'.format(r, b, g)


class ColourTests(unittest.TestCase):

    def setUp(self):
        self.flip_distance = 30
        os.environ['alfred_theme_background'] = 'rgba(255,255,255,1.00)'
        if os.path.exists(COLOUR_CACHE):
            shutil.rmtree(COLOUR_CACHE)

    def tearDown(self):
        if 'alfred_theme_background' in os.environ:
            del os.environ['alfred_theme_background']
        if os.path.exists(COLOUR_CACHE):
            shutil.rmtree(COLOUR_CACHE)

    def test_convert_hex_rgb(self):
        """CSS -> RGB"""

        for i in range(ITERATIONS):
            r = random.randint(0, 255)
            g = random.randint(0, 255)
            b = random.randint(0, 255)
            css = '{:02x}{:02x}{:02x}'.format(r, g, b)
            rgb = (r, g, b)
            self.assertEqual(rgb, AlfredBundler.hex_to_rgb(css))

    def test_convert_css_to_css(self):
        """CSS -> RGB -> CSS"""

        for i in range(ITERATIONS):
            r = random.randint(0, 255)
            g = random.randint(0, 255)
            b = random.randint(0, 255)
            css = '{:02x}{:02x}{:02x}'.format(r, g, b)

            self.assertEqual(css, AlfredBundler.rgb_to_hex(r, g, b))

    def test_convert_css_to_css2(self):
        """RGB -> HSV -> RGB"""

        for i in range(ITERATIONS):
            r = random.randint(0, 255)
            g = random.randint(0, 255)
            b = random.randint(0, 255)

            hsv = AlfredBundler.rgb_to_hsv(r, g, b)

            self.assertEqual((r, g, b), AlfredBundler.hsv_to_rgb(*hsv))

    def test_round_trip_css(self):
        """CSS -> RGB -> HSV -> RGB -> CSS"""

        for i in range(ITERATIONS):
            r = random.randint(0, 255)
            g = random.randint(0, 255)
            b = random.randint(0, 255)

            css = '{:02x}{:02x}{:02x}'.format(r, g, b)

            hsv = AlfredBundler.rgb_to_hsv(r, g, b)
            r2, g2, b2 = AlfredBundler.hsv_to_rgb(*hsv)

            self.assertEqual((r, g, b), (r2, g2, b2))

            self.assertEqual(css, AlfredBundler.rgb_to_hex(r2, g2, b2))

    def notest_flip_round_trip(self):
        """CSS -> flip -> flip -> CSS"""

        for i in range(ITERATIONS):
            r = random.randint(0, 255)
            g = random.randint(0, 255)
            b = random.randint(0, 255)

            css = '{:02x}{:02x}{:02x}'.format(r, g, b)
            css2 = AlfredBundler.flip_color(AlfredBundler.flip_color(css))

            r2, g2, b2 = AlfredBundler.hex_to_rgb(css2)
            log.debug('{}  ->  {}'.format(css, css2))

            self.assertAlmostEquals(r, r2, delta=self.flip_distance)
            self.assertAlmostEquals(g, g2, delta=self.flip_distance)
            self.assertAlmostEquals(b, b2, delta=self.flip_distance)

    def test_flip_color(self):
        """Flip colour"""
        self.assertEqual(AlfredBundler.flip_color('000000'), 'ffffff')
        self.assertEqual(AlfredBundler.flip_color('ffffff'), '000000')

        self.assertEqual(AlfredBundler.flip_color('000000'), 'ffffff')
        self.assertEqual(AlfredBundler.flip_color('ffffff'), '000000')

    def test_dark_light_colors(self):
        """Dark and light colours"""
        black = '000'
        white = 'fff'
        self.assertTrue(AlfredBundler.color_is_dark(black))
        self.assertFalse(AlfredBundler.color_is_light(black))

        self.assertTrue(AlfredBundler.color_is_light(white))
        self.assertFalse(AlfredBundler.color_is_dark(white))

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


if __name__ == '__main__':
    unittest.main()
