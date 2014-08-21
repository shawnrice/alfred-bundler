
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
      @major_version = 'ruby-dev'
      @wf_data = File.join( File.expand_path('~/'), 'Library',
        'Application Support', 'Alfred 2', 'Workflow Data', @bundle)


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
      @background = ENV['alfred_theme_background']
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
      # $captured_output = capture_stdout do
        installer      = Gem::DependencyInstaller.new({:install_dir => "#{@gem_dir}"})
        installed_gems = installer.install name, version
      # end
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
      gems.each do |g|
        begin
          gem *g
        rescue LoadError
          # Add in a notification here because installing gems might take a while
          install_gem(*g)
          gem *g
        end
      end
    end

    #### GEM FUNCTIONS
    ######################

    ######################
    #### ICON FUNCTIONS

    #
    # [icon description]
    # @param *args [type] [description]
    #
    # @return [type] [description]
    def icon(*args)

      if args.count == 1
        if args.is_a? Array
          font = args[0]['font']
          name = args[0]['name']
          color = args[0]['color']
          alter = args[0]['alter']
        end
      elsif args.count == 2
        font  = args[0]
        name  = args[1]
        color = '000000'
        alter = true
      elsif args.count == 3
        font  = args[0]
        name  = args[1]
        color = args[2]
        alter = false
      end

      fallback = File.join(@data, 'bundler', 'meta', 'icons', 'default.png')
      font.downcase!  # normalize the args
      color.downcase! # normalize the args

      # Deal with System icons first
      return get_system_icon(name) if font == 'system'

      # Check the hex, for now
      unless is_hex(color)
        self.console("#{color} is not a valid hex. Falling back to black.", 'error')
        color = '000000'
      end
      color = convert_hex(color)

      # Construct the icon directory
      icon_dir = File.join(@data, 'data/assets/icons', font, color)

      #  Make the icon directory if it doesn't exist
      FileUtils.mkpath(icon_dir) unless File.directory?(icon_dir)

      # Construct the icon path
      icon_path = File.join(icon_dir, name + '.png')

      # The file exists, so we'll just return the path
      # we should probably check the integrity of the file
      return icon_path if File.exists?(icon_path)

      # The file doesn't exist, so we'll have to go through the effort to get it

      # A list of icon servers so that we can have fallbacks
      # we're going to find that file based on a relative path to "me"
      # @TODO find a more elegant way to do this
      me = File.expand_path(File.dirname(__FILE__))
      icon_servers = File.join(me, '/meta/icon_servers')
      icon_servers = IO.readlines(icon_servers)

      # Loop through the list of servers until we find one that is working
      icon_servers.each do |x|
        icon_url = "#{x}/icon/#{font}/#{color}/#{name}"
        begin
          # Get the file if it doesn't exist
          File.open(icon_path, 'wb') do |file|
            file.write open(icon_url).read
          end
        rescue
          File.delete(icon_path)
          # @TODO Fix this with real error logging
          self.console("Could not download icon from #{x}", 'ERROR')
        else
          return icon_path
          break
        end
      end

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

        # Icon didn't exist, so send the fallback
        return File.join(@data, 'bundler', 'meta', 'icons', 'default.icns')
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
    def is_hex(color)
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
        color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
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
      return hex
    end

    # converts hex to rgb
    # @param hex [type] [description]
    #
    # @return [type] [description]
    def hex_to_rgb(hex)
      return hex_to_dec(hex.scan(/.{2}/))
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

    # lightens or darkens a hex value or rgb space returning a hex

    #
    # [alter description]
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
    # [init_log description]
    # @param location = STDERR [type] [description]
    #
    # @return [type] [description]
    def init_log(location = STDERR)
      # Check to see the type of log
      if location.is_a? String
        # The log is a file, so let's make the path if it doesn't exist
        FileUtils.mkpath(File.dirname(location)) unless File.exists? File.dirname(location)
        # Make and / or open the log file
        file = File.open(location, File::WRONLY | File::APPEND | File::CREAT)
        # Create the log with only one backup and a max size of 1MB
        var  = Logger.new(file, 1, 1048576)
        # Set the date format to YYYY-MM-DD HH:MM:SS
        date = "%Y-%m-%d %H:%M:%S"
      else
        # The log is to STDOUT / STDERR (probably just the latter)
        var  = Logger.new(location)
        # Set the date format to HH:MM:SS
        date = "%H:%M:%S"
      end
      # We need to make the format match the bundler's
      var.formatter = proc do |severity, datetime, progname, msg|
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
        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end
      # Return the newly created log object
      return var
    end


    #
    # [initialize_user_log description]
    #
    # @return [type] [description]
    def initialize_user_log()
      @user = self.init_log(File.join(@wf_data, @bundle + '.log'))
    end


    #
    # [initialize_bundler_log description]
    #
    # @return [type] [description]
    def initialize_bundler_log()
      # Create the bundler's log file
      log = File.join(@data, 'data', 'logs', 'bundler-' + @major_version + '.log')
      @file    = self.init_log(log)
      # Create the console log
      @console = self.init_log(STDERR)
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


    #### LOG FUNCTIONS
    ######################

  end

end