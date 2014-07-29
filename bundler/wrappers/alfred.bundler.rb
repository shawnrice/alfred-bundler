#!/bin/ruby

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
      @major_version = "devel"
      @home = File.expand_path("~/")
      @data = @home + "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version
      @cache = @home + "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" + @major_version

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
      # Make the bundler path
      FileUtils.mkpath(@data) unless File.directory?(@data)

      # Check for an Internet connection
      unless server_test("http://www.google.com")
        abort("ERROR: Cannot install Alfred Bundler because there is no Internet connection.")
      end

      require 'uri'

      # Bundler Install URLs
      # I added a bundler backup at Bitbucket: https://bitbucket.org/shawnrice/alfred-bundler
      # bundler_urls = IO.readlines("meta/bundler_servers")
      # Bundler URLs have to be hard coded in the wrapper
      bundler_urls = ["https://github.com/shawnrice/alfred-bundler/archive/" + @major_version + "-latest.zip",
                      "https://bitbucket.org/shawnrice/alfred-bundler/get/" + @major_version + "-latest.zip"]
      url = bundler_urls.each do |x|
        server = URI.parse(x)
        if server_test("#{server.scheme}://#{server.host}")
          break x
        end
      end
      FileUtils.mkpath(@cache) unless File.directory?(@cache)
      # Pausing this until we decide to stay with zip or move to git

      # Get the file if it doesn't exist
      open(@cache + "/bundler.zip", 'wb') do |file|
        file << open(url).read
      end
      zip = unzip("bundler.zip", @cache)

      unless :zip
        abort("ERROR: Cannot install Alfred Bundler -- bad zip file.")
      end

      # Theoretically, this will install the bundler
      command = "bash '" + @cache + "/alfred-bundler-" + @major_version + "/bundler/meta/installer.sh'"
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
