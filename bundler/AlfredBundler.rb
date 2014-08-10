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

# require 'json'
# require 'fileutils'
# require 'open-uri'

# http://www.alfredforum.com/topic/4716-some-new-alfred-script-environment-variables-coming-in-alfred-24/#entry28819
# notes for env variables:
 # "alfred_preferences" = "/Users/Crayons/Dropbox/Alfred/Alfred.alfredpreferences";
 #    "alfred_preferences_localhash" = adbd4f66bc3ae8493832af61a41ee609b20d8705;
 #    "alfred_theme" = "alfred.theme.yosemite";
 #    "alfred_theme_background" = "rgba(255,255,255,0.98)";
 #    "alfred_theme_subtext" = 3;
 #    "alfred_version" = "2.4";
 #    "alfred_version_build" = 277;
 #    "alfred_workflow_bundleid" = "com.alfredapp.david.googlesuggest";
 #    "alfred_workflow_cache" = "/Users/Crayons/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/com.alfredapp.david.googlesuggest";
 #    "alfred_workflow_data" = "/Users/Crayons/Library/Application Support/Alfred 2/Workflow Data/com.alfredapp.david.googlesuggest";
 #    "alfred_workflow_name" = "Google Suggest";
 #    "alfred_workflow_uid" = "user.workflow.B0AC54EC-601C-479A-9428-01F9FD732959";

module AlfredBundler

  # def initialize
  # 	@major_version = "devel"
  # 	@data = File.expand_path(
  # 		"~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version)
  # 	@cache = File.expand_path(
  # 		"~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" + @major_version)
  # end

  # Checks to see if a server is available
  def server_test(server)
    begin
      true if open(server)
    rescue
      false
    end
  end

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


  def load_utility(name, version='latest', json='')
    return load(name, version, 'utility', json='')
  end

  def load_gem(name, version='default', json='')
    return load(name, version, 'gem', json='')
  end

  # This is just an idea to load multiple gems at once
  def load_gems( gems )
    gems.each do |x|
      args = x.count
      if args == 1
        load_gem(x[0])
      elsif args == 2
        load_gem(x[0], x[1])
      else
        abort("ERROR: Overloading the load_gems method")
      end
    end
  end

  # This is the function to load an asset
  def load(type, name, version, json='')
    unless json.empty?
      puts "The file does not exist" unless File.exists?(json)
    end

    # Install the CFPropertyList for us to use if necessary
    gems = File.expand_path("~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version + "/data/assets/ruby/gems/gems")
    install_gem("CFPropertyList", "default") unless Dir["#{gems}/CFPropertyList-*"][0]
    $LOAD_PATH.unshift Dir["#{gems}/CFPropertyList-*/lib"][0]
    require 'CFPropertyList'

    # Get the bundle id of the workflow
    if File.exists?('info.plist')
      plist = CFPropertyList::List.new(:file => "info.plist")
      data = CFPropertyList.native_types(plist.value)
      bundle = data["bundleid"]
    end

    # Let's look in the Bundler's gems directory if the type is a gem
    if type == "gem"
      # Gems folder

      # If the version is default, then we'll see if one exists
      if version == "default"
        dir = Dir["#{@gem_dir}/gems/#{name}-*/lib"][0]
      else
        dir = "#{@gem_dir}/gems/#{name}-#{version}/lib"
      end

      # This is redundant and stopgap -- find a more elegant way
      if dir.nil?
        install_gem(name, version)
        dir = Dir["#{@gem_dir}/gems/#{name}-*/lib"][0]
      end

      # We need to put some error checking in here
      install_gem(name, version) unless File.exists?(dir)
      $LOAD_PATH.unshift dir
      require name
      # This returns TRUE, but we need to get rid of that
    elsif type == "utility"
      path = load_asset(type, name, version)
      return path
    end
  end

  # Function to install a gem
  def install_gem(name, version)
    # The Bundler Gems path
    # gems = File.expand_path("~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version + "/data/assets/ruby/gems")
    FileUtils.mkpath(@gem_dir) unless File.directory?(@gem_dir)
    if version == "default"
      command = "gem install -i \"#{@gem_dir}\" #{name}"
    else
      command = "gem install -v #{version} -i \"#{@gem_dir}\" #{name}"
    end

    # We need to doublecheck the security of this one...
    return `#{command}`
    # success = system(command)
    # success && $?.exitstatus == 0
  end

  # This is done internally
  def load_asset(type, name, version, bundle='', json='')
    # Need to add the path caching here
    if type == "utility"
      command = "'" + @data + "/bundler/bundlets/alfred.bundler.sh' '#{name}' '#{version}' '#{type}' '#{json}'"
      return `#{command}`.strip
    end
    return false
  end


  # This is a bunch of code for a nice little easter egg.
  def notify(title, message, options)
    require 'Shellwords'

    path = load_utility('CocoaDialog')

# Gutted function to remove TN in order to move to CD.
    # unless icon.empty?
    # 	if (File.exists?(icon) && File.extname(icon) == '.icns')
    # 		icon_moved = true
    # 		tmp_icon_path = @cache + '/tmp-icon'
    # 		FileUtils.mkpath(tmp_icon_path) unless File.directory?(tmp_icon_path)
    # 		tn_icon = File.path(File.dirname(path) + '/../Resources/Terminal.icns')
    # 		tn_icon_path = File.dirname(tn_icon)
    #
    # 		puts tn_icon_path + '/' + File.basename(icon)
    #
    #
    # 		FileUtils.move tn_icon, tmp_icon_path
    #
    # 		FileUtils.copy icon, tn_icon_path
    # 		FileUtils.move tn_icon_path + '/' + File.basename(icon), tn_icon_path + '/Terminal.icns'
    # 		abort
    # 	end
    # end
    # icon = '/Users/Sven/Documents/Alfred2 Workflows/alfred-bundler/bundler/meta/icons/bundle.png'
    # command = "#{Shellwords.escape(path)} -t '#{title}' -m '#{message}'"
    # -contentImage '/Users/Sven/Desktop/mics.png'
    # com.runningwithcrayons.Alfred-2
    # command = "#{Shellwords.escape(path)} -title '#{title}' -message '#{message}' "
    # command = "#{command} #{execute} #{openURL} #{activate} #{remove} #{sound} "
    # command = "#{command} #{list} #{subtitle} #{contentImage} #{appIcon} #{sender}"
    #
    # system(command)

    # if :icon_moved
    # 	FileUtils.remove tn_icon
    # 	FileUtils.copy tmp_icon_path, tn_icon_path
    # end
  end

  private :install_gem, :load_asset, :server_test
end
