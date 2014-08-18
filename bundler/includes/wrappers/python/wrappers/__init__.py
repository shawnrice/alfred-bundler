import AlfredBundler
from cocoadialog import CocoaDialog
from terminalnotifier import TerminalNotifier

_wrappers = {
    'cocoadialog': (CocoaDialog, 'cocoaDialog'),
    'terminalnotifier': (TerminalNotifier, 'terminal-notifier')
}


def wrapper(desired, debug=False):
    if desired in _wrappers.keys():
        return _wrappers[desired.lower()][0](
            AlfredBundler.utility(_wrappers[desired.lower()][1]), debug=debug)
