#!/bin/ruby

gem "minitest"
require "minitest/autorun"
require "../../bundler/bundlets/alfred.bundler.rb"


class CocoaDialogTest < MiniTest::Unit::TestCase

    def setup
        @_bundler = Alfred::Bundler.new
        @wrapper_name = "cocoadialog"
    end

    def test_wrapper_function
        _wrapper_load = @_bundler.wrapper(@wrapper_name)
        assert _wrapper_load.is_a?(Alfred::Cocoadialog)
    end

    def test_msgbox
        _wrapper_load = @_bundler.wrapper(@wrapper_name, debug=true)
        _test_msgbox = _wrapper_load.msgbox(
            title:"Bundler::#{__method__}",
            text:"Please click the indicated button...",
            button1:"Click Me"
        )
        assert _test_msgbox.is_a?(Array)
        assert _test_msgbox.length > 0
        assert _test_msgbox[0].eql? "1"
        _test_msgbox = _wrapper_load.msgbox(
            title:"Bundler::#{__method__}",
            text:"Please click the indicated button...",
            button1:"Click Me",
            string_output:true
        )
        assert _test_msgbox.is_a?(Array)
        assert _test_msgbox.length > 0
        assert _test_msgbox[0].eql? "Click Me"
    end

    def test_notify
        _wrapper_load = @_bundler.wrapper(@wrapper_name, debug=true)
        _test_notify = _wrapper_load.notify(
            title:"Bundler::#{__method__}",
            description:"This is just a test notification..."
        )
        assert _test_notify.nil?
    end

    def test_progressbar
        _wrapper_load = @_bundler.wrapper(@wrapper_name, debug=true)
        _test_progressbar = Alfred::ProgressBar.new(
            _wrapper_load,
            title:"Alfred::#{__method__}",
            text:"Testing progress bar...",
            percent:0
        )
        assert _test_progressbar.is_a?(Alfred::ProgressBar)
        (0..100).step(1) do |i|
            _test_progressbar.update(percent=i)
            sleep(0.01)
        end
        _test_progressbar.finish()
    end

    def test_stoppable_progressbar
        _wrapper_load = @_bundler.wrapper(@wrapper_name, debug=true)
        _test_progressbar = Alfred::ProgressBar.new(
            _wrapper_load,
            title:"Alfred::#{__method__}",
            text:"Please press the stoppable button...",
            percent:0,
            stoppable:true
        )
        assert _test_progressbar.is_a?(Alfred::ProgressBar)
        (0..100).step(1) do |i|
            _running_progress = _test_progressbar.update(percent=i)
            if _running_progress.eql? 0
                break
            else
                assert _running_progress.eql? 1
            end
            sleep(1)
        end

        # NOTE:
        # It is common for an error to occur on this assertion

        _killed_progress = _test_progressbar.update(percent=0)
        assert _killed_progress.eql? 0
    end
end




