#!/usr/bin/env python
# encoding:UTF-8

"""
Python API for interacting with OSX dialog spawner CocoaDialog.

.. module:: cocoadialog
    :platform: MacOSX
    :synopsis: Python API for interacting with OSX dialog spawner CocoaDialog.
.. moduleauthor:: Ritashugisha <ritashugisha@gmail.com>

CocoaDialog is a resource which allows the user to spawn MacOSX aqua dialogs
from the command-line. Dialogs are predefined and return input via echo.

`Official Documentation <http://mstratman.github.io/cocoadialog/>`_.
`License GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>`_.

**NOTE**: Dialog classes don't follow standard naming conventions.
This decision was made to improve simplicity in the implementation of the API.

-> Usage
===============================================================================

To include this api in your Python scripts, copy this ``cocoadialog.py`` to
a viable place for you to import.

Import the CocoaDialog client:

    from cocoadialog import CocoaDialog
    client = CocoaDialog("path to CocoaDialog.app or exec", debug=False)

Now that you have access to the client, you can call specific dialogs:

    my_message_box = client.msgbox(
        title='My Message Box',
        text='Hello, World!',
        button1='Ok', button2='Cancel',
        informative_text='Your information here...'
        icon='home',
        string_output=True)

    print my_message_box

If the user clicks on the "Ok" button, my_message_box will return ["Ok"]
in this script. If, however, the user presses "Cancel", ["Cancel"] will
be returned.

**NOTE**: The included `debug` parameter is very useful for finding out why
your specified parameters are not being shown, or why your parameters are not
passing as valid parameters, and thus the dialog is not being spawned.

All other dialogs are spawned via similar treatment as shown above.
For more info on what parameters are available for a specifc dialog, please
visit the `Official Documentation` or play with `debug=True` for a while.

To create a progress bar dialog, you have to create a new instance for the
progress bar object.

    my_progress_bar = client.progressbar(
        title='My Progress Bar',
        text='Hello, World!',
        percent=0,       # 0 percent filled bar
        icon='info')

    import time
    for i in range(101): # Demonstration of progress bar
        my_progress_bar.update(perent=i)
        time.sleep(0.1)  # in order for you to see results in this example,
                         # you need to have the bar sleep a little

Whenever the progress bar reaches an EOF, the dialog with kill itself.

If you plan to add the `stoppable` feature in your progress bar, you will need
to format your loop a little differently.

    my_progress_bar = client.progressbar(
        title='My Progress Bar',
        text='Hello, World!',
        percent=0,
        icon='info',
        stoppable=True)  # Stoppable is TRUE now

    import time
    for i in range(101):
        time.sleep(0.1)
        if my_progress_bar.update(perent=i) == 0:
            #...<USER STOPPED>
            break

The `update` function, returns 1 to signify it is running. When the user stops
the progress bar, the `finish` function is called and returns 0 instead.


-> Revisions
===============================================================================
1.0, 07-28-14: Initial release for (3.0, 0, 'beta')
...<FUTURE>...
"""

import os
import re
import inspect
import logging
import subprocess

logging.basicConfig(
    level=logging.DEBUG,
    format=('[%(levelname)-8s] '
            '<%(name)s, %(funcName)s:%(lineno)d>'
            '....%(message)s'))

AUTHOR = 'Ritashugisha <ritashugisha@gmail.com>'
DATE = '07-28-14'
VERSION = '1.0'
COCOA_VERSION = (3.0, 0, 'beta')


class NestedAccess(object):

    """Decorator used to provide child classes with access to their parent."""

    def __init__(self, cls):
        """Initialize decorator with the class descriptor.

        :param cls: Parent class initializing wrapper class
        """
        self.cls = cls

    def __get__(self, instance, outer_class):
        """Grab the parent class's object and returns in a Wrapper class.

        :param instance: Instance of child class
        :param outer_class: Parent class object
        """
        class Wrapper(self.cls):
            outer = instance

        Wrapper.__name__ = self.cls.__name__
        return Wrapper


