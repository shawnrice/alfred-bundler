#!/usr/bin/ruby

# Ruby API for interacting with OSX notification spawner TerminalNotifier.
#
# ..module:: terminalnotifier
#     :platform: MacOSX
#     :synopsis: Ruby API for interacting with OSX notification spawner TerminalNotifier.
# ..moduleauthor:: Ritashugisha <ritashugisha@gmail.com>
#
# Copyright: 2014 The Alfred Bundler Team
# License: MIT <http://opensource.org/licenses/MIT>
#
# Terminal Notifier is a resource which allows the user to spawn MacOSX notifications
# from the command-line. Notifications return no information.
#
# `Official Documentation <https://github.com/alloy/terminal-notifier>`_.
# `License GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>`_.
#
# Design decisions were made to improve simplicity in the implementation of the API.
#
# **Note**: This module is documented mirroring Python Sphinx documentation.
#
# -> Usage
# =============================================================================
#
# To include this api in your Ruby scripts, copy this ``terminalnotifier.rb``
# to a viable place to require.
#
# Load the TerminalNotifier client:
#
#     require './terminalnotifier'
#     @client = TerminalNotifier.new('path to terminal-notifer.app or exec', @debug=Boolean)
#
# Now that you have access to the client, you can call a notification:
#
#     my_notification = @client.notifiy(
#         title:'My Notification',
#         subtitle:'Hello, World!',
#         message:'Have a nice day!',
#         sender:'com.apple.Finder')
#
# **NOTE**: The included `debug` parameter is very useful for finding out why
# your specified parameters are not being shown, or why your parameters are not
# passing as valid parameters, and thus the dialog is not being spawned.
#
#
# -> Revisions
# =============================================================================
# 1.0, 07-28-14: Initial release

$AUTHOR = 'The Alfred Bundler Team'
$DATE = '07-28-14'
$VERSION = 1.0

module Alfred
# Main class used for interaction with TerminalNotifier.
#
# Class used to initialize the TerminalNotifier interaction client.
# Client build by:
#
#    client = TerminalNotifier.new('path to terminal-notifier.app or exec', @debug=Boolean)
#
# Initializes valid and required options.
class Terminalnotifier

    @@notifier         = ''
    @@debug            = false
    @@valid_options    = {}
    @@required_options = []

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

    # TerminalNotifier client object initialization.
    #
    # :param notifier: Path to terminal-notifier.app or exec
    # :param debug: True if debugging is enabled
    # :type notifier: str
    # :type debug: bool
    def initialize(notifier, debug=false)
        @@notifier = notifier
        @@debug = debug
        if File.exist?(@@notifier)
            if '.app'.eql?(File.extname(@@notifier).downcase)
                @@notifier = File.join(@@notifier, 'Contents/MacOS/terminal-notifier')
                valid_notifier = File.exist?(@@notifier)
            else
                valid_notifier = File.basename(@@notifier).downcase.eql?('terminal-notifier')
            end
        else
            valid_notifier = false
        end
        if !valid_notifier
            self.class.log('critical', __method__, __LINE__,
                'invalid path to terminal-notifier (%s)' % [@@notifier])
            abort
        end
        @@valid_options = {
            'message' => [String],
            'title' => [String],
            'subtitle' => [String],
            'sound' => [String],
            'group' => [String],
            'remove' => [String],
            'activate' => [String],
            'sender' => [String],
            'appIcon' => [String],
            'contentImage' => [String],
            'open' => [String],
            'execute' => [String]
        }
        @@required_options = ['message']
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
        return exec(process)
    end

    # Validate passed notification arguments.
    #
    # :param passed: Passed notification arguments
    # :type passed: hash
    # :returns: True if passed options are valid
    # :rtype: bool
    def _valid_options(passed)
        _is_valid = true

        # First we validate that all $passed options are valid options and \
        # are the coresponding valid type
        passed.keys.each do |passed_key|
            if @@valid_options.keys.include? passed_key.to_s
                unless @@valid_options[passed_key.to_s].include? passed[passed_key].class
                    self.class.log('warning', __method__, __LINE__,
                        'removing (%s) invalid type, expected (%s), got (%s)' % [
                            passed_key.to_s,
                            @@valid_options[passed_key.to_s].join(' or '),
                            passed[passed_key].class])
                    passed.delete(passed_key)
                end
            else
                self.class.log('warning', __method__, __LINE__,
                    'removing (%s) invalid parameter, available are (%s)' % [
                        passed_key.to_s, @@valid_options.keys.join(', ')])
                passed.delete(passed_key)
            end
        end

        # Next we can check that the $passed options contain the required \
        # options
        @@required_options.each do |required_key|
            unless passed.keys.include? required_key.to_sym
                self.class.log('error', __method__, __LINE__,
                    'missing required parameter (%s)' % required_key)
                _is_valid = false
            end
        end

        # If the remove option is given, then we sould remove all other \
        # options in order to allow room for notification removal to occur.
        if passed.has_key?('remove'.to_sym)
            _is_valid = true
            passed.keys.each do |k|
                unless k.to_s.start_with? 'remove'
                    passed.delete(k)
                end
            end
        end

        return _is_valid
    end

    # Display the passed notification.
    #
    # :param passed: Notification arguments
    # :type passed: hash
    def _display(passed)
        @process = ['\'%s\'' % @@notifier]
        new_passed = {}
        passed.each_pair do |k,v|
            # It is important we escape the first character of every
            # value passed . This is a known bug in TN.
            new_passed.merge!({'-' + k.to_s => '"\\%s"' % v})
        end
        new_passed.each_pair do |k,v|
            (@process << [k, v]).flatten!
        end
        self.class.log('info', __method__, __LINE__, @process)
        _run_subprocess(@process.join(' '))
    end

    # Spawn a notification with passed arguments
    #
    # :param _passed: Notification arguments
    # :type _passed: hash
    def notify(_passed)
        if _valid_options(_passed)
            return _display(_passed)
        end
    end


end

end