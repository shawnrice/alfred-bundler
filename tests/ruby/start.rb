#!/bin/ruby




ENV['AB_BRANCH'] = 'devel'
require_relative File.expand_path( File.dirname(__FILE__) ) + "../../../bundler/bundlets/alfred.bundler.rb"

begin
bundler  = Alfred::Bundler.new({'wf_log' => true})

rescue Alfred::BundlerInstallError => error
  raise StandardError.new("If you don't want to use the Bundler, uninstall this workflow") if error.reason == 'Deny'
  raise StandardError.new("We'll wait for you to try again later.") if error.reason == 'More Info'
end


puts bundler.utility({'name' => 'CocoaDialog', 'version' => '2.1343.1'})
puts bundler.utility(['Pashua', 'latest'])
puts bundler.utility('Pashua', 'latest')
puts bundler.utility('cocoaDialog')
puts bundler.utility('viewer')

log = Alfred::Log.new(STDERR, Logger::DEBUG)
log.debug('test')
log.info('test')

bundler.notify('title', 'message', File.join(bundler.data, 'bundler', 'meta', 'icons', 'gem.png'))



puts bundler.load( 'utility', 'Pashua' )
puts bundler.load( 'php', 'Workflows' )


# bundler.foo
# puts bundler.icon('font' => 'ELUSive', 'name' => 'fire', 'color' => 'abcabc', 'alter' => true)

# hex  = 'abcabc'
# rgb1 = bundler.hex_to_rgb(hex)
# hsv  = bundler.rgb_to_hsv(rgb1)
# rgb2 = bundler.hsv_to_rgb(hsv)


# [hex, rgb1, hsv, rgb2].each { |x| p x}


puts bundler.icon('elusive', 'fire', 'abcabc')

puts bundler.icon('elusive', 'fire')
puts bundler.icon('elusive', 'fire', 'abcabc', true)
puts bundler.icon('elusive', 'fire', '000', true)
puts bundler.icon('elusive', 'fire', 'ffffff', true)
puts bundler.icon('elusive', 'fire', 'abcabc', false)
puts bundler.icon(['elusive', 'fire', 'abcabc'])
puts bundler.icon({:font => 'elusive', :name => 'fire', :color => 'abcabc'})
puts bundler.icon('system', 'Accounts')
# puts bundler.icon('system', 'asda')

# bundler.console("Test", 'inaasfo')
# bundler.console("Fatal test", 'CRITICAL')
# bundler.log('Testing')
# bundler.log('Testing', 'FATAL')

# # puts "We're about to load some gems"
# bundler.gems( ['oauth'], ['plist', '~>3.1.0'])
# require 'plist'
# p = Plist::Listener.new
# p.tap{ |p| p p}