#!/bin/ruby

gem "minitest"
require "minitest/autorun"
require "../../bundler/bundlets/alfred.bundler.rb"


class TerminalNotifierTest < MiniTest::Unit::TestCase

    def setup
        @_bundler = Alfred::Bundler.new
        @wrapper_name = "terminalnotifier"
    end

    def test_wrapper_function
        _wrapper_load = @_bundler.wrapper(@wrapper_name)
        assert _wrapper_load.is_a?(Alfred::Terminalnotifier)
    end

    def test_notification
        _wrapper_load = @_bundler.wrapper(@wrapper_name)
        _test_notification = _wrapper_load.notify(
            title:"Bundler::#{__method__}",
            message:"This is just a test notification..."
        )
        assert _test_notification.nil?
    end

end