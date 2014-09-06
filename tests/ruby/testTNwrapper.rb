#!/bin/ruby

gem "minitest"
require "minitest/autorun"
require "../../bundler/bundlets/alfred.bundler.rb"

# Broken: due to Ruby bundler's utility->load methods.
# > All other bundler's allow the names "cocoadialog" and "terminalnotifier"
# > for loading wrappers (which also means utilities)


class TerminalNotifierTest < MiniTest::Unit::TestCase

    def setup
        @_bundler = Alfred::Bundler.new
        @wrapper_name = "terminalnotifier"
    end

    def test_wrapper_function
        _wrapper_load = @_bundler.wrapper(@wrapper_name)
    end

end