class CocoaDialog:

    """Main class used for interacting with CocoaDialog.

    Public class used to initialize the CocoaDialog interaction client.
    Client is built by:

        client = CocoaDialog('path to CocoaDailog.app or exec', debug=bool)

    Initializes global options (dict) and global icons (list).
    """

    def __init__(self, cocoa, debug=False):
        """Initialize the CocoaDialog client.

        :param cocoa: Path to CocoaDialog.app or exec
        :type cocoa: str
        :param debug: Option to enable debugging
        :type debug: bool
        """
        self.cocoa = cocoa
        self.debug = debug
        self.log = logging.getLogger(self.__class__.__name__)
        if os.path.exists(self.cocoa):
            if '.app' in os.path.splitext(self.cocoa)[1].lower():
                self.cocoa = os.path.join(
                    self.cocoa, 'Contents/MacOS/cocoadialog')
                valid_cocoa = os.path.exists(self.cocoa)
            else:
                valid_cocoa = ('cocoadialog' ==
                               os.path.basename(self.cocoa).lower())
        else:
            valid_cocoa = False
        if not valid_cocoa:
            if self.debug:
                self.log.critical(
                    'invalid path to cocoadialog ({})'.format(self.cocoa))
            raise SystemExit
        self.global_options = {
            'title': (str, unicode,),
            'string_output': (bool,),
            'no_newline': (bool,),
            'width': (int, float,),
            'height': (int, float,),
            'posX': (int, float,),
            'posY': (int, float,),
            'icon': (str, unicode,),
            'timeout': (int, float,),
            'timeout_format': (str, unicode,),
            'icon_bundle': (str, unicode,),
            'icon_file': (str, unicode,),
            'icon_size': (int, float,),
            'icon_height': (int, float,),
            'icon_width': (int, float,),
            'icon_type': (str, unicode,),  # Do not use, breaks icon display
            'debug': (bool,),
            'help': (bool,)
            }
        self.lower_exceptions = ['posX', 'posY']
        self.global_icons = [
            'addressbook', 'airport', 'airport2', 'application', 'archive',
            'bluetooth', 'bonjour', 'atom', 'burn', 'hazard', 'caution', 'cd',
            'cocoadialog', 'computer', 'dashboard', 'dock', 'document',
            'documents', 'download', 'eject', 'everyone', 'executable',
            'favorite', 'heart', 'fileserver', 'filevault', 'finder',
            'firewire', 'folder', 'folderopen', 'foldersmart', 'gear',
            'general', 'globe', 'group', 'help', 'home', 'info', 'installer',
            'ipod', 'movie', 'music', 'network', 'notice', 'package',
            'preferences', 'printer', 'screenshare', 'search', 'find',
            'security', 'sound', 'stop', 'x', 'sync', 'trash', 'trashfull',
            'update', 'url', 'usb', 'user', 'person', 'utilities', 'widget'
            ]

    def _format_passed(self, passed):
        new_passed = {}
        for k, v in passed.iteritems():
            if k not in self.lower_exceptions:
                new_passed[k.lower()] = v
            else:
                new_passed[k] = v
        return new_passed

    def _format_notify(self, passed):
        valid_x_placement = ['center', 'right', 'left']
        valid_y_placement = ['center', 'top', 'bottom']
        # Do some cleanup for passed hexadecimal colors. CocoaDialog only \
        # accepts the numbers (xxx or xxxxxx), so just in case users get \
        # crazy, we will regrex it
        for i in ['text_color', 'border_color', 'background_top',
                  'background_bottom']:
            if i in passed.keys():
                hex_match = re.match(
                    r'^(.*?)(?P<hex>([0-9a-fA-F]{3}){1,2})$',
                    passed[i])
                if hex_match:
                    passed[i] = hex_match.group('hex')
                else:
                    self.log.warning(', '.join([
                        custom_options['dialog_name'],
                        'removing invalid ({}), got ({})'.format(
                            i, passed[i]),
                        'expected (#XXX or #XXXXXX)']))
                    del passed[i]

        # Do some cleanup/validation on x_placement and y_placement \
        # parameters. Only accepted parameters are in valid_x_placement \
        # and valid_y_placement
        for i in [('x_placement', valid_x_placement),
                  ('y_placement', valid_y_placement)]:
            if i[0] in passed.keys() and \
               passed[i[0]] not in i[1]:
                if self.debug:
                    self.log.warning(', '.join([
                        custom_options['dialog_name'],
                        'removing invalid ({}), got ({})'.format(
                            i[0], passed[i[0]]),
                        'expected ({})'.format(' or '.join(i[1]))
                        ]))
                del passed[i[0]]
        return passed

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
            (proc, proc_e,) = proc.communicate()
            return proc
        else:
            return False

    def _valid_options(self, passed, custom_options):
        """Check if the $passed **kwargs are valid.

        This function compares the $passed **kwargs to the valid global options
        and the valid $custom_options, to check if the passed arguments
        are valid.

        :param passed: **kwargs from dialog arguements
        :type passed: dict
        :param custom_options: Custom valid options for the calling dialog
        :type custom_options: dict
        """
        _is_valid = True

        # Join the global options with the passed $custom_options \
        # and grab the function name
        valid_passed = dict(custom_options['custom_options'].items() +
                            self.global_options.items())
        _funct = custom_options['dialog_name']

        # First we validate that all $passed options are valid options and \
        # are the coresponding valid type.
        for passed_key in passed.keys():
            if passed_key in valid_passed.keys():
                if type(passed[passed_key]) not in valid_passed[passed_key]:
                    if self.debug:
                        # Debug: $function_name, \
                        # ($option) invalid type, \
                        # expected ($list_of_valid_types), \
                        # got($type_of_option)
                        self.log.warning(', '.join([
                            _funct,
                            'removing ({}) invalid type'.format(passed_key),
                            'expected ({})'.format(' or '.join([
                                i.__name__ for i in valid_passed[passed_key]
                                ])),
                            'got ({})'.format(
                                type(passed[passed_key]).__name__)
                            ]))
                    del passed[passed_key]
            else:
                if self.debug:
                    # Debug: $function_name, \
                    # ($option) invalid parameter, \
                    # available are ($list_of_valid_options)
                    self.log.warning(', '.join([
                        _funct,
                        'removing ({}) invalid parameter'.format(passed_key),
                        'available are ({})'.format(
                            ', '.join(valid_passed.keys()))
                        ]))
                del passed[passed_key]

        # Next we can check that the $passed options contain the required \
        # options. We also validate that, if list is passed (for items), \
        # there is at least 1 entry in the list.
        for required_key in custom_options['required_options']:
            if required_key in passed.keys():
                for _lists in ['items', 'with_extensions',
                               'checked', 'disabled']:
                    if _lists in required_key.lower():
                        if len(passed[_lists]) <= 0:
                            if self.debug:
                                # Debug: $funciton_name, \
                                # length of items must be > 0
                                self.log.error(', '.join([
                                    _funct,
                                    'length of items must be > 0']))
                            _is_valid = False
            else:
                if self.debug:
                    # Debug: $function_name, \
                    # missing required parameter \
                    # ($missing_required_parameter)
                    self.log.error(', '.join([
                        _funct,
                        'missing required parameter ({})'.format(required_key)
                        ]))
                _is_valid = False

        # Finally, if we are passed an icon (!(icon_bundle || icon_file)), \
        # we check if the passed icon name is in $global_icons.\
        # If not, we remove it.
        if 'icon' in passed.keys():
            if passed['icon'] not in self.global_icons:
                if self.debug:
                    # Debug: #function_name, \
                    # removing invalid icon \
                    # ($passed_icon_name), available are \
                    # ($list_of_valid_icon_names)
                    self.log.warning(', '.join([
                        _funct,
                        'removing invalid icon ({})'.format(passed['icon']),
                        'available are ({})'.format(
                            ', '.join(self.global_icons))
                        ]))
                del passed['icon']

        return _is_valid

    def _display(self, funct, passed, return_process=False):
        """Display the dialog after some crutial formatting.

        :param funct: Dialog name
        :type funct: str
        :param passed: Passed dialog arguemnts
        :type passed: dict
        :param return_process: Return subprocess list if True
        :type return_process: bool
        :returns: Process output or False
        :rtype: str or bool
        """
        # Ensure that passed keys are formated as --$key \
        # with underscores as hyphens
        passed = dict(('--{}'.format(k.replace('_', '-')), v)
                      for k, v in passed.iteritems())
        process = [self.cocoa, funct.replace('_', '-')]

        # For the passed argument dictionary, make sure certain values \
        # are added to the process list as needed.

        # Strings, Unicode, Integers, and Floats are added as simple strings.
        # Lists are extended to the process list.
        # Bools are represented by the presence of the formated key.
        for k, v in passed.iteritems():
            if (isinstance(v, str) or isinstance(v, unicode) or
               (isinstance(v, int) and not isinstance(v, bool))
                or isinstance(v, float)) or \
               (isinstance(v, list) and len(v) > 0):
                process.append(k)
                if isinstance(v, list):
                    process.extend([str(i) for i in v])
                else:
                    process.append(str(v))
            else:
                if isinstance(v, bool) and v:
                    process.append(k)
        if not return_process:
            try:
                if self.debug:
                    # Debug: $process_list
                    self.log.info(process)
                return self._run_subprocess(process).split('\n')[:-1]
            except IndexError:
                # Previous problem that should have been eliminated. \
                # I'll leave it in as a catch all (just in case)
                return False
            except KeyboardInterrupt:
                # Used only for development purposes
                return False
        else:
            return process

    def bubble(self, **_passed):
        """Dialog type `bubble`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/bubble_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'no_timeout': (bool,),
            'alpha': (int, float),
            'x_placement': (str, unicode),
            'y_placement': (str, unicode),
            'text': (str, unicode,),
            'text_color': (str, unicode),
            'border_color': (str, unicode),
            'background_top': (str, unicode),
            'background_bottom': (str, unicode)
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['title', 'text'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            _passed = self._format_notify(_passed)
            return self._display(custom_options['dialog_name'], _passed)

    def notify(self, **_passed):
        """Updated version of `bubble`.

        NOTE: `bubble` is left for backwards compatibility.

        If the no_growl option is marked as true, growl is suppressed
        and you are allowed to mess with colors.

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'description': (str, unicode,),
            'sticky': (bool,),
            'no_growl': (bool,),
            'alpha': (int, float,),
            'text_color': (str, unicode,),
            'border_color': (str, unicode,),
            'background_bottom': (str, unicode,),
            'background_top': (str, unicode,),
            'x_placement': (str, unicode),
            'y_placement': (str, unicode),
            'fh': (bool,),  # Unkown option
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['title', 'description'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            _passed = self._format_notify(_passed)
            return self._display(custom_options['dialog_name'], _passed)

    def checkbox(self, **_passed):
        """Dialog type `checkbox`.

        Parameters are not documented.

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'label': (str, unicode,),
            'checked': (list,),
            'columns': (int,),
            'disabled': (list,),
            'items': (list,),
            'rows': (int,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1', 'items'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def radio(self, **_passed):
        """Dialog type `radio`.

        Parameters are not documented.

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'label': (str, unicode,),
            'selected': (int,),
            'columns': (int,),
            'disabled': (list,),
            'items': (list,),
            'rows': (int,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,)
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1', 'items'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def slider(self, **_passed):
        """Dialog type `slider`.

        Parameters are not documented.

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'label': (str, unicode,),
            'always_show_value': (bool,),
            'min': (int, float,),
            'max': (int, float,),
            'ticks': (int, float,),
            'slider_label': (str, unicode,),
            'value': (int, float,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            'return_float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1', 'min', 'max'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def msgbox(self, **_passed):
        """Dialog type `msgbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/msgbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            'no_cancel': (bool,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def ok_msgbox(self, **_passed):
        """Dialog type `ok_msgbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/ok-msgbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'no_cancel': (bool,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': [],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def yesno_msgbox(self, **_passed):
        """Dialog type `yesno_msgbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/yesno-msgbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'no_cancel': (bool,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': [],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def inputbox(self, **_passed):
        """Dialog type `inputbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/inputbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            'float': (bool,),
            'no_show': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def standard_inputbox(self, **_passed):
        """Dialog type `standard_inputbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/standard-inputbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'no_cancel': (bool,),
            'float': (bool,),
            'no_show': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': [],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def secure_inputbox(self, **_passed):
        """Dialog type `secure_inputbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/secure-inputbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def secure_standard_inputbox(self, **_passed):
        """Dialog type `secure_standard_inputbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/secure-standard-inputbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'informative_text': (str, unicode,),
            'no_cancel': (bool,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': [],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def fileselect(self, **_passed):
        """Dialog type `fileselect`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/fileselect_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'select_directories': (bool,),
            'select_only_directories': (bool,),
            'packages_as_directories': (bool,),
            'select_multiple': (bool,),
            'with_extensions': (list,),
            'with_directory': (str, unicode),
            'with_file': (str, unicode),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': [],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def filesave(self, **_passed):
        """Dialog type `filesave`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/filesave_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'packages_as_directories': (bool,),
            'no_create_directories': (bool,),
            'with_extensions': (list,),
            'with_directory': (str, unicode),
            'with_file': (str, unicode),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': [],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def textbox(self, **_passed):
        """Dialog type `textbox`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/textbox_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'text_from_file': (str, unicode,),
            'informative_text': (str, unicode,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            'editable': (bool,),
            'focus_textbox': (bool,),
            'selected': (bool,),
            'scroll_to': (str, unicode),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def dropdown(self, **_passed):
        """Dialog type `dropdown`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/dropdown_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'items': (list,),
            'pulldown': (bool,),
            'button1': (str, unicode,),
            'button2': (str, unicode,),
            'button3': (str, unicode,),
            'exit_onchange': (bool,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['button1', 'items'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    def standard_dropdown(self, **_passed):
        """Dialog type `standard_dropdown`.

        Valid parameters are listed at:
        <http://mstratman.github.io/cocoadialog/#documentation3.0/standard-dropdown_control>

        :param _passed: Dialog parameters
        :type _passed: dict
        """
        custom_options = {
            'text': (str, unicode,),
            'items': (list,),
            'pulldown': (bool,),
            'exit_onchange': (bool,),
            'float': (bool,),
            }
        custom_options = {
            'dialog_name': inspect.getframeinfo(
                inspect.currentframe())[2].lower(),
            'required_options': ['items'],
            'custom_options': custom_options
            }
        _passed = self._format_passed(_passed)
        if self._valid_options(_passed, custom_options):
            return self._display(custom_options['dialog_name'], _passed)

    @NestedAccess
    class progressbar(object):

        """Build a progress bar object in CocoaDialog.

        Note: This is a nested class, thus requires the @NestedAccess
        descriptor for access to methods in the parent class (CocoaDialog).

        Note: The implementation of this dialog is a little more funky than
        the others. Building a progress bar dialog is executed the same
        way as the other dialogs. Unlike the other functions, this class has
        an update function with takes **ONLY** an integer to modify the percent
        of the progress bar, and a string to modify the text above the
        progress bar.

        Note: By default, the progress bar sould automatically kill itself when
        it reads an EOF. If for some reason the dialog does not automatically
        kill itself at the EOF, there is a `finish` function which takes no
        parameters, but kills the current instance's progress bar dialog.
        """

        def __init__(self, **_passed):
            """Initailize and display the progress bar dialog.

            :param _passed: Arguments for manipulating dialog
            :type _passed: **kwargs
            """
            custom_options = {
                'text': (str, unicode,),
                'percent': (int, float,),
                'indeterminate': (bool,),
                'float': (bool,),
                'stoppable': (bool,),
                }
            self.custom_options = {
                'dialog_name': self.__class__.__name__.lower(),
                'required_options': ['percent', 'text'],
                'custom_options': custom_options
                }
            _passed = self._format_passed(_passed)
            if self.outer._valid_options(_passed, self.custom_options):
                self.percent, self.text = (_passed['percent'], _passed['text'])
                process = self.outer._display(
                    self.custom_options['dialog_name'],
                    _passed,
                    return_process=True)

                # We need to create our own child-process here in order to \
                # push stdin for updates later
                self.pipe = subprocess.Popen(
                    process,
                    stdin=subprocess.PIPE,
                    stdout=subprocess.PIPE)

        def update(self, percent=None, text=None, stoppable=None):
            """Update the progress bar instance with a new percent value and text.

            :param percent: New percent for dialog's progress bar
            :param text: New text for dialog's informative text
            :type percent: ``int`` or ``float``
            :type text: ``str`` or ``unicode``
            :returns: 1 if running
            """
            self.percent = percent or self.percent
            self.text = text or self.text
            try:
                self.pipe.stdin.write('{} {}\n'.format(
                    self.percent, self.text))
                return 1
            except IOError:
                return self.finish()

        def finish(self):
            """Last ditch to close progress bar dialog out.

            Note: Should occur at EOF signal.
            :returns: 0 if killed
            """
            self.pipe.kill()
            return 0
