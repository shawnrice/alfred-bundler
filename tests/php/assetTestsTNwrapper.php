<?php

class TerminalNotifierTest extends PHPUnit_Framework_TestCase {

    function setUp()  {
        $this->wrapper_name = 'terminalnotifier';
        require_once('alfred.bundler.php');
        $this->_bundler = new AlfredBundler;
    }

    function tearDown() {}

    function testWrapperFunction() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name);
        $this->assertTrue(is_object($wrapper_load));
    }

    function testNotification() {
        $wrapper_load = $this->_bundler->wrapper($this->wrapper_name, $debug=True);
        $_test_notification = $wrapper_load->notify([
            'title'=>'Bundler::'.__FUNCTION__,
            'message'=>'This is just a test notification...'
        ]);
        $this->assertEmpty($_test_notification);
    }

}