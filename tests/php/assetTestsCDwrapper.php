<?php

class CocoaDialogTest extends PHPUnit_Framework_TestCase {

    function setUp()  {
        $this->wrapper_name = 'cocoadialog';
        require_once('alfred.bundler.php');
        $this->_bundler = new AlfredBundler;
    }

    function tearDown() {}

    function testWrapperFunction() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name);
        $this->assertTrue(is_object($wrapper_load));
    }

    function testMsgBox() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name);
        $_test_msgbox = $wrapper_load->msgbox([
            'title'=>'Bundler::'.__FUNCTION__,
            'text'=>'Please click the indicated button...',
            'button1'=>'Click Me'
        ]);
        $this->assertTrue(is_array($_test_msgbox));
        $this->assertTrue(count($_test_msgbox)>0);
        $this->assertEquals($_test_msgbox[0], '1');
        $_test_msgbox = $wrapper_load->msgbox([
            'title'=>'Bundler::'.__FUNCTION__,
            'text'=>'Please click the indicated button...',
            'button1'=>'Click Me',
            'string_output'=>true
        ]);
        $this->assertTrue(is_array($_test_msgbox));
        $this->assertTrue(count($_test_msgbox)>0);
        $this->assertEquals($_test_msgbox[0], 'Click Me');
    }

    function testNotify() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name);
        $_test_notify = $wrapper_load->notify([
            'title'=>'Bundler::'.__FUNCTION__,
            'description'=>'This is just a test notification...'
        ]);
        $this->assertEmpty($_test_notify);
    }

    function testProgressBar() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name);
        $_test_progressbar = new ProgressBar($wrapper_load, [
            'title'=>'Bundler::'.__FUNCTION__,
            'text'=>'Testing progress bar...',
            'percent'=>0
        ]);
        $this->assertTrue(is_object($_test_progressbar));
        foreach(range(0, 101) as $i) {
            $_test_progressbar->update($percent=$i);
            time_nanosleep(0, 10000000);
        }
        $_test_progressbar->finish();
    }

    function testStoppableProgressBar() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name);
        $_test_progressbar = new ProgressBar($wrapper_load, [
            'title'=>'Bundler::'.__FUNCTION__,
            'text'=>'Testing progress bar...',
            'percent'=>0,
            'stoppable'=>true
        ]);
        $this->assertTrue(is_object($_test_progressbar));
        foreach(range(0, 101) as $i) {
            $_running_progress = $_test_progressbar->update($percent=$i);
            if($_running_progress == 0) {
                break;
            } else {
                $this->assertEquals($_running_progress, 1);
            }
            time_nanosleep(1, 0);
        }
        $_killed_progress = $_test_progressbar->update($percent=0);
        $this->assertEquals($_running_progress, 0);
    }

}








