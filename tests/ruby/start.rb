#!/bin/ruby

require_relative "../../bundler/bundlets/alfred.bundler.rb"

bundle   = 'com.poop'
bundler  = Alfred::Bundler.new

bundler.gems( ['rdoc'], ['plist', '~>3.1.0'])
require 'plist'
p = Plist::Listener.new
puts p.inspect


exit

# # http://mlen.pl/posts/protip-installing-gems-programmatically/
# require 'rubygems'
# require 'rubygems/dependency_installer'

# def install_gem(name, options = {})
#   gem_dir="/Users/Sven/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-ruby-dev/data/assets/ruby/gems"
#   version     = options.fetch(:version, Gem::Requirement.default)
#   installer = Gem::DependencyInstaller.new({:install_dir => "#{gem_dir}"})
#   installed_gems = installer.install name, version
# end


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