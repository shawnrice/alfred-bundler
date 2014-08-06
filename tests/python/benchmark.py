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

import sys

sys.path.insert(0, '../../bundler/wrappers')
sys.path.insert(0, '../../bundler')

from time import time

import bundler
import AlfredBundler as AB


PROFILE = False


def main():

    reps = 100

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
    print('Calling `bundler.utility("viewer")`')
    for i in range(reps):
        bundler.utility('viewer')
        # print('[{:2d}] {}'.format(i+1, p))
    d = time() - st
    print('{} calls in {:0.4f} s ({:0.4f} s/call)\n'.format(reps, d, d / reps))

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
