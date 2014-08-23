#!/usr/bin/ruby

#  Ruby wrapper for the Alfred Bundler
#
# ..module:: Alfred
#   :platform: MaxOSX
# ..moduleauthor: The Alfred Bundler Team
#
#  Main Ruby file for the Alfred Bundler.
#
#  This file is part of the Alfred Bundler, released under the MIT licence.
#  Copyright (c) 2014 The Alfred Bundler Team
#  See https://github.com/shawnrice/alfred-bundler for more information
#
#  @copyright  The Alfred Bundler Team 2014
#  @license    http://opensource.org/licenses/MIT  MIT
#  @version    Taurus 1
#  @since      File available since Taurus 1

# All of these are native and necessary for the bundler to work
require 'uri'
require 'fileutils'
require 'open-uri'
require 'logger'
require 'pathname'
require 'digest'

# Namespace for the Alfred Bundler
#
# @see http://shawnrice.github.io/alfred-bundler Documentation
# @author The Alfred Bundler Team
# @since Taurus 1
#
module Alfred

  # Exception class for various problems when installing the Alfred Bundler
  #
  # @see Bundler#install_bundler
  #
  # @author The Alfred Bundler Team
  #
  class BundlerInstallError < RuntimeError

    attr :reason

    def initialize(reason)
      @reason = reason
    end

  end

  # External wrapper for the Bundler's {Internal internal class} (that does all
  # the work).
  #
  # @see Internal
  # @see Icon
  # @see Log
  # @see HTTP
  #
  # @author The Alfred Bundler Team
  #
  class Bundler

    # The Bundler's data directory
    #
    # `~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-taurus`
    attr_reader :data

    # @!group Creation

    # The class constructor
    #
    # Sets up the bundler for use and intiantiates the internal bundler object;
    # also, installs the bundler if it isn't already installed.
    #
    # @param options Hash a set of options to customize the behavior of the
    # bundler instance
    #
    # @return [type] [description]
    def initialize(options = {})

    # The major version of the Bundler
    @major_version = 'devel'

    # The user's home folder
    @home  = File.expand_path('~/')

    # The Bundler's data directory
    @data  = File.join(@home, 'Library', 'Application Support', 'Alfred 2',
              'Workflow Data', 'alfred.bundler-' + @major_version)

    # the Bunder's cache directory
    @cache = File.join(@home, 'Library', 'Caches',
              'com.runningwithcrayons.Alfred-2', 'Workflow Data',
              'alfred.bundler-' + @major_version)

    # the name of the workflow
    @name  = get_workflow_name.chomp

    # For development, we'll use the AlfredBundler.rb file that we're editing
    @bundler = File.join(@data, 'bundler', 'AlfredBundler.rb')
    # @bundler = File.join(File.dirname(__FILE__), '..', 'AlfredBundler.rb' )

      unless File.exists? @bundler
        self.install_bundler unless confirm_installation == 'Proceed'
        installed = true
      end

      ####
      #### @TODO REMOVE BEFORE PUSHING
      ####
      # For testing...
      @bundler = File.join(File.dirname(__FILE__), '..', 'AlfredBundler.rb' )
      # End for testing...

      require_relative @bundler

      # Initialize an internal object
      @internal = Internal.new(@data, @cache)
      # Send a notification informing that the bundler has been installed
      @internal.notify("#{@name} Setup", "The Alfred Bundler has been installed.")
    end

    # @!endgroup

    # @!group Magic (router handling)

    # Sends everything unrecognized to the bundler backend
    #
    # @see Internal
    #
    # @param name String the unrecognized method
    # @param *arguments Array an array of the arguments
    #
    # @return Mixed whatever the Bundler backend sends to us
    def method_missing(name, *arguments)
      @internal.send("#{name}", *arguments)
    end

    #@!endgroup

    # @!group Install Functions

    # Creates the necessary directories for the Bundler to function
    #
    # @see #install_bundler
    #
    def make_install_directories
      directories = [
        @data,
        File.join(@data,  'data'),
        File.join(@data,  'data', 'logs'),
        @cache,
        File.join(@cache, 'install'),
        File.join(@cache, 'php'),
        File.join(@cache, 'python'),
        File.join(@cache, 'ruby'),
        File.join(@cache, 'misc'),
        File.join(@cache, 'icns'),
        File.join(@cache, 'color'),
        File.join(@cache, 'utilities')
      ]

      directories.each { |dir| FileUtils.mkpath(dir) unless File.directory?(dir) }
    end

    # Installs the Alfred Bundler
    #
    def install_bundler

      # Make all the directories
      self.make_install_directories()

      # See if we're getting the head or the release
      if defined? ENV['AB_BRANCH']
        suffix = ".zip"
      else
        suffix = "-latest.zip"
      end

      # Bundler Install URLs
      # Bundler URLs have to be hard coded in the bundlet
      bundler_urls = ["https://github.com/shawnrice/alfred-bundler/archive/" + @major_version + suffix,
                      "https://bitbucket.org/shawnrice/alfred-bundler/get/"  + @major_version + suffix]

      install_path = File.join(@cache, 'install', 'bundler.zip')
      bundler_urls.each do |server|
        begin
          File.open(install_path, 'wb') do |file|
            file.write open(server).read
          end
        rescue Exception => e
          puts e
        else
          break
        end
      end

      zip = unzip("bundler.zip", @cache + '/install')

      unless :zip
        File.delete(@cache + "/install/bundler.zip")
        raise Alfred::BundlerInstallError('corrupt'),
          "Bundler downloaded zip file corrupted."
      end

      # Move the bundler installation into the data directory
      Dir[@cache + '/install/*'].each { |dir|
        FileUtils.move("#{dir}/bundler", "#{@data}") if File.directory? "#{dir}/bundler"
      }

    end

    # Gets the appropriate icon for the AppleScript dialog
    #
    # First, try to use the workflow's `icon.png` file but fallback to a system
    # icon.
    #
    # @see #construct_confirm_dialog
    #
    # @return String path to an icon
    def get_confirm_dialog_icon
      icon =  ":System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:"
      icon << "SideBarDownloadsFolder.icns"
      icon = File.expand_path('icon.png').gsub('/', ':') if File.exists? 'icon.png'
      icon[0] = '' # Remove the first semi-colon
      return icon
    end

    # Cobbles together an AppleScript dialog to confirm installation
    #
    # @see #install_bundler
    # @see #do_confirm_dialog
    #
    # @return String the text of a full AppleScript dialog
    def construct_confirm_dialog
      name = get_workflow_name.chomp
      icon = get_confirm_dialog_icon
      script =  "display dialog \"#{text}\" "
      script << "\"#{name} needs to install additional components, which will be "
      script << "placed in the Alfred storage directory and will not interfere "
      script << "with your system.\\n\\nYou may be asked to allow some components "
      script << "to run, depending on your security settings.\\n\\nYou can "
      script << "decline this installation, but #{name} may not work without them. "
      script << "There will be a slight delay after accepting.\""
      script << "buttons {\"More Info\",\"Cancel\",\"Proceed\"} default button 3 "
      script << "with title \"#{name} Setup\" "
      script << "with icon file \"#{icon}\""
      return script
    end

    # Reads the name of the workflow from the `info.plist` file
    #
    # @return String the name of the workflow
    def get_workflow_name
      return `/usr/libexec/PlistBuddy -c 'Print :name' 'info.plist'`
    end

    # Grabs the code for an AppleScript dialog and executes it
    #
    # @see #confirm_installation
    #
    # @return String the button pressed on the applescript
    def do_confirm_dialog
      dialog = construct_confirm_dialog
      return `osascript -e '#{dialog}'`.gsub('button returned:', '')
    end

    # Asks the user for confirmation to install the Alfred Bundler
    #
    # Uses an AppleScript dialog to get confirmation
    #
    # @see #install_bundler
    #
    # @raise Alfred::BundlerInstallError when user asks for more information
    # @raise Alfred::BundlerInstallError when the user denies installation
    #
    # @return Bool either return `true` or raise an exception
    def confirm_installation
      result = do_confirm_dialog.chomp
      if result == 'More Info'
        system("open 'https://github.com/shawnrice/alfred-bundler/wiki/What-is-the-Alfred-Bundler'")
        raise Alfred::BundlerInstallError.new('More Info'),
          'User canceled installation of the Alfred Bundler by looking for more info.'
      elsif result == 'Proceed'
        return true
      end
      raise Alfred::BundlerInstallError.new('Deny'),
        'User canceled installation of the Alfred Bundler.'
    end

    # @!endgroup

    # @!group Helper Functions

    # Unzips a file using a shell command
    #
    # @param file String a path to the file to unzip
    # @param destination String a path to the destination where the file will
    #   be unzipped
    #
    # @return Int exit status of the unzip action
    def unzip(file, destination)
      command = "cd \"#{destination}\"; unzip -oq #{file}; cd - 1>&2 > /dev/null"
      success = system(command)
      success && $?.exitstatus == 0
    end

    # Reads a value from a plist
    #
    # @param key String the key in a plist
    # @param plist String path to the plist file
    #
    # @return String the value of the key to be read
    def read_plist_value(key, plist)
      return `/usr/libexec/PlistBuddy -c 'Print :#{key}' '#{plist}'`
    end

    #@!endgroup

  end
end