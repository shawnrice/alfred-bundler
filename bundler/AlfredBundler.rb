#!/usr/bin/ruby

#  Ruby API for the Alfred Bundler
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

# Namespace for the Alfred Bundler
#
# @see http://shawnrice.github.io/alfred-bundler Documentation
# @author The Alfred Bundler Team
# @since Taurus 1
#
module Alfred

  # The Internal class that does all the heavy lifting for the Alfred Bundler
  #
  # Basically, the {Alfred::Bundler} class wraps around this class and passes
  # everything here to process via its
  # {Alfred::Bundler#method_missing method_missing} method.
  # That class instantiates an object of this class. Icon handling is further
  # routed to the internal {Alfred::Icon icon class}, and logging functions are
  # passed to a variety of objects instantiated by the {Alfred::Log internal
  # logging class}.
  #
  # This class handles {#load asset loading}, including {#gems gems}.
  #
  # The documentation for this class is the most important to read in order to
  # understand how the bundler works.t
  #
  # @license    http://opensource.org/licenses/MIT  MIT
  # @version    Taurus 1
  # @link http://shawnrice.github.io/alfred-bundler
  # @package AlfredBundler
  # @author The Alfred Bundler Team
  #
  class Internal

    # The Bundler's data directory
    #
    # `~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-taurus`
    attr_reader :data

    # The class constructor
    #
    # Sets up everything neede for the bundler to function
    #
    # @see Bundler
    #
    # @param data String the data path for the bundler
    # @param cache String the cache path for the bundler
    # @param options Hash a hash of options sent to customize how the
    #   bundler works
    #
    def initialize(data, cache, options = {})
      @data   = data
      @cache  = cache
      # development / debugging. remove these
      @bundle = 'foo.my.poop'
      @major_version = 'devel'
      @wf_data = File.join( File.expand_path('~/'), 'Library',
        'Application Support', 'Alfred 2', 'Workflow Data', @bundle)
      @icon = Alfred::Icon.new(@data, @cache)

      # Initialize with user log or without
      options['wf_log'] == true ? initialize_logs(true) : initialize_logs
      is_there_a_plist?

      unless ENV['alfred_version'].nil?
        self.initialize_modern
      else
        self.initialize_deprecated
      end

      # Add our local gem repository
      @gem_dir = @data + "/data/assets/ruby/gems"
      Gem.path.unshift(@gem_dir) unless Gem.path.include?(@gem_dir)
    end

    # Checks if an `info.plist` file is present
    #
    # @raise [StandardError] if no info.plist file is present
    # @return Bool
    def is_there_a_plist?
      return true if File.exists? './info.plist'
      raise StandardError('The Alfred Bundler cannot be used if no info.plist file is present.')
    end

    # Handles errors
    # @param name String the name of the missing method called
    # @param arguments Array an array of unknown arguments
    #
    # @raise [StandardError] when a bad method is called
    #
    def method_missing(name, *arguments)
      self.console("'#{name}' does not exist either externally or internally.", 'error')
      raise StandardError("#{name} is not a valid method.")
    end

    # Sets the necessary variables to function if running Alfred >= v2.4:277
    #
    def initialize_modern
      @wf_data    = ENV['alfred_workflow_data']
      @bundle     = ENV['alfred_workflow_bundleid']
      @name       = ENV['alfred_workflow_name']
    end

    # Sets the necessary variables to function if running Alfred < v2.4:277
    #
    def initialize_deprecated
      @name   = read_plist_value('name', 'info.plist')
      @bundle = read_plist_value('bundleid', 'info.plist')
    end

    # Reads a value from a plist
    # @param key String the key to read
    # @param plist String file name for the plist to read
    #
    # @return String the value of the key called for in the plist
    def read_plist_value(key, plist)
      return `/usr/libexec/PlistBuddy -c 'Print :#{key}' '#{plist}'`
    end

    # @!group Load methods

    # Loads an asset
    # @param args Array an array of arguments to load ultimately, we need
    #   `type`, `name`, `version`, `json`. Only `type` and `name` are necessary.
    #   `version` defaults to 'latest', and `json` defaults to one of the
    #   'defaults'.
    #
    # @raise [StandardError] when asset is not found
    #
    # @return String path to an asset or false when asset is not found
    def load(*args)
      args = parse_load_args(args)
      type = args['type']
      name = args['name']
      version = args['version']
      json = args['json']
      json = File.join(@data, 'bundler', 'meta', 'defaults', "#{name}.json") if json == 'default'
      unless File.exists? json
        raise StandardError("Asset #{name}, type #{type} does not exist")
      end

      # We need to deal with utilities
      if type == 'utility'
        path_hash = File.join(@cache, 'utilities', Digest::MD5.hexdigest("#{name}-#{version}-#{type}-#{json}"))
        return File.readlines(path_hash).first.chomp if File.exists? path_hash
      end

      path = File.join(@data, 'data', 'assets', type, name, version, 'invoke')
      return File.readlines(path).first.chomp if File.exists? path

      # This should install the asset; we might find a native way to do this later
      command = "'" + @data + "/bundler/bundlets/alfred.bundler.sh' '#{type}' '#{name}' '#{version}' '#{json}'"

      return `#{command}`.strip
    end

    # Loads a utility
    #
    # A wrapper function for {#load}
    #
    # @see #load
    #
    # @param args Array random arguments, takes a set of strings, an array, or
    #   a hash
    #
    # @return String path to asset
    def utility(*args)
      if args.count > 1
        args.unshift('utility')
      else
        args = args.shift
        if args.is_a? Array
          if args.count > 1
            args.unshift('utility')
          end
        elsif args.is_a? Hash
          args.merge!('type' => 'utility')
        elsif args.is_a? String
          args = {'type' => 'utility', 'name' => args}
        end
      end
      return self.load(args)
    end

    # Loads an icon
    #
    # Passes the arguments to the internal icon object to do the work.
    #
    # @see Icon#icon
    #
    # @param args Array, Strings
    #
    # @return String file path to icon
    def icon(*args)
      @icon.icon(args)
    end

    # Loads a wrapper file
    # @param wrapper String name of the wrapper
    #   currently, the only values currently accepted are `cocoadialog` and
    #   `terminalnotifier`
    # @raise StandardError when wrapper file does not exist
    def wrapper(wrapper, debug=false)
      require 'json'
      _common = JSON.parse(File.read(File.join(File.dirname(__FILE__), 
        'includes', 'wrappers', 'wrappers.json'
      )))
      _wrapper_common = wrapper.scan(/[A-Za-z0-9]/).join('').downcase
      wrapper = File.join(File.dirname(__FILE__), 'includes', 'wrappers',
        'ruby', "#{_wrapper_common}.rb")
      raise StandardError("Wrapper #{wrapper} does not exist.") unless File.exists? wrapper
      require_relative wrapper
      _wrapper_class_name = _wrapper_common.slice(0,1).capitalize + _wrapper_common.slice(1..-1)
      _wrapper_class = sprintf('Alfred::%s', _wrapper_class_name).split('::').inject(Object) {|o,c| o.const_get c}
      if _common[_wrapper_common].length > 0
        return _wrapper_class.new(self.utility(_common[_wrapper_common]), @debug=debug)
      else
        return _wrapper_class.new(@debug=debug)
      end
    end

    # Parses the arguments sent to the `load` method to make them usable
    #
    # @see #load
    # @see #utility
    #
    # @overload parse_load_args(args)
    #   @param args Hash
    #
    # @overload parse_load_args(args)
    #   @param args Array
    #
    # @overload parse_load_args(args)
    #   @param type String
    #   @param name String
    #   @param version String
    #   @param json String
    #
    # @return Hash has keys: `type`, `name`, `version`, `json`
    def parse_load_args(*args)
      args = args.shift
      args = args.shift if args.class.to_s == 'Array' && args.count == 1
      if args.class.to_s == 'Array'
        keys = ['type', 'name', 'version', 'json']
        args = Hash[keys.zip args]
      end
      args['version'] = 'latest' if args['version'].nil?
      args['json'] = 'default' if args['json'].nil?
      return args
    end

    # @!endgroup

    # @!group Gem Methods

    # Install a gem into the bundler's {#data} directory
    #
    # This method should be called, internally, only from the {#gems} method. The
    # method sends a notification to inform the user that a gem is being
    # installed because it might take a little while.
    #
    # @see #gems
    #
    # @param name String name of the gem to install
    # @param version String version of the gem
    # @raise `Gem::GemNotFoundException` when the requested gem + version
    #   cannot be found.
    #
    def install_gem(name, version = Gem::Requirement.default)
      require 'rubygems'
      require 'rubygems/dependency_installer'
      icon = File.join(@data, 'bundler', 'meta', 'icons', 'gem.png')
      self.notify('Alfred Bundler', "Installing Gem: '#{name}'\nPlease be patient.", icon)
      begin
        installer      = Gem::DependencyInstaller.new({:install_dir => "#{@gem_dir}"})
        installed_gems = installer.install name, version
      rescue Gem::GemNotFoundException
        console("Cannot install Gem #{name}. Either the name/version is bad or the Internet connection is lacking.", 'CRITICAL')
        log("Failed to install Gem #{name}.", 'CRITICAL')
        self.notify('Alfred Bundler', "Could not install Gem #{name}", icon)
      end
    end

    # Loads gems and downloads them if necessary
    #
    # If the gem cannot be found, then it will download the gem and its
    # dependencies into the bundler's {#data} directory and load it from there.
    # If they have already been downloaded, then they'll just be loaded.
    # However, you still need to `require` everything.
    #
    # @see #install_gem
    #
    # @overload gems(args)
    #   @param gems Arrays of `['gem_name']` or `['gem_name', 'gem_version']`
    #
    # @example
    #   bundler = Alfred::Bundler.new
    #   bundler.gems(['oauth'], ['plist', '~>3.1.0'])
    #   require 'plist'
    #   require 'oauth'
    #
    def gems(*gems)
      gems.each { |g|
        begin
          gem *g
        rescue LoadError
          install_gem(*g)
        end
      }
    end

    # @!endgroup

    # @!group Log Functions

    # [initialize_logs description]
    # @param user = false [type] [description]
    #
    # @return [type] [description]
    def initialize_logs( user = false )
      self.initialize_bundler_log
      self.initialize_user_log if user == true
    end

    # Creates a file log for the workflow's use
    #
    # The log is created in the workflow's data directory with the name
    #   `workflow_bundle_id.log` (accepts: `Logger::DEBUG`, `Logger::INFO`,
    #   `Logger::WARN`, `Logger::ERROR`, `Logger::FATAL`)
    #
    # @param level Object a Logger level
    #
    def initialize_user_log(level = Logger::INFO)
      @user = Alfred::Log.new(File.join(@wf_data, @bundle + '.log'), level)
    end

    #

    #
    # @param msg [type] [description]
    # @param level = 'info' [type] [description]
    #
    # @return [type] [description]
    def log(msg, level = 'info' )
      @file.send(normalize_log_level(level), msg)
    end

    #
    # [console description]
    # @param msg [type] [description]
    # @param level='info' [type] [description]
    #
    # @return [type] [description]
    def console(msg, level='info')
      @console.send(normalize_log_level(level), msg)
    end

    # Creates a console log and a file log for the bundler's use
    #
    # @param level Object a Logger level
    #   (accepts: `Logger::DEBUG`, `Logger::INFO`, `Logger::WARN`, `Logger::ERROR`,
    #   `Logger::FATAL`)
    #
    def initialize_bundler_log(level = Logger::DEBUG)
      # Create the bundler's log file
      log = File.join(@data, 'data', 'logs', 'bundler-' + @major_version + '.log')
      @file    = Alfred::Log.new(log, level)
      # Create the console log
      @console = Alfred::Log.new(STDERR, level)
    end

    # @!endgroup

    # [notify description]
    # @param title [type] [description]
    # @param message [type] [description]
    # @param icon = 'icon.png' [type] [description]
    #
    # @return [type] [description]
    def notify(title, message, icon = 'icon.png')

      @cd = self.wrapper('cocoadialog') if @cd.nil?

      notification = {
        :title => title,
        :description => message
      }

      notification[:icon_file] = icon unless icon == false
      $stderr.puts notification
      @cd.notify(notification)

    end

  end

  # Class to manage icon assets
  #
  # Includes color conversion methods to provide a constrast between
  # foreground and background colors.
  #
  # @author The Alfred Bundler Team
  #
  class Icon

    def initialize(data, cache, err = Logger::INFO)
      @data  = data
      @cache = File.join(cache, 'color')
      @log = Alfred::Log.new(STDERR, err)
      @background = self.get_background
    end

    def get_background()
      return self.get_background_modern unless ENV['alfred_theme_background'].nil?
      return self.get_background_deprecated
    end

    def get_background_modern
      matches = /rgba\(([0-9]{1,3}),([0-9]{1,3}),([0-9]{1,3}),([0-9.]{4,})\)/
        .match(ENV['alfred_theme_background'])
      r, g, b = matches[1].to_i, matches[2].to_i, matches[3].to_i
      @background = brightness([r, g, b])
    end

    def get_background_deprecated
      plist = "#{ENV['HOME']}/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist";
      FileUtils.mkdir_p(File.join(@cache, '..', 'misc')) unless File.directory?(File.join(@cache, '..', 'misc'))
      cache = File.join(@cache, '..', 'misc', 'theme_background')
      util  = File.join(@data, 'bundler', 'includes', 'LightOrDark')
      if File.exists? cache
        return File.open(cache).read.chomp if File.mtime(cache) > File.mtime(plist)
      end

      return false unless File.exists? util

      background = `"#{util}"`
      File.open(cache, 'w') {|f| f.write(background) }
      return background
    end

    def parse_icon_args(*args)
      args = args.shift

      args = args.shift if args.count == 1 and args.is_a? Array
      font, name, color, alter = args[0], args[1], args[2], args[3]
      color, alter = '000000', true if args.count == 2
      alter = false if args.count == 3

      if args.is_a? Hash
        for key, value in args # or for args[0..args.length] ?
          eval "#{key} = #{value.inspect}"
        end
      end

      return {:font => font, :name => name, :color => color, :alter => alter}
    end

    # Loads (and downloads) an icon
    #
    # @param args Mixed accepts an array or a series of strings. Ultimately, we
    #   need arguments for `font`, `name`, `color`, `alter`. Only `font` and
    #   `name` are necessary. `Color` defaults to black, and `alter` defaults to
    #   false (unless `color` is left out, in which case `alter` defaults to
    #   true).
    #
    # @return String path to an icon
    def icon(*args)
      # Massage the icon arguments so that we can use them.
      a = parse_icon_args(args.shift)

      a[:font].downcase!  # normalize the args
      # Deal with System icons first
      return get_system_icon(a[:name]) if a[:font] == 'system'
      a[:color].downcase! # normalize the args
      fallback = File.join(@data, 'bundler', 'meta', 'icons', 'default.png')

      # Check the hex, for now
      unless is_hex?(a[:color])
        @log.error("#{a[:color]} is not a valid hex. Falling back to black.")
        raise "Not a valid color"
      end
      a[:color] = self.convert_hex(a[:color])
      a[:color] = self.alter(a[:color]) if check_for_alter(a[:color]) == true
      # Construct the icon directory
      icon_dir = File.join(@data, 'data/assets/icons', a[:font], a[:color])

      #  Make the icon directory if it doesn't exist
      FileUtils.mkpath(icon_dir) unless File.directory?(icon_dir)

      # Construct the icon path
      icon_path = File.join(icon_dir, a[:name] + '.png')

      # The file exists, so we'll just return the path
      # we should probably check the integrity of the file
      return icon_path if File.exists?(icon_path)

      # The file doesn't exist, so we'll have to go through the effort to get it

      # A list of icon servers so that we can have fallbacks
      servers = File.join(File.expand_path(File.dirname(__FILE__)), '/meta/icon_servers')
      servers = IO.readlines(servers).map! {|server|
        server = "#{server}/icon/#{a[:font]}/#{a[:color]}/#{a[:name]}"
      }
      http = Alfred::HTTP.new
      icon = http.try_servers(servers, icon_path)
      return icon unless icon == false
      @log.error("Could not download file from #{server}")
      return fallback
    end

    # Gets a file path for a system icon
    # @param icon String name of the icon to get (case sensitive)
    #
    # @return String, Bool path to icon on success, false on failure
    def get_system_icon(icon)
        # This is where the icon should be
        icon = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/#{icon}.icns";

        # Return the System icon if it exists
        return icon if File.exists?(icon)
        @log.error("#{icon} is not a valid system icon (not found).")
        false
    end



    # Checks to see if string is a valid hex color
    #
    # @param color String a hex color
    #
    # @return Bool
    def is_hex?(color)
      return true if /^[0-9a-f]{6}$|^[0-9a-f]{3}$/.match(color)
      false
    end

    # Converts 3-hex to 6-hex
    #
    # @param color String a hex color
    #
    # @return String, Bool a six-color hex string or false on failure
    def convert_hex(color)
      return color if /^[0-9a-f]{6}$/.match(color)
      if /^[0-9a-f]{3}$/.match(color)
        return color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
      end
      false
    end

    # @!group Color Conversion Methods

    # Converts a hex number to a decimal
    # @param color String Hex color (six digits)
    #
    # @return Array an array of dec values from the hex values
    def hex_to_dec(color)
      color.map {|item| item.to_i(16)}
    end

    # Converts a decimal to a hex number with a 0 pad
    # @param color Array an array of base 10 values
    #
    # @return String a hex string (color)
    def dec_to_hex(color)
      hex = ""
      color.each do |x|
        h = x.to_s(16)
        if x < 16
          hex << "0#{h}"
        else
          hex << h
        end
      end
      hex
    end

    # Converts Hex to RGB
    # @param hex String a hex color
    #
    # @return Array an RGB color space
    def hex_to_rgb(hex)
      hex_to_dec(hex.scan(/.{2}/))
    end

    # Converts an RGB colorspace to a hex color
    # @param rgb Array an RGB colorspace
    #
    # @return String a hex color
    def rgb_to_hex(rgb)
      return dec_to_hex(rgb)
    end

    # Converts an RGB to an HSV colorspace
    #
    # @param rgb Array a colorspace in RGB format
    #
    # @return Array a colorspace in HSV format
    def rgb_to_hsv(rgb)

      r = rgb[0] / 1.0
      g = rgb[1] / 1.0
      b = rgb[2] / 1.0

      # Make sure these are floats and not ints
      min = Float(rgb.min)
      max = Float(rgb.max)
      chroma = max - min

      return [0, 0, (max/255.0)] if chroma == 0

      if r == max
        h = (g - b)/chroma
        h += 6.0 if h < 0.0
      elsif g == max
        h = ((b-r)/chroma) + 2.0
      else
        h=((r-g)/chroma) + 4.0
      end

      h *= 60.0
      s = chroma / max
      v = max / 255.0

      return [h,s,v]
    end

    # Converts an HSV colorpsace to RGB
    # @param hsv array hsv values
    #
    # @return array rgb colorspace
    def hsv_to_rgb(hsv)
      h = Float(hsv[0])
      s = Float(hsv[1])
      v = Float(hsv[2])

      r, g, b = 0, 0, 0

      chroma = s * v
      h /= 60.0

      x = chroma * (1.0 - (((h.modulo(2.0)) - 1.0).abs))
      min = v - chroma

      if h < 1.0
        r = chroma
        g = x
      elsif h < 2.0
        r = x
        g = chroma
      elsif h < 3.0
        g = chroma
        b = x
      elsif h < 4.0
        g = x
        b = chroma
      elsif h < 5.0
        r = x
        b = chroma
      elsif h < 6.0
        r = chroma
        b = x
      end

      return [r, g, b].map { |x| ((x + min) * 255).round }
    end

    # @!endgroup

    # Finds the luminance of a color space
    #
    # @param rgb Array an RGB colorspace as an array
    #
    # @return Float a float between 0 and 1 where 0 is dark, 1 is light, and
    #   .5 is neutral
    def luminance(rgb)
      rgb = hex_to_rgb(rgb) if rgb.is_a? String
      return (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255
    end

    # Evaluates a color as 'light' or 'dark' via a luminance calulation
    #
    # @see #luminance
    #
    # @param color String, Array a hex color or an RGB color space as an array
    #
    # @return String either 'light' or 'dark'
    def brightness(color)
      return 'light' if luminance(color) > 0.5
      'dark'
    end

    # Checks to see if a background color and a foreground color "match"
    #
    # The "match" is evaluated based on a luminance calculation returned
    # as either 'light' or 'dark'
    #
    # @see #brightness
    # @see #luminance
    #
    # @param color String, Array a hex color or an RGB color space as an array
    #
    # @return Bool true if the both match, false if they're different
    def check_for_alter(color)
      return true if @background == brightness(color)
      false
    end

    # Lightens or darkens a hex value or RGB space returning a hex
    # @param color String, Array either a hex color or an RGB color array
    #
    # @see #hex_to_rgb
    # @see #rgb_to_hsv
    # @see #hsv_to_rgb
    # @see #rgb_to_hex
    #
    # @return String a hex color
    def alter(color)
      color = hex_to_rgb(color) if color.is_a? String
      hsv = rgb_to_hsv(color)
      hsv = [hsv[0], hsv[1], 1.0 - hsv[2]]
      rgb = hsv_to_rgb(hsv)
      return rgb_to_hex(rgb)
    end

  end

  # A simple class to help download files
  #
  # @author The Alfred Bundler Team
  #
  class HTTP

    # Downloads a file with error handling
    # On failure, the file is deleted.
    #
    # @param url String URL to download file
    # @param path String path to destination file (where the download)
    #   gets placed locally
    #
    # @return Bool,String either false or the path where the file was
    #   downloaded
    def get(url, path)
      begin
        # Get the file if it doesn't exist
        File.open(path, 'wb') { |file| file.write open(url).read }
      rescue
        File.delete(path)
        return false
      end
      path
    end

    # Tries to download a file from a list of servers (URLs)
    #
    # Iterates through a list of urls and attempts to download one until
    # there is success.
    #
    # @param servers Array an array of URLs
    # @param path String path to destination file (where the download)
    #   gets placed locally
    #
    # @return String,Bool returns the file path on success and false if
    #   all the servers fail
    def try_servers(servers, path)
      # Loop through the list of servers until we find one that is working
      servers.each { |url| file = self.get(url, path)
        return file unless file == false }
      false
    end

  end

  # A simple function that wraps around the Logger class.
  #
  # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/logger/rdoc/Logger.html Logger
  #
  # @see Internal#log
  # @see Internal#console
  #
  # @author The Alfred Bundler Team
  #
  class Log

    # Creates a log object as a class variable
    #
    # @param location String, IO the location for the log, either a file path
    #   (string) or an IO (`STDERR` or `STDOUT`). _Note: creating a log that
    #   passes to `STDOUT` will disrupt script filters._
    # @param level = Logger::INFO [type] [description]
    #
    def initialize(location, level = Logger::INFO)
      require 'logger'
      @log = init_log(location)
      @log.level = level
    end

    # Redirects method call to log object if it is a valid Logger method
    #
    # @param name String method name
    # @param arguments Array an array of arguments sent
    #
    # @raise StandardError when a Logger object does not respond to the method
    #
    def method_missing(name, *arguments)
      return @log.send("#{name}", *arguments) if @log.respond_to?(:method)
      raise StandardError("#{name} is not a valid logging method.")
    end

    # Creates a new log
    # Small wrapper around a Logger object
    #
    # @param location Sting, IO either a file path or an IO stream
    #
    # @return Object a Logger object
    def init_log(location = STDERR)
      # Check to see the type of log
      if location.is_a? String
        # Creates the log file
        file = self.create_log_file(location)
        # Create the log with only one backup and a max size of 1MB
        log  = Logger.new(file, 1, 1048576)
        # Set the date format to YYYY-MM-DD HH:MM:SS
        date = "%Y-%m-%d %H:%M:%S"
      else
        # The log is to STDOUT / STDERR (probably just the latter)
        log  = Logger.new(location)
        # Set the date format to HH:MM:SS
        date = "%H:%M:%S"
      end
      log = self.format_log(log, date)
      # Return the newly created log object
      return log
    end

    # Creates a file to be used for Logger
    #
    # @see #init_log
    # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/logger/rdoc/Logger.html Logger
    #
    # @param location String path to a file
    #
    # @return Object a file object
    def create_log_file(location)
       # The log is a file, so let's make the path if it doesn't exist
        FileUtils.mkpath(File.dirname(location)) unless File.exists? File.dirname(location)
        # Make and / or open the log file
        file = File.open(location, File::WRONLY | File::APPEND | File::CREAT)
        return file
    end

    # Reformats a Logger object to output in standard Alfred Bundler format
    #
    # @see #init_log
    # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/logger/rdoc/Logger.html Logger
    #
    # @param log Object a Logger object
    # @param date String the format for the date/time
    #
    # @return Object a newly reformatted Logger object
    def format_log(log, date)
     # We need to make the format match the bundler's
      log.formatter = proc { |severity, datetime, progname, msg|
        # Get the last stack trace
        trace = caller.last.split(':')
        # Get the filename from the stacktrace without the directory
        file = Pathname.new(trace[0]).basename
        # Get the line number fron the trace
        line = trace[1]
        date = Time.now.strftime("#{date}")
        # Normalize the log levels to be in line with the rest of the bundler
        severity = 'CRITICAL' if severity == 'FATAL'
        severity = 'WARNING'  if severity == 'WARN'

        # Set the message format to the bundler standard
        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n" }
      return log
    end

    # Normalizes the log level to keep in line with the bundler
    #
    # Accepts `debug`, `info`, `warn`, `warning`, `error`, `fatal`, `critical`
    #
    # @param level String a log level
    #
    # @return String a valid log level, defaulting to `info`
    def normalize_log_level(level)
      # Lowercase the level name
      level.downcase!
      # define the levels and their
      levels = { 'debug' => 'debug',
                 'info'  => 'info',
                 'warning' => 'warn',
                 'warn' => 'warn',
                 'error' => 'error',
                 'fatal' => 'fatal',
                 'critical' => 'fatal'
      }
      unless levels.has_key?(level)
        # The level isn't valid, so set it to `info`
        self.console("#{level} is not a valid level, falling back to 'info'", 'debug')
        level = 'info'
      end
      return levels[level]
    end
  end
end