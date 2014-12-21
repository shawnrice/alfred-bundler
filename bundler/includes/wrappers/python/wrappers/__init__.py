import os
import inspect

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
from scriptfilter import ScriptFilter

# This "should" work through the json,
# but in Python it's better to work around the json like this.
_common = {
    'cocoadialog': (CocoaDialog, 'cocoaDialog'),
    'terminalnotifier': (TerminalNotifier, 'Terminal-Notifier'),
    'scriptfilter': (ScriptFilter, None)
}


def wrapper(desired, debug=False, workflow_id=None):
    if desired in _common.keys():
        if _common[desired][1]:
            return _common[desired][0](
                AlfredBundler._utility(
                    _common[desired][1], 'latest', workflow_id=workflow_id),
                debug=debug
            )
        else:
            return _common[desired][0](debug=debug)
