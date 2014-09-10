import os

BUNDLER_DIR = None

_lookback = os.path.abspath(__file__)
while not BUNDLER_DIR:
    _curdir = os.path.dirname(os.path.abspath(_lookback))
    if os.path.basename(_curdir).startswith('alfred.bundler-'):
        BUNDLER_DIR = _curdir
        break
    else:
        _lookback = _curdir

try:
    import AlfredBundler
except ImportError:
    import imp
    AlfredBundler = imp.load_source(
        'AlfredBundler',
        os.path.join(BUNDLER_DIR, 'bundler', 'AlfredBundler.py')
    )

from cocoadialog import CocoaDialog
from terminalnotifier import TerminalNotifier

# This "should" work through the json,
# but in Python it's better to work around the json like this.
_common = {
    'cocoadialog': (CocoaDialog, 'cocoaDialog'),
    'terminalnotifier': (TerminalNotifier, 'Terminal-Notifier')
}


def wrapper(desired, debug=False):
    if desired in _common.keys():
        return _common[desired][0](
            AlfredBundler.utility(_common[desired][1]), debug=debug)
