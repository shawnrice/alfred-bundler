#!/usr/bin/env ruby

# Exit early if incorrect number of args given
unless (ARGV.length == 1 or ARGV.length == 2)
  abort("Usage: 'hex color' 'true'/'false'/'hex color'")
end

# start functions
def is_hex(color)
  if /^[0-9a-f]{6}$|^[0-9a-f]{3}$/.match(color)
    true
  else
    false
  end
end

def convert_hex(color)
  if /^[0-9a-f]{6}$/.match(color)
    color
  elsif /^[0-9a-f]{3}$/.match(color)
    color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
  else
    false
  end
end

def hex_to_dec(color)
  color.map {|item| item.to_i(16)}
end

def dec_to_hex(color)
  color.map {|item| item.to_s(16)}
end

def rgb_to_hsv(color)
  r = color[0] / 255.0
  g = color[1] / 255.0
  b = color[2] / 255.0

  max = [r, g, b].max
  min = [r, g, b].min
  delta = max - min
  v = max

  if (max != 0.0)
    s = delta / max
  else
    s = 0.0
  end

  if (s == 0.0)
    h = 0.0
  else
    if (r == max)
      h = (g - b) / delta
    elsif (g == max)
      h = 2 + (b - r) / delta
    elsif (b == max)
      h = 4 + (r - g) / delta
    end

    h *= 60.0

    if (h < 0)
      h += 360.0
    end
  end

  h /= 360

  color = [h, s, v]

end

def hsv_to_rgb(color)
  h = color[0]
  s = color[1]
  v = color[2]

  if $s == 0
    r = g = b = v * 255
  else
    h *= 6
    i = h.floor
    var1 = v * (1 - s)
    var2 = v * (1 - s * (h - i))
    var3 = v * (1 - s * (1 - (h - i)))
    if i == 0
      r = v
      g = var3
      b = var1
    elsif i == 1
      r = var2
      g = v
      b = var1
    elsif i == 2
      r = var1
      g = v
      b = var3
    elsif i == 3
      r = var1
      g = var2
      b = v
    elsif i == 4
      r = var3
      g = var1
      b = v
    else
      r = v
      g = var1
      b = var2
    end
  end

  r = (r * 255).to_i
  g = (g * 255).to_i
  b = (b * 255).to_i

  color = [r, g, b]
end

def convert_color(color)
  if is_hex(color)
    color = convert_hex(color) # Convert 3 to 6 if necessary
  else
    abort(false)
  end
  color = color.scan(/.{2}/)   # Break into array
  color = hex_to_dec(color)
  color = rgb_to_hsv(color)
  color[2] = 1 - color[2]
  color = hsv_to_rgb(color)
  color = dec_to_hex(color)
  color = color.join()
  convert_hex(color)
end

def check_color(color)
  tmp = color.scan(/.{2}/)
  tmp = hex_to_dec(tmp)
  if ((tmp[0] * 299) + (tmp[1] * 587) + (tmp[2]*114) / 1000) > 140
    'light'
  else
    'dark'
  end
end

def check_background(color)

  # We should change this to a relative path
  if File.exists?(File.expand_path(File.dirname(__FILE__)) + "/LightOrDark")
    cmd = File.expand_path(File.dirname(__FILE__)) + "/LightOrDark"
    background = `'#{cmd}'`
  else
    # The background checking utility isn't present
    abort(color)
  end
end

color = convert_hex(ARGV[0]).downcase
# There is no fourth argument, so ignore everything, return the color, and exit 0
if ARGV.length == 1
  print color
  exit(true)
end

if ARGV[1] =~ /^([tT]|[tT][rR]|[tT][rR][uU]|[tT][rR][uU][eE]|1)$/
  backup = true
elsif ARGV[1] =~ /^([fF]|[fF][aA]|[fF][aA][lL]|[fF][aA][lL][sS]|[fF][aA][lL][sS][eE]|0)$/
  print color
  exit(true)
else
  # Fourth argument is not a bool
  if ! is_hex(ARGV[1])
    # Fourth argument is not a valid hex, so return regular color
    # and exit with status 1
    abort(color)
  else
    backup = ARGV[1]
  end
end

# Remove hash signs if they're in there.
color = color.sub('#','')

# Check to see if the color is a valid hex, if not, die
if !is_hex(color)
  abort('Not a valid hex color')
end

if check_background(color) != check_color(color)
  print color
  exit(true)
end

if !!backup == backup
  bool = true
else
  # Remove a hash if there is one
  backup = backup.sub('#','')
  if is_hex(backup)
    backup = convert_hex(backup)
  else
    # Not a valid hex color
    abort(color)
  end
  # Send backup color as the one to use
  print backup
  exit(true)
end

# So, we should be here only if the background and foreground are the same,
# a backup color was not specified, and 'true' was passed as the fourth argument.
if bool
  color = convert_color(color)
end

print color
