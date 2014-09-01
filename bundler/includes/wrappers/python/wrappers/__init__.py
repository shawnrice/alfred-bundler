# I hate to do this, but until we can figure out a common way to store
# global variables between releases, I'll have to reference the "devel"
# VERSION.
#
# This will need to be updated with release.
#
# TODO: Figure out an easier way to point to AlfredBundler.py for self import.
BUNDLER_VERSION = 'devel'

try:
    import AlfredBundler
except ImportError:
    import os
    import imp
    AlfredBundler = imp.load_source('AlfredBundler', os.path.expanduser(
        '~/Library/Application Support/Alfred 2/Workflow Data/'
        'alfred.bundler-{}/bundler/AlfredBundler.py'.format(BUNDLER_VERSION)))

from cocoadialog import CocoaDialog
from terminalnotifier import TerminalNotifier

_wrappers = {
    'cocoadialog': (CocoaDialog, 'cocoaDialog'),
    'terminalnotifier': (TerminalNotifier, 'terminal-notifier')
}


def wrapper(desired, debug=False):
    if desired in _wrappers.keys():
        # This key conform is questionable
        return _wrappers[desired.lower()][0](
            AlfredBundler.utility(_wrappers[desired.lower()][1]), debug=debug)
