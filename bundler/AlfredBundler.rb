
#
# [module description]
#
# @author [Sven]
# @since Taurus 1
#
module Alfred


  #
  # [class description]
  #
  # @author [Sven]
  #
  class Internal

    attr_reader :data

    #
    # [initialize description]
    # @param data [type] [description]
    # @param cache [type] [description]
    #
    # @return [type] [description]
    def initialize(data, cache)
      @data   = data
      @cache  = cache
      @bundle = 'foo.my.poop'
      @major_version = 'devel'
      @wf_data = File.join( File.expand_path('~/'), 'Library',
        'Application Support', 'Alfred 2', 'Workflow Data', @bundle)
      @icon = Alfred::Icon.new(@data, @cache)


      self.initialize_logs()
      self.plist_check()

      unless ENV['alfred_version'].nil?
        self.initialize_modern()
      else
        self.initialize_deprecated()
      end

      # Add our local gem repository
      @gem_dir = @data + "/data/assets/ruby/gems"
      Gem.path.unshift(@gem_dir) unless Gem.path.include?(@gem_dir)
    end


    #
    # [plist_check description]
    #
    # @return [type] [description]
    def plist_check
      self.console('No plist exists.', 'fatal') unless File.exists? './info.plist'
    end


    #
    # [method_missing description]
    # @param name [type] [description]
    # @param *arguments [type] [description]
    #
    # @return [type] [description]
    def method_missing(name, *arguments)
      self.console("'#{name}' does not exist either externally or internally.", 'error')
    end


    #
    # [initialize_modern description]
    #
    # @return [type] [description]
    def initialize_modern
      # For Alfred >= v2.4:277

      @wf_data    = ENV['alfred_workflow_data']
      @bundle     = ENV['alfred_workflow_bundleid']
      @name       = ENV['alfred_workflow_name']
    end


    #
    # [initialize_deprecated description]
    #
    # @return [type] [description]
    def initialize_deprecated
      # For Alfred < v2.4:277
      @name   = read_plist_value('name', 'info.plist')
      @bundle = read_plist_value('bundleid', 'info.plist')
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


    ######################
    #### LOAD FUNCTIONS


    #
    # [load description]
    # @param *args [type] [description]
    #
    # @return [type] [description]
    def load(*args)
      args = parse_load_args(args)
      type = args['type']
      name = args['name']
      version = args['version']
      json = args['json']
      json = File.join(@data, 'bundler', 'meta', 'defaults', "#{name}.json") if json == 'default'
      return false unless File.exists? json

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


    #
    # [parse_load_args description]
    #
    # @overload parse_load_args(args)
    #   @param hash
    #
    # @overload parse_load_args(args)
    #   @param array
    #
    # @overload parse_load_args(args)
    #   @param
    #   @param
    #   @param
    #
    # @param *args [type] [description]
    #
    # @return [type] [description]
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

    # Use a has or string args
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

    #### LOAD FUNCTIONS
    ######################

    ######################
    #### GEM FUNCTIONS

    # Based on # # http://mlen.pl/posts/protip-installing-gems-programmatically/

    #
    # [install_gem description]
    # @param name [type] [description]
    # @param version = Gem::Requirement.default [type] [description]
    #
    # @return [type] [description]
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


    #
    # [gems description]
    # @overload gems(args)
    #   @param hash
    # @param *gems [type] [description]
    #
    # @raise -------- ?
    #
    # @return [type] [description]
    def gems(*gems)
      gems.each { |g|
        begin
          gem *g
        rescue LoadError
          install_gem(*g)
        end
      }
    end

    #### GEM FUNCTIONS
    ######################

    ######################
    #### LOG FUNCTIONS


    #
    # [initialize_logs description]
    # @param user = false [type] [description]
    #
    # @return [type] [description]
    def initialize_logs( user = false )
      self.initialize_bundler_log
      self.initialize_user_log if user == true
    end


    #
    # [initialize_user_log description]
    #
    # @return [type] [description]
    def initialize_user_log(level = Logger::INFO)
      @user = Alfred::Log.new(File.join(@wf_data, @bundle + '.log'), level)
    end


    #
    # [log description]
    # @param msg [type] [description]
    # @param level = 'info' [type] [description]
    #
    # @return [type] [description]
    def log(msg, level = 'info' )
      @file.send(fix_level(level), msg)
    end


    #
    # [console description]
    # @param msg [type] [description]
    # @param level='info' [type] [description]
    #
    # @return [type] [description]
    def console(msg, level='info')
      @console.send(fix_level(level), msg)
    end

    #
    # [initialize_bundler_log description]
    #
    # @return [type] [description]
    def initialize_bundler_log(level = Logger::DEBUG)
      # Create the bundler's log file
      log = File.join(@data, 'data', 'logs', 'bundler-' + @major_version + '.log')
      @file    = Alfred::Log.new(log, level)
      # Create the console log
      @console = Alfred::Log.new(STDERR, level)
    end

    def icon(*args)
      @icon.icon(args)
    end

    def wrapper(wrapper)
      wrapper.downcase!
      require_relative File.join(File.dirname(__FILE__), 'includes', 'wrappers', 'ruby', wrapper + '.rb')
    end

    def notify(title, message, icon = 'icon.png')
      self.wrapper('cocoadialog')
      @cd = Alfred::CocoaDialog.new(self.utility('cocoaDialog')) if @cd.nil?

      notification = {
        'title' => title,
        'description' => message,
        'alpha' => 1,
        # 'background_top' => 'ffffff',
        # 'background_bottom' => 'ffffff',
        # 'border_color' => 'ffffff',
        # 'text_color' => '000000',
        # 'no_growl' => true
      }

      notification['icon_file'] = icon unless icon == false
      @cd.notify(notification)

    end

  end

  class Icon
    ######################
    #### ICON FUNCTIONS

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

    #
    # [icon description]
    # @param *args [type] [description]
    #
    # @return [type] [description]
    def icon(*args)
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
      # we're going to find that file based on a relative path to "me"
      # @TODO find a more elegant way to do this
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


    #
    # [get_system_icon description]
    # @param icon [type] [description]
    #
    # @return [type] [description]
    def get_system_icon(icon)
        # This is where the icon should be
        icon = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/#{icon}.icns";

        # Return the System icon if it exists
        return icon if File.exists?(icon)
        @log.error("#{icon} is not a valid system icon (not found).")
        false
    end

    #######################
    ### Icon Validation Functions
    #######################

    # checks to see if string is a valid hex color

    #
    # [is_hex description]
    # @param color [type] [description]
    #
    # @return [type] [description]
    def is_hex?(color)
      return true if /^[0-9a-f]{6}$|^[0-9a-f]{3}$/.match(color)
      false
    end

    #######################
    #### Conversion methods
    #######################

    # converts 3 hex to 6 hex

    #
    # [convert_hex description]
    # @param color [type] [description]
    #
    # @return [type] [description]
    def convert_hex(color)
      return color if /^[0-9a-f]{6}$/.match(color)
      if /^[0-9a-f]{3}$/.match(color)
        return color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
      end
      false
    end

    # converts a hex number to a decimal

    #
    # [hex_to_dec description]
    # @param color [type] [description]
    #
    # @return [type] [description]
    def hex_to_dec(color)
      color.map {|item| item.to_i(16)}
    end

    # converts a decimal to a hex number with a 0 pad
    # @param color [type] [description]
    #
    # @return [type] [description]
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

    # converts hex to rgb
    # @param hex [type] [description]
    #
    # @return [type] [description]
    def hex_to_rgb(hex)
      hex_to_dec(hex.scan(/.{2}/))
    end

    # converts rgb color to hex color

    #
    # [rgb_to_hex description]
    # @param rgb [type] [description]
    #
    # @return [type] [description]
    def rgb_to_hex(rgb)
      return dec_to_hex(rgb)
    end

    # converts rgb to hsv colorspace

    #
    # [rgb_to_hsv description]
    # @param rgb [type] [description]
    #
    # @return [type] [description]
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


    #
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

    #
    # Finds the luminance of a color space
    # I will take a hex or rgb color
    # @param rgb [type] [description]
    #
    # @return [type] [description]
    def luminance(rgb)
      rgb = hex_to_rgb(rgb) if rgb.is_a? String
      return (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255
    end

    # returns "light" or "dark" based on luminance

    #
    # [brightness description]
    # @param color [type] [description]
    #
    # @return [type] [description]
    def brightness(color)
      return 'light' if luminance(color) > 0.5
      'dark'
    end

    def check_for_alter(color)
      return true if @background == brightness(color)
      false
    end

    # lightens or darkens a hex value or rgb space returning a hex
    # @param color [type] [description]
    #
    # @return [type] [description]
    def alter(color)
      color = hex_to_rgb(color) if color.is_a? String
      hsv = rgb_to_hsv(color)
      hsv = [hsv[0], hsv[1], 1.0 - hsv[2]]
      rgb = hsv_to_rgb(hsv)
      return rgb_to_hex(rgb)
    end


    #### ICON FUNCTIONS
    ######################

  end

  class HTTP

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

    def try_servers(servers, path)
      # Loop through the list of servers until we find one that is working
      servers.each { |url| file = self.get(url, path)
        return file unless file == false }
      false
    end

  end


  class Log

    ######################
    #### LOG FUNCTIONS

    def initialize(location, level = Logger::INFO)
      @log = init_log(location)
      @log.level = level
    end


    def method_missing(name, *arguments)
      return @log.send("#{name}", *arguments) if @log.respond_to?(:method)
      raise "Error with logging"
    end

    #
    # [init_log description]
    # @param location = STDERR [type] [description]
    #
    # @return [type] [description]
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

    def create_log_file(location)
       # The log is a file, so let's make the path if it doesn't exist
        FileUtils.mkpath(File.dirname(location)) unless File.exists? File.dirname(location)
        # Make and / or open the log file
        file = File.open(location, File::WRONLY | File::APPEND | File::CREAT)
        return file
    end

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


    #
    # [fix_level description]
    # @param level [type] [description]
    #
    # @return [type] [description]
    def fix_level(level)
      # Lowercase the level name
      level.downcase!

      # define the levels and their
      levels = {
        'debug' => 'debug',
        'info'  => 'info',
        'warning' => 'warn',
        'warn' => 'warn',
        'error' => 'error',
        'fatal' => 'fatal',
        'critical' => 'fatal'
      }
      unless levels.has_key?(level)
        self.console("#{level} is not a valid level, falling back to 'info'", 'debug')
        level = 'info'
      end
      return levels[level]
    end




    #### LOG FUNCTIONS
    ######################

  end

end