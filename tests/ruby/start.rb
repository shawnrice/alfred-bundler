#!/bin/ruby

require_relative File.expand_path( File.dirname(__FILE__) ) + "../../../bundler/bundlets/alfred.bundler.rb"

bundle   = 'com.poop'
bundler  = Alfred::Bundler.new


# def init(var, date, location = 'STDERR')

#   var = Logger.new(location)
#   var.formatter = proc do |severity, datetime, progname, msg|
#         trace = caller.last.split(':')
#         file = Pathname.new(trace[0]).basename
#         line = trace[1]
#         date = Time.now.strftime(date)

#         if severity == 'FATAL'
#           severity = 'CRITICAL'
#         elsif severity == 'WARN'
#           severity = 'WARNING'
#         end

#         "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
#       end
#   return var
# end


# foo = init('foo',"%Y-%m-%d %H:%M:%S", 'STDERR')
# puts foo.inspect
# foo.info('test')
# puts bundler.load( 'utility', 'Pashua' )
# puts bundler.load( 'php', 'Workflows' )
# puts bundler.utility({'name' => 'CocoaDialog', 'version' => '3.0.0-beta7'})
# puts bundler.utility(['Pashua', 'latest'])
# puts bundler.utility('Pashua', 'latest')
# puts bundler.utility('cocoaDialog')
# puts bundler.utility('viewer')

# bundler.foo
# puts bundler.icon('font' => 'ELUSive', 'name' => 'fire', 'color' => 'abcabc', 'alter' => true)

puts bundler.icon('elusive', 'fire')
# puts bundler.icon('elusive', 'fire', 'asjdhahs')
# puts bundler.icon('system', 'Accounts')
puts bundler.icon('system', 'asda')

# bundler.console("Test", 'inaasfo')
# bundler.console("Fatal test", 'CRITICAL')
# bundler.log('Testing')
# bundler.log('Testing', 'FATAL')

# puts "We're about to load some gems"
bundler.gems( ['rdoc'], ['plist', '~>3.1.0'])
require 'plist'
p = Plist::Listener.new
puts p.inspect