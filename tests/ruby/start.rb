#!/bin/ruby

require_relative "../../bundler/bundlets/alfred.bundler.rb"

bundler = Alfred::Bundler.new
bundler.foo
puts bundler.icon('font' => 'ELUSive', 'name' => 'fire', 'color' => 'abcabc', 'alter' => true)

puts bundler.icon('elusive', 'fire')
puts bundler.icon('elusive', 'fire', 'asjdhahs')
puts bundler.icon('system', 'Accounts')
puts bundler.icon('system', 'asda')

bundler.console("Test", 'inaasfo')
bundler.console("Fatal test", 'CRITICAL')
bundler.log('Testing')
bundler.log('Testing', 'FATAL')
puts "hello"