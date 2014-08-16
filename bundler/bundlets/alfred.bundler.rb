#!/bin/ruby
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

# This is very experimental code written by some people who don't really know ruby well.
# Watch it develop.

# Can we split this into two files like the other bundlers? Then we can abstract it all the
# more in order to make this work out well.

require 'json'
require 'fileutils'
require 'open-uri'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
require 'AlfredBundler'

module Alfred

  class Bundler
    include AlfredBundler
    # @major_version = "devel"
    # @data = File.expand_path(
    # 	"~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version)
    # @cache = File.expand_path(
    # 	"~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" + @major_version)
    def initialize
      if defined? ENV['AB_BRANCH']
        @major_version = ENV['AB_BRANCH']
      else
        @major_version = "devel"
      end

      @home = File.expand_path("~/")
      @data = @home + "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version
      @cache = @home + "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" + @major_version

      if defined? ENV['alfred_version']
        @alfred_theme = ENV['alfred_theme']
        @alfred_theme_background = ENV['alfred_theme_background']
        @alfred_preferences = ENV['alfred_preferences']
        @alfred_preferences_localhash = ENV['alfred_preferences_localhash']
        @alfred_workflow_uid = ENV['alfred_workflow_uid']
      end

      # Add our local gem repository
      @gem_dir = @data + "/data/assets/ruby/gems"
      $LOAD_PATH.unshift @gem_dir
      # The below line is just for easier development purposes
      #
      # Should there be a better test?
      install_bundler	unless File.exists?(@data + "/bundler/AlfredBundler.rb")

      # $LOAD_PATH.unshift @data + "/bundler"
      # $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
      # require 'AlfredBundler'

    end


    # This is the function to install the bundler
    def install_bundler()
      # Make the bundler paths
      FileUtils.mkpath(@data) unless File.directory?(@data)
      FileUtils.mkpath(@cache) unless File.directory?(@cache)

      # Check for an Internet connection
      unless server_test("http://www.google.com")
        abort("ERROR: Cannot install Alfred Bundler because there is no Internet connection.")
      end

      require 'uri'

      # Bundler Install URLs
      # I added a bundler backup at Bitbucket: https://bitbucket.org/shawnrice/alfred-bundler
      # bundler_urls = IO.readlines("meta/bundler_servers")
      # Bundler URLs have to be hard coded in the wrapper
      if defined? ENV['AB_BRANCH']
        suffix = "-latest.zip"
      else
        suffix = ".zip"
      end

      bundler_urls = ["https://github.com/shawnrice/alfred-bundler/archive/" + @major_version + suffix,
                      "https://bitbucket.org/shawnrice/alfred-bundler/get/" + @major_version + suffix]
      url = bundler_urls.each do |x|
        server = URI.parse(x)
        if server_test("#{server.scheme}://#{server.host}")
          break x
        end
      end

      # Pausing this until we decide to stay with zip or move to git

      # Get the file if it doesn't exist
      open(@cache + "/bundler.zip", 'wb') do |file|
        file << open(url).read
      end
      zip = unzip("bundler.zip", @cache)

      unless :zip
        File.delete(@cache + "/bundler.zip")
        abort("ERROR: Cannot install Alfred Bundler -- bad zip file.")
      end

      # Theoretically, this will install the bundler
      command = "bash '" + @cache + "/alfred-bundler-" + @major_version + "/bundler/meta/installer.sh'"
      success = system(command)
      success && $?.exitstatus == 0
    end

    # This is real fucking inelegant, but we can't assume that the
    # native gems are available to unzip files, so we'll go through the system
    def unzip(file, destination)
      command = "cd \"#{destination}\"; unzip -oq #{file}; cd -"
      success = system(command)
      success && $?.exitstatus == 0
    end

  end

end


if __FILE__ == $0
  name  = 'align-center'
  color = '2321ee'
  font  = 'fontawesome'

  bundler = Alfred::Bundler.new


  ### TEST CASES
  ########################


  # PASSING

  # puts bundler.load('Pashua', 'default', 'utility')
  # puts bundler.load_utility('Pashua', 'default')
  # bundler.load_gem('zip', '2.0.2')
  icon = File.join( File.expand_path(File.dirname(__FILE__)), '..', 'meta', 'icons', 'bundle.icns')

  # For some reason, this doesn't work when there are spaces in the paths — either
  # quoted or escaped
  bundler_icon = File.expand_path("~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/bundler/meta/icons/bundle.icns")
  puts bundler_icon
  options = {
    "sender" => "com.runningwithcrayons.Alfred-2",
    "subtitle" => "This is a subtitle",
    "appIcon" => bundler_icon
  }

  bundler.notify('Title','Message', options)
  puts bundler.icon(font, color, name)

  # FAILING

  # bundler.load_gem('rspec')
  # bundler.load_gems([['zip'], ['test', 2]]) # This will fail because there is no test gem v 2
end