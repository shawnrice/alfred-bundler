#!/bin/ruby

require_relative "../../bundler/bundlets/alfred.bundler.rb"

bundler = Alfred::Bundler.new
bundler.foo
bundler.icon('font' => 'elusive', 'name' => 'fire', 'color' => 'abcabc', 'alter' => true)

bundler.console("Test", 'inaasfo')
bundler.console("Fatal test", 'CRITICAL')
bundler.log('Testing')
bundler.log('Testing', 'FATAL')
puts "hello"