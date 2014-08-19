
module AlfredBundlerIcon
  # Function to get icons from the icon server
  def icon(font, name, color='000000', alter='FALSE' )


    #
    # Fix for sytem icon font
    #

    # Construct the icon directory
    icon_dir = File.join(@data, 'data/assets/icons', font, color)

    #  Make the icon directory if it doesn't exist
    FileUtils.mkpath(icon_dir) unless File.directory?(icon_dir)

    # Construct the icon path
    icon_path = File.join(icon_dir, name + '.png')

    # The file exists, so we'll just return the path
    return icon_path if File.exists?(icon_path)

    # The file doesn't exist, so we'll have to go through the effort to get it

    # A list of icon servers so that we can have fallbacks
    icon_servers = IO.readlines("bundler/meta/icon_servers")


    # Loop through the list of servers until we find one that is working
    server = icon_servers.each do |x|
      if server_test(x)
        break x
      end
    end

    # So, none of the servers were reachable. So, we exit, disgracefully.
    unless :server
      return false
    end
    # Finish constructing the URL
    icon_url = "#{server}/icon/#{font}/#{color}/#{name}"

    unless
      # Get the file if it doesn't exist
      open(icon_path, 'wb') do |file|
        file << open(icon_url).read
      end
    end
    icon_path
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

end # End icon module