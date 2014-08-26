<?php

class AssetTests extends PHPUnit_Framework_TestCase
{

    function setUp() {
        $_ENV['AB_BRANCH'] = 'devel';

        require_once( 'alfred.bundler.php' );
        $this->major = 'devel';
        define('DATADIR', "{$_SERVER['HOME']}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major}");
        define('CACHEDIR', "{$_SERVER['HOME']}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major}");

        $this->b = new AlfredBundler;
    }

    function tearDown() {
        unset( $this->b );
    }

    function testLibrary() {
        $library = $this->b->library('Workflows');
        $this->assertTrue( class_exists( 'Workflows' ) );
    }

    function testUtility() {
        $utility = $this->b->utility('Pashua', 'latest');
        $this->assertTrue( file_exists( $utility ) );
    }

    function testLoad() {
        $utility = $this->b->load( 'utility', 'cocoaDialog', '2.1.1' );
        $this->assertTrue( file_exists( $utility ) );
    }

    function testWrapper() {
        $wrapper = $this->b->wrapper('cocoadialog');
        $this->assertTrue( is_object( $wrapper ) );
    }

    function testIcon() {
        $icon = $this->b->icon('elusive', 'fire', '123', true );
        $this->assertTrue( file_exists( $icon ) );

    }

    function testComposer() {
        $this->b->composer( array( 'monolog/monolog' => '1.0.*' ) );
        $this->assertTrue( class_exists( "Monolog\Logger" ) );
    }


}