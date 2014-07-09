#!/bin/ruby

# This is very experimental code written by some people who don't really know ruby well.
# Watch it develop.

# Can we split this into two files like the other bundlers? Then we can abstract it all the
# more in order to make this work out well.

require 'json'
require 'fileutils'
require 'open-uri'

$ab_major_version = 'aries'
$ab_data_dir = File.expand_path(
	"~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-#{$ab_major_version}")


# Can we move this hardcoded URL into the backend? If we want to start to code in "mirror" backups,
# then we should move this to the backend if possible. Actually, we should move all URLs to the
# backend.
# URL template for creating icon URLs. Add `font`, `color`, `name`s
$ab_icon_url = 'http://icons.deanishe.net/icon/%s/%s/%s'

# Function to get icons from the icon server.
def get_icon(font, color, name)

	icon_dir = File.join($ab_data_dir, 'assets/icons', font, color)

	#  Make the icon directory if it doesn't exist
	FileUtils.mkpath(icon_dir) unless File.directory?(icon_dir)

	icon_url = $ab_icon_url % [font, color, name]
	icon_path = File.join(icon_dir, name + '.png')

	unless File.exists?(icon_path)
		# Get the file if it doesn't exist
		open(icon_path, 'wb') do |file|
			file << open(icon_url).read
		end
	end
	icon_path
end

def install_bundler()
# This is the function to install the bundler

# Bundler Install URLs
# I added a bundler backup at Bitbucket: https://bitbucket.org/shawnrice/alfred-bundler
install_urls = [ 'https://github.com/shawnrice/alfred-bundler/tree/aries' ]
# https://github.com/shawnrice/alfred-bundler/blob/aries/meta/installer.sh
# https://bitbucket.org/shawnrice/alfred-bundler/get/7c0f71f72bfc.zip
end

def _load(name, version, type, json='')
	unless json.nil?
		puts "The file does not exist" unless File.exists?(json)
	end

	# This is the function to load an asset
end

def _load_asset()
	# This is done internally
end

def _load_asset_inner()
	# This is done even more internally
end

name = 'align-center'
color = 'dd11ee'
font = 'fontawesome'

puts get_icon(font, color, name)




