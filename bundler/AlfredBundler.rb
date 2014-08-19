# http://hawkins.io/2013/08/using-the-ruby-logger/
# class CustomFormater < Logger::Formater
#   def call(severity, time, progname, msg)
#    # msg2str is the internal helper that handles different msgs correctly
#     "#{time} - #{msg2str(msg)}"
#   end
# end

module Alfred

  class Internal

    def initialize(data, cache)
      @@data   = data
      @@cache  = cache
      @@bundle = 'foo.my.poop'
      @@major_version = 'ruby-dev'
      @@wf_data = File.join( File.expand_path('~/'), 'Library',
        'Application Support', 'Alfred 2', 'Workflow Data', @@bundle)

      self.initialize_logs()
    end


    def method_missing(name, *arguments)
      self.console("'#{name}' does not exist either externally or internally.")
    end

    def initialize_modern
      # For Alfred >= v2.4:277
    end

    def initialize_deprecated
      # For Alfred < v2.4:277
    end

    ######################
    #### ICON FUNCTIONS

    def get_system_icon(icon)

        # This is where the icon should be
        icon = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/#{icon}.icns";

        # Return the System icon if it exists
        return icon if File.exists?(icon)

        # Icon didn't exist, so send the fallback
        return File.join(@@data, 'bundler', 'meta', 'icons', 'default.icns')



    end

    # Function to get icons from the icon server
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

      fallback = File.join(@@data, 'bundler', 'meta', 'icons', 'default.png')
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
      icon_dir = File.join(@@data, 'data/assets/icons', font, color)

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


    # checks to see if string is a valid hex color
    def is_hex(color)
      if /^[0-9a-f]{6}$|^[0-9a-f]{3}$/.match(color)
        true
      else
        false
      end
    end

    # converts 3 hex to 6 hex
    def convert_hex(color)
      if /^[0-9a-f]{6}$/.match(color)
        color
      elsif /^[0-9a-f]{3}$/.match(color)
        color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
      else
        false
      end
    end

    # converts a hex number to a decimal
    def hex_to_dec(color)
      color.map {|item| item.to_i(16)}
    end

    # converts a decimal to a hex number with a 0 pad
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

    #######################
    #### Conversion methods

    # converts hex to rgb
    def hex_to_rgb(hex)
      hex = hex.scan(/.{2}/)
      return hex_to_dec(hex)
    end

    # converts rgb color to hex color
    def rgb_to_hex(rgb)
      return dec_to_hex(rgb)
    end

    # converts rgb to hsv colorspace
    def rgb_to_hsv(rgb)

      r = rgb[0] / 1.0
      g = rgb[1] / 1.0
      b = rgb[2] / 1.0

      # Make sure these are floats and not ints
      min = Float(rgb.min)
      max = Float(rgb.max)
      chroma = max - min

      if chroma == 0
        return [0, 0, (max/255.0)]
      end

      if r == max
        h = (g - b)/chroma
        if h < 0.0
          h += 6.0;
        end
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

    # converts hsv to rgb colorspace
    def hsv_to_rgb(hsv)
      h = Float(hsv[0])
      s = Float(hsv[1])
      v = Float(hsv[2])
      r = 0
      g = 0
      b = 0

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

      r = ((r + min) * 255).round
      g = ((g + min) * 255).round
      b = ((b + min) * 255).round

      return [r, g, b]
    end

    # Finds the luminance of a color space
    # I will take a hex or rgb color
    def luminance(rgb)
      if rgb.is_a? String
        rgb = hex_to_rgb(rgb)
      end
      return (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255
    end

    # returns "light" or "dark" based on luminance
    def brightness(color)
      if luminance(color) > 0.5
        return 'light'
      else
        return 'dark'
      end
    end

    # lightens or darkens a hex value or rgb space returning a hex
    def alter(color)
      if color.is_a? String
        color = hex_to_rgb(color)
      end
      hsv = rgb_to_hsv(color)
      hsv = [hsv[0], hsv[1], 1.0 - hsv[2]]
      rgb = hsv_to_rgb(hsv)
      return rgb_to_hex(rgb)
    end


    #### ICON FUNCTIONS
    ######################

    ######################
    #### LOG FUNCTIONS


    # @TODO combine the log and file commands

    def initialize_logs
      self.initialize_bundler_log()
      self.initialize_user_log()
    end

    def initialize_user_log

      FileUtils.mkdir(@@wf_data) unless File.directory?(@@wf_data)

      @@user    = Logger.new(File.join(@@wf_data, @@bundle + '.log'), 1, 1048576)
      # Redo formatting to make everythng nice
      @@user.formatter = proc do |severity, datetime, progname, msg|
        trace = caller.last.split(':')
        file = Pathname.new(trace[0]).basename
        line = trace[1]
        date = Time.now.strftime("%Y-%m-%d %H:%M:%S")

        if severity == 'FATAL'
          severity = 'CRITICAL'
        elsif severity == 'WARN'
          severity = 'WARNING'
        end

        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end
    end

    def initialize_bundler_log
      @@console = Logger.new(STDERR)

      # Redo formatting to make everythng nice
      @@console.formatter = proc do |severity, datetime, progname, msg|
        trace = caller.last.split(':')
        file = Pathname.new(trace[0]).basename
        line = trace[1]
        date = Time.now.strftime("%H:%M:%S")

        if severity == 'FATAL'
          severity = 'CRITICAL'
        elsif severity == 'WARN'
          severity = 'WARNING'
        end

        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end

      @@file    = Logger.new(File.join(@@data, 'data', 'logs', 'bundler-' + @@major_version + '.log'), 1, 1048576)
      # Redo formatting to make everythng nice
      @@file.formatter = proc do |severity, datetime, progname, msg|
        trace = caller.last.split(':')
        file = Pathname.new(trace[0]).basename
        line = trace[1]
        date = Time.now.strftime("%Y-%m-%d %H:%M:%S")

        if severity == 'FATAL'
          severity = 'CRITICAL'
        elsif severity == 'WARN'
          severity = 'WARNING'
        end


        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end
    end

    def log(msg, level = 'info' )
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
      level = levels[level]
      @@file.send(level, msg)
    end

    def console(msg, level='info')
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
      level = levels[level]
      @@console.send(level, msg)
    end


    #### LOG FUNCTIONS
    ######################

  end

end