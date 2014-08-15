<?php

/**
 * Tests for the PHP Bundler
 *
 * @TODO Write the damn tests
 */


// tests to use info.plist
// tests to use env variables


class AlfredBundlerTest extends PHPUnit_Framework_TestCase
{
    public function setUp(){
        require_once( __DIR__ . '/../../bundler/wrappers/alfred.bundler.php' );

        // define data and cache paths first...
        if ( file_exists( DATADIR ) )
            rmdir( DATADIR );
        if ( file_exists( CACHEDIR ) )
            rmdir( CACHEDIR ); // make these work recursively
        }

        $this->b = new AlfredBundler();
    }

    public function tearDown(){
        unset( $this->b )
    }

    public function testLoadLibrary() {

      $this->assertTrue( $this->b->library( 'Workflows' ) );
    }

}
