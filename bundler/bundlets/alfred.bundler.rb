#!/bin/ruby

require 'uri'
require 'fileutils'
require 'open-uri'
require 'logger'
require 'pathname'

ENV['AB_BRANCH'] = 'ruby-dev'

module Alfred

  # This is the external Bundler class
  class Bundler

    @@major_version = 'ruby-dev'

    @@home  = File.expand_path('~/')
    @@data  = File.join(@@home, 'Library', 'Application Support', 'Alfred 2',
              'Workflow Data', 'alfred.bundler-' + @@major_version)

    @@cache = File.join(@@home, 'Library', 'Caches',
              'com.runningwithcrayons.Alfred-2', 'Workflow Data',
              'alfred.bundler-' + @@major_version)

    # @@bundler = File.join(@@data, 'bundler', 'AlfredBundler.rb')
    @@bundler = File.join(File.dirname(__FILE__), '..', 'AlfredBundler.rb' )

    # The class constructor
    def initialize

      unless File.exists? @@bundler
        ### Let's reset everything here...
        if File.directory?(@@data)
          command = "rm -fR '#{@@data}'"
          success = system(command)
        end
        if File.directory?(@@cache)
          command = "rm -fR '#{@@cache}'"
          success = system(command)
        end

        ### And let's reinstall
        self.install_bundler
      end

      # @@bundler
      require_relative @@bundler
      # @@bundler = Alfred::Internal.new
      # require './internal.rb'

      # Initialize an internal object
      @@internal = Internal.new(@@data, @@cache)

    end

    def method_missing(name, *arguments)
      @@internal.send("#{name}", *arguments)
    end






    ######################
    #### INSTALL FUNCTIONS

    # Make the install directories
    def make_install_directories
      directories = [
        @@data,
        @@cache,
        File.join(@@cache, 'install'),
        File.join(@@cache, 'php'),
        File.join(@@cache, 'python'),
        File.join(@@cache, 'ruby'),
        File.join(@@cache, 'misc'),
        File.join(@@cache, 'icns'),
        File.join(@@cache, 'color'),
        File.join(@@cache, 'utilities'),
        File.join(@@data, 'data'),
        File.join(@@data, 'data', 'logs')
      ]

      directories.each do |dir|
        FileUtils.mkpath(dir) unless File.directory?(dir)
      end

    end

    # This is real fucking inelegant, but we can't assume that the
    # native gems are available to unzip files, so we'll go through the system
    def unzip(file, destination)
      command = "cd \"#{destination}\"; unzip -oq #{file}; cd - 1>&2 > /dev/null"
      success = system(command)
      success && $?.exitstatus == 0
    end

    def install_bundler

      # File.rename('internal.rb.old', 'internal.rb')


      self.make_install_directories()

      if defined? ENV['AB_BRANCH']
        suffix = ".zip"
      else
        suffix = "-latest.zip"
      end

      # Bundler Install URLs
      # Bundler URLs have to be hard coded in the bundlet
      bundler_urls = ["https://github.com/shawnrice/alfred-bundler/archive/" + @@major_version + suffix,
                      "https://bitbucket.org/shawnrice/alfred-bundler/get/"  + @@major_version + suffix]

      install_path = File.join(@@cache, 'install', 'bundler.zip')
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

      zip = unzip("bundler.zip", @@cache + '/install')

      unless :zip
        File.delete(@@cache + "/install/bundler.zip")

        # @TODO: bring in line with proper error handling
        abort("ERROR: Cannot install Alfred Bundler -- bad zip file.")
      end

      # Move the bundler installation into the data directory
      Dir[@@cache + '/install/*'].each do |dir|
        FileUtils.move("#{dir}/bundler", "#{@@data}") if File.directory? dir + '/bundler'
      end

    end




    #### INSTALL FUNCTIONS
    ######################

  end
end
