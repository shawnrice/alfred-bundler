#!/usr/bin/env python
# encoding:UTF-8

"""
Python API for interacting with OSX notification spawner Terminal Notifier.

.. module:: terminalnotifier
    :platform: MacOSX
    :synopsis: Python API for interacting with OSX
               notification spawner Terminal Notifier.
.. moduleauthor:: Ritashugisha <ritashugisha@gmail.com>

Terminal Notifier is a resource which allows the user to spawn MacOSX
notifications from the command-line. Notifications return no information.

`Official Documentation <https://github.com/alloy/terminal-notifier>`_.
`License GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>`_.

Design decisions were made to improve simplicity
in the implementation of the API.

-> Notification Options
===============================================================================

+ `message      *[notification message]*` (__REQUIRED__)
+ `title        *[notification title]*` (Displayed at the top in bold)
+ `subtitle     *[notification subtitle]*` (Displayed beneath title in bold)
+ `sound        *[notification entry sound]*` (Apple sounds (case sensitive))
+ `group        *[notification group id]*` (ID of notification group)
+ `remove       *[notification group id]*` (Removes any with passed group id)
+ `activate     *[app to be activated]*` (App bundle id to be activated)
+ `sender       *[app bundle id of icon]*` (App bundle id for icon to be used)
+ `appIcon      *[path to image of icon]*` (OSX 10.9+ only)
+ `contentImage *[path to image of content icon]*` (OSX 10.9+ only)
+ `open         *[url to be opened]*` (URL to be opened)
+ `execute      *[shell command to be run]*` (Shell command to be run)


-> Usage
===============================================================================

To include this api in your Python scripts, copy this ``terminalnotifier.py``
to a viable place for you to import.

Import the TerminalNotifier client:

    from terminalnotifier import TerminalNotifier
    client = TerminalNotifier(
        "path to terminal-notifier.app or exec", debug=False)

Now that you have access to the client, you can call a notification:

    my_notification = client.notify(
        title='My Notification',
        subtitle='Hello, World!',
        message='Have a nice day!',
        sender='com.apple.Finder')

**NOTE**: The included `debug` parameter is very useful for finding out why
your specified parameters are not being shown, or why your parameters are not
passing as valid parameters, and thus the notification is not being spawned.


-> Revisions
===============================================================================
1.0, 07-28-14: Initial release
...<FUTURE>...
"""

import os
import inspect
import logging
import subprocess

logging.basicConfig(
    level=logging.DEBUG,
    format=('[%(asctime)s] '
            '[{}:%(lineno)d] '
            '[%(levelname)s] '
            '%(message)s').format(os.path.basename(__file__)),
    datefmt='%Y-%m-%d %H:%M:%S'
    )

AUTHOR = 'Ritashugisha <ritashugisha@gmail.com>'
DATE = '07-28-14'
VERSION = '1.0'


