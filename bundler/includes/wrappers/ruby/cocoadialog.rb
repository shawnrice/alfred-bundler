#!/usr/bin/ruby

# Ruby API for interacting with OSX dialog spawner CocoaDialog.
#
# ..module:: cocoadialog
#     :platform: MacOSX
#     :synopsis: Ruby API for interacting with OSX dialog spawner CocoaDialog.
# ..moduleauthor:: Ritashugisha <ritashugisha@gmail.com>
#
# Copyright: 2014 Ritashugisha
# License: GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>
#
# CocoaDialog is a resource which allows the user to spawn MacOSX aqua dialogs
# from the command-line. Dialogs are predefined and return input via echo.
#
# `Official Documentation <http://mstratman.github.io/cocoadialog/>`
#
# **Note**: This module is documented mirroring Python Sphinx documentation.
#
# -> Usage
# =============================================================================
#
# To include this api in your Ruby scripts, copy this ``cocoadialog.rb`` to a
# viable place to require.
#
# Load the CocoaDialog client:
#
#     require './cocoadialog'
#     @client = CocoaDialog.new('path to CocoaDialog.app or exec', @debug=Boolean)
#
# Now that you have access to the client, you can call specific dialogs:
#
#     my_message_box = @client.msgbox(
#         title:'My Message Box',
#         text:'Hello, World!',
#         button1:'Ok', button2:'Cancel',
#         informative_text:'Your information here...'
#         icon:'home',
#         string_output:true)
#
#     puts my_message_box
#
# If the user clicks on the "Ok" button, my_message_box will return ["Ok"]
# in this script. If, however, the user presses "Cancel", ["Cancel"] will
# be returned.
#
# **NOTE**: The included `debug` parameter is very useful for finding out why
# your specified parameters are not being shown, or why your parameters are not
# passing as valid parameters, and thus the dialog is not being spawned.
#
# All other dialogs are spawned via similar treatment as shown above.
# For more info on what parameters are available for a specifc dialog, please
# visit the `Official Documentation` or play with `debug=True` for a while.
#
# To create a progress bar dialog, you have to create a new instance for the
# progress bar object.
#
#     @my_progress_bar = ProgressBar.new(
#         @client,
#         title:'My Progress Bar',
#         text:'Hello, World!',
#         percent:0,
#         icon:'info')
#
#     (0..100).step(1) do |i|
#         @my_progress_bar.update(percent=i)
#         sleep(0.1)
#     end
#
# Whenever the progress bar reaches an EOF, the dialog with kill itself.
#
# If you plan to add the `stoppable` feature in your progress bar, you will need
# to format your loop a little differently.
#
#     @my_progress_bar = ProgressBar.new(
#         @client,
#         title:'My Progress Bar',
#         text:'Hello, World!',
#         percent:0,
#         icon:'info',
#         stoppable:true)
#
#     (0..100).step(1) do |i|
#         sleep(0.1)
#         break if @my_progress_bar.update(percent=i) == 0
#     end
#
# The `update` function, returns 1 to signify it is running. When the user stops
# the progress bar, the `finish` function is called and returns 0 instead.
#
#
# -> Revisions
# =============================================================================
# 1.0, 07-28-14: Initial release for (3.0, 0, 'beta')


module Alfred

$AUTHOR = 'Ritashugisha <ritashugisha@gmail.com>'
$DATE = '07-28-14'
$VERSION = 1.0
$COCOA_VERSION = [3.0, 0, 'beta']

require 'open3'


