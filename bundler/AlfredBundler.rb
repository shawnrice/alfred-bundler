#!/bin/ruby



# This is very experimental code written by some people who don't really know ruby well.
# Watch it develop.

# Can we split this into two files like the other bundlers? Then we can abstract it all the
# more in order to make this work out well.

# require 'json'
# require 'fileutils'
# require 'open-uri'

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
	def icon(font, color, name)

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

	# This is real fucking inelegant, but we can't assume that the
	# native gems are available to unzip files, so we'll go through the system
	def unzip(file, destination)
		command = "cd \"#{destination}\"; unzip -oq #{file}; cd -"
		success = system(command)
		success && $?.exitstatus == 0
	end

	def load_utility(name, version='default', json='')
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
	def load(name, version, type, json='')
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
			path = load_asset(name, version, type)
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
	def load_asset(name, version, type, bundle='', json='')
		# Need to add the path caching here
		if type == "utility"
			command = "'" + @data + "/bundler/wrappers/alfred.bundler.misc.sh' '#{name}' '#{version}' '#{type}' '#{json}'"
			return `#{command}`
		end
		return false
	end

	private :install_gem, :load_asset, :server_test
end