class TerminalNotifier:

    """Main class used to interact with Terminal Notifier.

    Public class used to initialize the Terminal Notifier interaction client.
    Client is built by:

        client = TerminalNotifier(
            'path to terminal-notifier.app or exec', debug=Boolean)

    Initializes valid and required options.
    """

    def __init__(self, notifier, debug=False):
        """Initialize the Terminal Notifier client.

        :param notifier: Path to terminal-notifier.app or exec
        :type notifier: str
        :param debug: True if debugging is enabled
        :type debug: bool
        """
        self.notifier = notifier
        self.debug = debug
        self.log = logging.getLogger(self.__class__.__name__)
        if os.path.exists(self.notifier):
            if '.app' in os.path.splitext(self.notifier)[1].lower():
                self.notifier = os.path.join(
                    self.notifier, 'Contents/MacOS/terminal-notifier')
                valid_notifier = os.path.exists(self.notifier)
            else:
                valid_notifier = ('terminal-notifier' ==
                                  os.path.basename(self.notifier).lower())
        else:
            valid_notifier = False
        if not valid_notifier:
            if self.debug:
                self.log.critical(
                    'invalid path to terminal-notifier ({})'.format(
                        self.notifier))
            raise SystemExit
        self.valid_options = {
            'message': (str, unicode,),
            'title': (str, unicode,),
            'subtitle': (str, unicode,),
            'sound': (str, unicode,),
            'group': (str, unicode,),
            'remove': (str, unicode,),
            'activate': (str, unicode,),
            'sender': (str, unicode,),
            'appIcon': (str, unicode,),
            'contentImage': (str, unicode,),
            'open': (str, unicode,),
            'execute': (str, unicode)
        }
        self.required_options = ['message']

    def _run_subprocess(self, process):
        """Run the specified subprocess on the system.

        NOTE: The process parameter takes either a list or a string.
        This capability was only placed as a fallback to a previous version
        You should never pass a string to this function.

        :param process: Process to be run
        :type process: str
        :returns: String of command output or False
        :rtype: str or bool
        """
        if isinstance(process, list) or isinstance(process, str):
            if isinstance(process, list):
                proc = subprocess.Popen(
                    process,
                    stdout=subprocess.PIPE)
            else:
                proc = subprocess.Popen(
                    [process],
                    stdout=subprocess.PIPE,
                    shell=True)
            return proc
        else:
            return False

    def _valid_options(self, passed):
        """Check if the $passed **kwargs are valid.

        This function compares the $passed **kwargs to the global valid options
        to check if the passed arguments are valid.

        :param passed: **kwargs from dialog arguements
        :type passed: dict
        :returns: True if passed are valid
        :rtype: bool
        """
        _is_valid = True

        # First we validate that all $passed options are valid options and \
        # are the coresponding valid type.
        for passed_key in passed.keys():
            if passed_key in self.valid_options.keys():
                if type(passed[passed_key]) not in \
                        self.valid_options[passed_key]:
                    if self.debug:
                        self.log.warning(', '.join([
                            'notification',
                            'removing ({}) invalid type'.format(passed_key),
                            'expected ({})'.format(' or '.join([
                                i.__name__ for i in
                                self.valid_options[passed_key]
                            ])),
                            'got ({})'.format(
                                type(passed[passed_key]).__name__)
                        ]))
                    del passed[passed_key]
            else:
                if self.debug:
                    self.log.warning(', '.join([
                        'notification',
                        'removing ({}) invalid parameter'.format(passed_key),
                        'available are ({})'.format(', '.join(
                            self.valid_options.keys()))
                    ]))
                del passed[passed_key]

        # Next we can check that the $passed options contain the required \
        # options.
        for required_key in self.required_options:
            if required_key not in passed.keys():
                if self.debug:
                    self.log.error(', '.join([
                        'notification',
                        'missing required parameter ({})'.format(required_key)
                    ]))
                _is_valid = False

        # If the remove option is given, then we sould remove all other \
        # options in order to allow room for notification removal to occur.
        if 'remove' in passed.keys():
            _is_valid = True
            for k in passed.keys():
                if not k.startswith('remove'):
                    passed.pop(k)

        return _is_valid

    def _display(self, passed):
        """Display the dialog after some crutial formatting.

        :param passed: Passed dialog arguemnts
        :type passed: dict
        :returns: Process output or False
        :rtype: str or bool
        """
        # Ensure that passed keys are formated as -$key
        passed = dict(('-{}'.format(k), v) for k, v in passed.iteritems())
        process = [self.notifier]

        # Add keys and corresponding values to process list
        # It is important we escape the first character of every value
        # passed. This is a known bug in TN.
        [process.extend([k, '\%s' % v]) for k, v in passed.iteritems()]
        try:
            if self.debug:
                self.log.info(process)
            return self._run_subprocess(process)
        except IndexError:
            return False
        except KeyboardInterrupt:
            return False

    def notify(self, **_passed):
        """Spawn a notification with passed arguments.

        :param _passed: **kwargs of command arguments.
        :type _passed: dict
        """
        if self._valid_options(_passed):
            self._display(_passed)
