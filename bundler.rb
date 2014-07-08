#!/bin/ruby

# This is very experimental code written by someone who doesn't know ruby.
# Watch it develop.

require 'json'
require 'fileutils'
require 'open-uri'

majorVersion = 'aries'
_data = '~/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-aries'

# Function to get icons from the icon server.
def getIcon( font, color, name )
	_data = Dir.home + '/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-aries'
	
	iconDir = _data + '/assets/icons/' + font + '/' + color

	#  Make the icon directory if it doesn't exist
	FileUtils.mkpath( iconDir ) unless File.directory?( iconDir )

	iconServer = 'http://icons.deanishe.net/icon'
	icon = iconServer + '/' + font + '/' + color + '/' + name

	unless File.exists?( iconDir + '/' + name + '.png' )
		# Get the file if it doesn't exist
		open( iconDir + '/' + name + '.png' , 'wb') do |file|
			file << open( icon ).read
		end
	end
end

def installBundler()
# This is the function to install the bundler
end

def _load( name, version, type, json = '' )
	unless json.nil?
		puts "The file does not exist" unless File.exists?( json )
	# FileUtils.mkdir(rubydir) unless File.directory?(rubydir)
	end

	# This is the function to load an asset
end

def _loadAsset()
	# This is done internally
end

def _loadAssetInner()
	# This is done even more internally
end

# _load( 'name', 'version', 'type', '/Users/Sven/Desktop' )

name = 'align-center'
color = 'dd11ee'
font = 'fontawesome'

getIcon( font, color, name )




