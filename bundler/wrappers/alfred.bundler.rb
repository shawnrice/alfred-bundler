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

		def initialize
			@major_version = "devel"
			@data = File.expand_path(
				"~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" + @major_version)
			@cache = File.expand_path(
				"~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" + @major_version)

			# Should there be a better test?
			install_bundler	unless File.exists?(@data + "/bundler/AlfredBundler.rb")
			# $LOAD_PATH.unshift @data + "/bundler"
			# The below line is just for easier development purposes

		end

	end

end


if __FILE__ == $0
	name = 'align-center'
	color = '2321ee'
	font = 'fontawesome'

	bundler = Alfred::Bundler.new
	# puts bundler.hello
	# puts bundler.load('Pashua', 'default', 'utility')
	puts bundler.utility('Pashua', 'default')
	# puts bundler.load('zip', 'default', 'gem')
	# puts icon.install_bundler
	# puts icon.get_icon(font, color, name)
end
