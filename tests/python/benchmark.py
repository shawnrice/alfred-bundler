#!/usr/bin/python
# encoding: utf-8
#
# Copyright © 2014 deanishe@deanishe.net
#
# MIT Licence. See http://opensource.org/licenses/MIT
#
# Created on 2014-06-08
#

"""
"""

from __future__ import print_function, unicode_literals

import os
import sys

sys.path.insert(0, '../../bundler/bundlets')
sys.path.insert(0, '../../bundler')

from time import time

import bundler
import AlfredBundler as AB


PROFILE = False


def main():

    reps = 100

    #
    # Bundlet functions
    # -------------------------------------------------------------------------

    st = time()
    print('Calling `bundler.init()`')
    for i in range(reps):
        bundler.init()
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    print('Calling `bundler.utility("Pashua")`')
    for i in range(reps):
        bundler.utility('Pashua')
        # print('[{:2d}] {}'.format(i+1, p))
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    print('Calling `bundler.utility("Terminal-Notifier")`')
    for i in range(reps):
        bundler.utility('Terminal-Notifier')
        # print('[{:2d}] {}'.format(i+1, p))
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    print('Calling `bundler.utility("cocoaDialog")`')
    for i in range(reps):
        bundler.utility('cocoaDialog')
        # print('[{:2d}] {}'.format(i+1, p))
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    print('Calling `bundler.utility("viewer")`')
    for i in range(reps):
        bundler.utility('viewer')
        # print('[{:2d}] {}'.format(i+1, p))
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    print('Calling `bundler.icon()` (light)')
    for i in range(reps):
        bundler.icon('fontawesome', 'adjust', 'fff')
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    os.environ['alfred_theme_background'] = 'rgba(0,0,0,1.0)'
    print('Calling `bundler.icon()` (light on light with `alter`)')
    for i in range(reps):
        bundler.icon('fontawesome', 'adjust', 'fff', True)
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    st = time()
    os.environ['alfred_theme_background'] = 'rgba(255,255,255,1.0)'
    print('Calling `bundler.icon()` (light on dark with `alter`)')
    for i in range(reps):
        bundler.icon('fontawesome', 'adjust', 'fff', True)
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

    #
    # Bundler functions
    # -------------------------------------------------------------------------

    st = time()
    print('Calling `AlfredBundler.flip_color()`')
    for i in range(reps):
        AB.flip_color('fff')
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))


    #st = time()
    #print('Posting notification with `terminal-notifier`')
    #for i in range(reps):
        #subprocess.call([notifier, '-title', 'Some title',
                        #'-message', 'My message'])
        ## print('[{:2d}] {}'.format(i+1, p))
    #d = time() - st
    #print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))


if __name__ == '__main__':
    if not PROFILE:
        sys.exit(main())

    import cProfile
    cProfile.run('main()')