# Main class used for interactive with CocoaDialog.
#
# Class used to initialize the CocoaDialog interaction client.
# Client build by:
#
#    client = CocoaDialog.new('path to CocoaDialog.app or exec', @debug=Boolean)
#
# Initializes global options (Hash) and global icons (Array).
class CocoaDialog

    @@cocoa = ''
    @@debug = false
    @@global_options = {}
    @@lower_exceptions = []
    @@global_icons = []

    # Logging Function (used to emulate logging module in Python).
    #
    # Logs passed information to stdout in format:
    # [Logging Level] <Function:Line#>....Message
    #
    # :param level: Logging level
    # :param funct: Calling function
    # :param lineno: Calling line number
    # :param message: Log message
    # :type level: str
    # :type funct: str
    # :type lineno: int
    # :type message: str
    def self.log(level, funct, lineno, message)
        if @@debug
            $stdout.write "[%s] [%s:%d] [%s] %s\n" % [
                Time.now.strftime('%Y-%m-%d %H:%M:%S'),
                File.basename(__FILE__),
                lineno,
                level.upcase,
                message
            ]
        end
    end


    # CocoaDialog client object initialization.
    #
    # :param cocoa: Path to CocoaDialog.app or exec
    # :param debug: True if debugging is enabled
    # :type cocoa: str
    # :type debug: bool
    def initialize(cocoa, debug=false)
        @@cocoa = cocoa
        @@debug = debug
        if File.exist?(@@cocoa)
            if '.app'.eql?(File.extname(@@cocoa).downcase)
                @@cocoa = File.join(@@cocoa, 'Contents/MacOS/cocoadialog')
                valid_cocoa = File.exist?(@@cocoa)
            else
                valid_cocoa = File.basename(@@cocoa).downcase.eql?('cocoadialog')
            end
        else
            valid_cocoa = false
        end
        if !valid_cocoa
            self.class.log('critical', __method__, __LINE__,
                'invalid path to cocoadialog (%s)' % [@@cocoa])
            abort
        end
        @@global_options = {
            'title' => [String],
            'string_output' => [String],
            'no_newline' => [TrueClass, FalseClass],
            'width' => [Fixnum, Float],
            'height' => [Fixnum, Float],
            'posX' => [Fixnum, Float],
            'posY' => [Fixnum, Float],
            'timeout' => [Fixnum, Float],
            'timeout_format' => [String],
            'icon' => [String],
            'icon_bundle' => [String],
            'icon_file' => [String],
            'icon_size' => [Fixnum, Float],
            'icon_height' => [Fixnum, Float],
            'icon_width' => [Fixnum, Float],
            'icon_type' => [String],
            'debug' => [TrueClass, FalseClass],
            'help' => [TrueClass, FalseClass]
        }
        @@lower_exceptions = ['posX', 'posY']
        @@global_icons = [
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
    end

    # Hash modification function (used to convert keys to lowercase).
    #
    # :param passed: Hash to be modified
    # :type passed: hash
    # :returns: Modified hash
    # :rtype: hash
    def self._passed_lower(passed)
        new_passed = {}
        passed.each_pair do |k,v|
            unless @@lower_exceptions.include? k
                new_passed.merge!({k.downcase => v})
            else
                new_passed.merge!({k => v})
            end
        end
        return new_passed
    end

    def _format_notify(passed)
        valid_x_placement = ['center', 'right', 'left']
        valid_y_placement = ['center', 'top', 'bottom']

        # Cleanup for passed hexadecimal colors. CocoaDialog only accpets
        # numbers (xxx or xxxxxx), so just in case users get crazy, we
        # will re.match it
        [
            'text_color', 'border_color',
            'background_top','background_bottom'
        ].each do |i|
            if passed.keys.include? i.to_sym
                hex_match = /^(.*?)(?<hex>[0-9a-fA-F]{3}{1,2})$/.match(passed[i.to_sym])
                if hex_match != nil
                    passed[i.to_sym] = hex_match[:hex]
                else
                    self.class.log('warning', __method__, __LINE__,
                        'removing invalid (%s), got (%s), expected (#XXX or #XXXXXX)' % [
                            i, passed[i.to_sym]])
                    passed.delete(i.to_sym)
                end
            end
        end

        # Cleanup/validation for x_placement and y_placement arguments.
        [
            ['x_placement', valid_x_placement],
            ['y_placement', valid_y_placement]
        ].each do |i|
            if (passed.keys.include? i[0].to_sym) &&
                !(i[1].include? passed[i[0].to_sym])
                self.class.log('warning', __method__, __LINE__,
                    'removing invalid (%s), got (%s), expected (%s)' % [
                        i[0], passed[i[0].to_sym], i[1].join(' or ')])
                passed.delete(i[0].to_sym)
            end
        end
        return passed
    end


    # Run a subprocess and return the output
    #
    # :param passed: Process to be run
    # :type passed: str
    # :returns: Output of process
    # :rtype: str
    def _run_subprocess(process)
        if process.class.eql?(Array)
            process = process.join(' ')
        end
        return `#{process}`
    end

    # Validate passed dialog arguments.
    #
    # :param passed: Passed dialog arguments
    # :param custom_options: Dialog specific valid options
    # :type passed: hash
    # :type custom_options: hash
    # :returns: True if passed options are valid
    # :rtype: bool
    def _valid_options(passed, custom_options)
        @_is_valid = true

        # Join valid global options with dialog specific options
        valid_passed = custom_options['custom_options'].merge(@@global_options)
        _funct = custom_options['dialog_name']

        # First, validate that the passed arguments are allows and of valid type
        passed.keys.each do |passed_key|
            if valid_passed.keys.include? passed_key.to_s
                unless valid_passed[passed_key.to_s].include? passed[passed_key].class
                    self.class.log('warning', __method__, __LINE__,
                        'removing (%s) invalid type, expected (%s), got (%s)' % [
                            passed_key.to_s,
                            valid_passed[passed_key.to_s].join(' or '),
                            passed[passed_key].class])
                    passed.delete(passed_key)
                end
            else
                self.class.log('warning', __method__, __LINE__,
                    'removing (%s) invalid parameter, available are (%s)' % [
                        passed_key.to_s, valid_passed.keys.join(', ')])
                passed.delete(passed_key)
            end
        end

        # Second, check that the required options are passed and valid
        custom_options['required_options'].each do |required_key|
            if passed.keys.include? required_key.to_sym
                ['items', 'with_extensions', 'checked', 'disabled'].each do |_lists|
                    if _lists.eql?(required_key.downcase)
                        if passed[_lists.to_sym].length <= 0
                            self.class.log('error', __method__, __LINE__,
                                'length of items must be > 0')
                            @_is_valid = false
                        end
                    end
                end
            else
                self.class.log('error', __method__, __LINE__,
                    'missing required parameter (%s)' % [required_key])
                @_is_valid = false
            end
        end

        # Lastly, if an icon is include, check that it is a valid icon from global icons
        if passed.has_key?('icon'.to_sym)
            unless @@global_icons.include? passed[:icon]
                self.class.log('warning', __method__, __LINE__,
                    'removing invalid icon (%s), available are (%s)' % [
                        passed[:icon], @@global_icons.join(', ')])
                passed.delete(:icon)
            end
        end

        return @_is_valid
    end

    # Display the passed dialog.
    #
    # :param funct: Dialog name
    # :param passed: Dialog arguments
    # :param return_process: Returns process list if True
    # :type funct: str
    # :type passed: hash
    # :type return_process: bool
    # :returns: Output of dialog
    # :rtype: str
    def _display(funct, passed, return_process=false)
        @process = ['\'%s\'' % @@cocoa, funct.to_s.tr('_', '-')]
        # Ensure that passed argument's keys are formated as --$key
        new_passed = {}
        passed.each_pair do |k,v|
            new_passed.merge!({'--' + k.to_s.tr('_', '-') => v})
        end
        passed = new_passed

        # Make sure keys and arguments are added to the process in the correct way
        #
        # Strings and numbers are added by (--key "value")
        # Lists are added by (--key "value1" "value2" ...)
        # Booleans are added by (--key)
        passed.each_pair do |k,v|
            if v.class.eql?(String) || v.class.eql?(Fixnum) ||
                v.class.eql?(Float) || (v.class.eql?(Array) && v.length > 0)
                @process << k
                if v.class.eql?(Array)
                    @process.push(*v.collect {|x| "\"#{x}\""})
                else
                    @process << '"%s"' % v.to_s
                end
            else
                if (v.class.eql?(TrueClass) || v.class.eql?(FalseClass)) && v
                    @process << k
                end
            end
        end
        unless return_process
            self.class.log('info', __method__, __LINE__, @process)
            return _run_subprocess(@process.join(' ')).split("\n")
        else
            return @process
        end
    end

    # Dialog type bubble
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def bubble(**_passed)
        custom_options = {
            'no_timeout' => [TrueClass, FalseClass],
            'alpha' => [Fixnum, Float],
            'x_placement' => [String],
            'y_placement' => [String],
            'text' => [String],
            'text_color' => [String],
            'border_color' => [String],
            'background_top' => [String],
            'background_bottom' => [String]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['title', 'text'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            _passed = self._format_notify(_passed)
            _display(__method__, _passed)
        end
    end

    # Dialog type notify
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def notify(**_passed)
        custom_options = {
            'no_timeout' => [TrueClass, FalseClass],
            'description' => [String],
            'no_growl' => [TrueClass, FalseClass],
            'alpha' => [Fixnum, Float],
            'x_placement' => [String],
            'y_placement' => [String],
            'text_color' => [String],
            'border_color' => [String],
            'background_top' => [String],
            'background_bottom' => [String],
            'fh' => [TrueClass, FalseClass] # Unkown option
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['title', 'description'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            _passed = self._format_notify(_passed)
            _display(__method__, _passed)
        end
    end

    # Dialog type checkbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def checkbox(**_passed)
        custom_options = {
            'label' => [String],
            'checked' => [Array],
            'columns' => [Fixnum],
            'disabled' => [Array],
            'items' => [Array],
            'rows' => [Fixnum],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1', 'items'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type radio
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def radio(**_passed)
        custom_options = {
            'label' => [String],
            'selected' => [Fixnum],
            'columns' => [Fixnum],
            'disabled' => [Array],
            'items' => [Array],
            'rows' => [Fixnum],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1', 'items'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type slider
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def slider(**_passed)
        custom_options = {
            'label' => [String],
            'always_show_value' => [TrueClass, FalseClass],
            'min' => [Fixnum, Float],
            'max' => [Fixnum, Float],
            'ticks' => [Fixnum, Float],
            'slider_label' => [String],
            'value' => [Fixnum, Float],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String],
            'return_float' => [TrueClass, FalseClass]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1', 'min', 'max'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end



    # Dialog type msgbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def msgbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String],
            'no_cancel' => [TrueClass, FalseClass],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type ok_msgbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def ok_msgbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'no_cancel' => [TrueClass, FalseClass],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => [],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type yesno_msgbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def yesno_msgbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'no_cancel' => [TrueClass, FalseClass],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => [],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type inputbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def inputbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String],
            'float' => [TrueClass, FalseClass],
            'no_show' => [TrueClass, FalseClass]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type standard_inputbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def standard_inputbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'float' => [TrueClass, FalseClass],
            'no_show' => [TrueClass, FalseClass]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => [],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type secure_inputbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def secure_inputbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type secure_standard_inputbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def secure_standard_inputbox(**_passed)
        custom_options = {
            'text' => [String],
            'informative_text' => [String],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => [],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type fileselect
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def fileselect(**_passed)
        custom_options = {
            'text' => [String],
            'select_directories' => [TrueClass, FalseClass],
            'select_only_directories' => [TrueClass, FalseClass],
            'packages_as_directories' => [TrueClass, FalseClass],
            'select_multiple' => [TrueClass, FalseClass],
            'with_extensions' => [Array],
            'with_directory' => [String],
            'with_file' => [String]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => [],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type filesave
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def filesave(**_passed)
        custom_options = {
            'text' => [String],
            'packages_as_directories' => [TrueClass, FalseClass],
            'no_create_directories' => [TrueClass, FalseClass],
            'with_extensions' => [Array],
            'with_directory' => [String],
            'with_file' => [String]
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => [],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type textbox
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def textbox(**_passed)
        custom_options = {
            'text' => [String],
            'text_from_file' => [String],
            'informative_text' => [String],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String],
            'editable' => [TrueClass, FalseClass],
            'focus_textbox' => [TrueClass, FalseClass],
            'selected' => [TrueClass, FalseClass],
            'scroll_to' => [String],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type dropdown
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def dropdown(**_passed)
        custom_options = {
            'text' => [String],
            'items' => [Array],
            'pulldown' => [TrueClass, FalseClass],
            'button1' => [String],
            'button2' => [String],
            'button3' => [String],
            'exit_onchange' => [TrueClass, FalseClass],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['button1', 'items'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end

    # Dialog type standard_dropdown
    #
    # :param _passed: Dialog arguments
    # :type _passed: hash
    # :returns: Output of dialog
    # :rtype: str
    def standard_dropdown(**_passed)
        custom_options = {
            'text' => [String],
            'items' => [Array],
            'pulldown' => [TrueClass, FalseClass],
            'exit_onchange' => [TrueClass, FalseClass],
            'float' => [TrueClass, FalseClass],
        }
        custom_options = {
            'dialog_name' => __method__,
            'required_options' => ['items'],
            'custom_options' => custom_options
        }
        _passed = self.class._passed_lower(_passed)
        if _valid_options(_passed, custom_options)
            return _display(__method__, _passed)
        end
    end
end


# CocoaDialog progress bar implementation
#
# Since Ruby **does not** support nested classes, we have to build progress bar
# outside of the client.
#
# Progress bar client build:
#     @client = CocoaDialog.new('path to CocoaDialog.app or exec', @debug=Boolean)
#     @progress_bar = ProgressBar.new(@client, **Dialog Arguments**)
#
# Progress bar class opens own subprocess with open PIPE.
class ProgressBar

    @@cocoa_object = nil
    @@percent      = nil
    @@text         = nil
    @@pipe_in      = nil
    @@pipe_out     = nil

    # Progress bar class constructor.
    #
    # :param cocoa_object: CocoaDialog object
    # :type cocoa_object: CocoaDialog
    # :param _passed: Progress bar arguments
    # :type _passed: hash
    def initialize(cocoa_object, _passed)
        @@cocoa_object = cocoa_object
        unless @@cocoa_object.class.eql?(CocoaDialog)
            $stdout.write("[%-8s] <%s:%d>....%s\n" % [
                'CRITICAL', __method__, __LINE__, 'invalid cocoadialog client'])
            abort
        end
        custom_options = {
            'text' => [String],
            'percent' => [Fixnum, Float],
            'indeterminate' => [TrueClass, FalseClass],
            'float' => [TrueClass, FalseClass],
            'stoppable' => [TrueClass, FalseClass]
        }
        custom_options = {
            'dialog_name' => self.class.name.downcase,
            'required_options' => ['percent', 'text'],
            'custom_options' => custom_options
        }
        if @@cocoa_object._valid_options(_passed, custom_options)
            @@percent = _passed[:percent]
            @@text = _passed[:text]
            @process = @@cocoa_object._display(
                self.class.name.downcase, _passed, @return_process=true
            ).join(' ')
            @@pipe_in, @@pipe_out = Open3.popen2(@process)
            @@pipe_out
        end
    end

    # Update function for progress bar.
    #
    # :param percent: Percent value to be updated
    # :param text: Text string to be updated
    # :type percent: int
    # :type text: str
    # :returns: 1 if running
    # :rtype: int
    def update(percent=nil, text=nil)
        @@percent = percent || @@percent
        @@text = text || @@text
        begin
            @@pipe_in.puts("%s %s\n" % [@@percent, @@text])
            return 1
        rescue
            finish()
        end
    end

    # Kill progress bar.
    #
    # :returns: 0 if dead
    # :rtype: int
    def finish()
        @@pipe_in.close
        @@pipe_out.close
        return 0
    end
end

end # End module