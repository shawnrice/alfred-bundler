#!/bin/ruby

require_relative File.expand_path( File.dirname(__FILE__) ) + "../../../bundler/bundlets/alfred.bundler.rb"

bundle   = 'com.poop'
bundler  = Alfred::Bundler.new


# puts "We're about to load some gems"
bundler.gems( ['rdoc'], ['plist', '~>3.1.0'])
require 'plist'
p = Plist::Listener.new
puts p.inspect

exit

# # puts bundler.load( 'utility', 'Pashua' )
# # puts bundler.load( 'php', 'Workflows' )
# # puts bundler.utility({'name' => 'CocoaDialog', 'version' => '3.0.0-beta7'})
# # puts bundler.utility(['Pashua', 'latest'])
# # puts bundler.utility('Pashua', 'latest')
# # puts bundler.utility('cocoaDialog')
# # puts bundler.utility('viewer')

# # bundler.foo
# # puts bundler.icon('font' => 'ELUSive', 'name' => 'fire', 'color' => 'abcabc', 'alter' => true)

# # puts bundler.icon('elusive', 'fire')
# # puts bundler.icon('elusive', 'fire', 'asjdhahs')
# # puts bundler.icon('system', 'Accounts')
# # puts bundler.icon('system', 'asda')

# # bundler.console("Test", 'inaasfo')
# # bundler.console("Fatal test", 'CRITICAL')
# # bundler.log('Testing')
# # bundler.log('Testing', 'FATAL')





# # ====================
# # INSTALLING gems
require 'rubygems/commands/install_command'
cmd = Gem::Commands::InstallCommand.new
cmd.handle_options ["--no-ri", "--no-rdoc", 'rake', '--version', '0.9']  # or omit --version and the following option to install the latest

begin
  cmd.execute
rescue Gem::SystemExitException => e
  puts "DONE: #{e.exit_code}"
end