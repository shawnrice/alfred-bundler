import AlfredBundler
from cocoadialog import CocoaDialog
from terminalnotifier import TerminalNotifier

_wrappers = {
    'cocoaDialog': CocoaDialog,
    'terminal-notifier': TerminalNotifier
}


def wrapper(desired, debug=False):
    if desired in _wrappers.keys():
        return _wrappers[desired](AlfredBundler.utility(desired), debug=debug)
