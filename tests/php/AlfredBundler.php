<?php

/**
 * Tests for the PHP Bundler
 *
 * @TODO Write the damn tests
 */


require_once( __DIR__ . '/../../bundler/wrappers/alfred.bundler.php' );


class AlfredBundlerTest extends PHPUnit_Framework_TestCase
{
    public function setUp(){ }
    public function tearDown(){ }

    public function testLoadLibrary() {
      $b = new AlfredBundler();
      $this->assertTrue( $b->library( 'Workflows' ) );
    }

}
