#!/bin/ruby



# This is very experimental code written by some people who don't really know ruby well.
# Watch it develop.

# Can we split this into two files like the other bundlers? Then we can abstract it all the
# more in order to make this work out well.

require 'json'
require 'fileutils'
require 'open-uri'

# This is the function to install the bundler
def install_alfred_bundler()

	major_version = "devel"
	data = File.expand_path(
		"~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + major_version)
	cache = File.expand_path(
		"~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" + major_version)

	# Make the bundler path
	FileUtils.mkpath(data) unless File.directory?(data)

	#### THE FOLLOWING CHECK WILL FAIL BECAUSE IT HASN'T BEEN LOADED

	# Check for an Internet connection
	# unless server_test("http://www.google.com")
		# abort("ERROR: Cannot install Alfred Bundler because there is no Internet connection.")
	# end

	require 'uri'

	# Bundler Install URLs
	# I added a bundler backup at Bitbucket: https://bitbucket.org/shawnrice/alfred-bundler
	# bundler_urls = IO.readlines("meta/bundler_servers")
	# Bundler URLs have to be hard coded in the wrapper
	bundler_urls = ["https://github.com/shawnrice/alfred-bundler/archive/devel.zip",
									"https://bitbucket.org/shawnrice/alfred-bundler/get/devel.zip"]
	url = bundler_urls.each do |x|
		server = URI.parse(x)
		# if server_test("#{server.scheme}://#{server.host}")
			break x
		# end
	end
	FileUtils.mkpath(cache) unless File.directory?(cache)
	# Pausing this until we decide to stay with zip or move to git

	# Get the file if it doesn't exist
	open(cache + "/bundler.zip", 'wb') do |file|
		file << open(url).read
	end
	# zip = unzip("bundler.zip", cache)
	command = "cd \"#{cache}\"; unzip -oq bundler.zip; cd -"
	system(command)

	unless :zip
		abort("ERROR: Cannot install Alfred Bundler -- bad zip file.")
	end

	# Theoretically, this will install the bundler
	command = "bash '" + @cache + "/alfred-bundler-" + @major_version + "/bundler/meta/installer.sh'"
	success = system(command)
	success && $?.exitstatus == 0
end

# Should there be a better test?
install_alfred_bundler	unless File.exists?(
	File.expand_path(
		"~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + "devel" + "/bundler/AlfredBundler.rb")
)
# $LOAD_PATH.unshift @data + "/bundler"
# The below line is just for easier development purposes


$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
require 'AlfredBundler'

module Alfred
	class Bundler
		include AlfredBundler

		# I need to move the load function here along with the plist parsing
	end
end


if __FILE__ == $0
	name = 'align-center'
	color = '2321ee'
	font = 'fontawesome'

	bundler = Alfred::Bundler.new
	# puts bundler.hello
	# puts bundler.load('Pashua', 'default', 'utility')
	puts bundler.load_utility('Pashua', 'default')
	# puts bundler.load_gem('zip')
	# puts icon.install_bundler
	# puts icon.get_icon(font, color, name)
end
