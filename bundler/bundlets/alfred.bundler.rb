#!/bin/ruby

# All of these are native
require 'uri'
require 'fileutils'
require 'open-uri'
require 'logger'
require 'pathname'
require 'digest'


#
# [module description]
#
# @author [Sven]
#
module Alfred

  class BundlerInstallError < RuntimeError

    attr :reason

    def initialize(reason)
      @reason = reason
    end

  end

  #
  # [class description]
  #
  # @author [Sven]
  #
  class Bundler

    attr_reader :data

    #
    # [initialize description]
    # @param options = {} [type] [description]
    #
    # @return [type] [description]
    def initialize(options = {})

    @major_version = 'devel'

    @home  = File.expand_path('~/')
    @data  = File.join(@home, 'Library', 'Application Support', 'Alfred 2',
              'Workflow Data', 'alfred.bundler-' + @major_version)

    @cache = File.join(@home, 'Library', 'Caches',
              'com.runningwithcrayons.Alfred-2', 'Workflow Data',
              'alfred.bundler-' + @major_version)

    @name  = get_workflow_name.chomp


    # For development, we'll use the AlfredBundler.rb file that we're editing
    @bundler = File.join(@data, 'bundler', 'AlfredBundler.rb')
    # @bundler = File.join(File.dirname(__FILE__), '..', 'AlfredBundler.rb' )

      # unless File.exists? @bundler
        ## Let's reset everything here...
        if File.directory?(@data)
          command = "rm -fR '#{@data}'"
          success = system(command)
        end
        if File.directory?(@cache)
          command = "rm -fR '#{@cache}'"
          success = system(command)
        end

        ### And let's reinstall
        self.install_bundler unless confirm_installation == 'Proceed'
        installed = true
      end

      # For testing...
      @bundler = File.join(File.dirname(__FILE__), '..', 'AlfredBundler.rb' )
      # End for testing...

      require_relative @bundler

      # Initialize an internal object
      @internal = Internal.new(@data, @cache)
      @internal.notify("#{@name} Setup", "The Alfred Bundler has been installed.")
    end

    def method_missing(name, *arguments)
      @internal.send("#{name}", *arguments)
    end

    #
    # [read_plist_value description]
    # @param key [type] [description]
    # @param plist [type] [description]
    #
    # @return [type] [description]
    def read_plist_value(key, plist)
      return `/usr/libexec/PlistBuddy -c 'Print :#{key}' '#{plist}'`
    end

    # @!group Install Functions


    #
    # [make_install_directories description]
    #
    # @return [type] [description]
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

      directories.each do |dir|
        FileUtils.mkpath(dir) unless File.directory?(dir)
      end

    end

    # This is real fucking inelegant, but we can't assume that the
    # native gems are available to unzip files, so we'll go through the system

    #
    # [unzip description]
    # @param file [type] [description]
    # @param destination [type] [description]
    #
    # @return [type] [description]
    def unzip(file, destination)
      command = "cd \"#{destination}\"; unzip -oq #{file}; cd - 1>&2 > /dev/null"
      success = system(command)
      success && $?.exitstatus == 0
    end


    #
    # [install_bundler description]
    #
    # @return [type] [description]
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

        # @TODO: bring in line with proper error handling
        abort("ERROR: Cannot install Alfred Bundler -- bad zip file.")
      end

      # Move the bundler installation into the data directory
      Dir[@cache + '/install/*'].each do |dir|
        FileUtils.move("#{dir}/bundler", "#{@data}") if File.directory? dir + '/bundler'
      end

    end

    def get_confurm_dialog_icon
      icon = ":System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:SideBarDownloadsFolder.icns"
      icon = File.expand_path('icon.png').gsub('/', ':') if File.exists? 'icon.png'
      icon[0] = '' # Remove the first semi-colon
      return icon
    end

    def construct_confirm_dialog
      name = get_workflow_name.chomp
      icon = get_confurm_dialog_icon
      text = "#{name} needs to install additional components, which will be placed in the Alfred storage directory and will not interfere with your system.\\n\\nYou may be asked to allow some components to run, depending on your security settings.\\n\\nYou can decline this installation, but #{name} may not work without them. There will be a slight delay after accepting."
      return "display dialog \"#{text}\" buttons {\"More Info\",\"Cancel\",\"Proceed\"} default button 3 with title \"#{name} Setup\" with icon file \"#{icon}\"";
    end

    def get_workflow_name
      return `/usr/libexec/PlistBuddy -c 'Print :name' 'info.plist'`
    end

    def do_confirm_dialog
      dialog = construct_confirm_dialog
      return `osascript -e '#{dialog}'`.gsub('button returned:', '')
    end

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


  end
end