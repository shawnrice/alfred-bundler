<?php

/**
 * Tests for the PHP Bundler
 *
 */


// tests to use info.plist
// tests to use env variables


class IconTests extends PHPUnit_Framework_TestCase
{
    function setUp() {
        $_ENV['AB_BRANCH'] = 'devel';
        $_ENV[ 'alfred_version' ]  = '2.4';
        $_ENV[ 'alfred_theme_background' ]  = 'rgba(255,255,255,0.98)';
        $_ENV[ 'alfred_workflow_bundleid' ] = 'com.bundler.testing.php';
        $_ENV[ 'alfred_workflow_name' ]     = 'PHP BUNDLER TESTING FRAMEWORK';
        $_ENV[ 'alfred_workflow_data' ]     = $_SERVER['HOME'].'/Library/Application Support/Alfred 2/Workflow Data/com.bundler.testing.poop';

        require_once( 'alfred.bundler.php' );
        $this->major = 'devel';
        define('DATADIR', "{$_SERVER['HOME']}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major}");
        define('CACHEDIR', "{$_SERVER['HOME']}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major}");

        // // define data and cache paths first...
        // if ( file_exists( DATADIR ) ) {
        //     rrmdir( DATADIR );
        // }
        // if ( file_exists( CACHEDIR ) )
        //     rrmdir( CACHEDIR ); // make these work recursively

        $this->b = new AlfredBundler;
        $this->i = new AlfredBundlerIcon( $b );
    }

    function tearDown(){
        unset( $this->b );
    }




    //
    //
    // COLOR TESTS
    function testNormalize3Hex() {
        // generate a 3-hex to use.
        $color = strtoupper( generate_hex( FALSE ) );
        // Generate the answer
        $answer = '';
        for ($x=0; $x<3; $x++ ) :
          $answer .= $color[$x] . $color[$x];
        endfor;
        $answer = strtolower( $answer );

        $color = $this->i->color( $color );
        $this->assertTrue( $color == $answer );
    }
    function testNormalizeHex() {
        $color = strtoupper( generate_hex() );
        $normalized = $this->i->normalizeHex( $color );
        $this->assertTrue( $normalized == $this->i->checkHex($color) );
    }
    function testValidateHex() {
        $hex = generate_hex();
        $this->assertNotFalse( $this->i->validateHex($hex) );
    }
    function testCheckHex() {
        $color = generate_hex();
        $this->assertTrue( $this->i->checkHex($color) !== false );
    }
    function testHexToRgb() {
        $hex = generate_hex();
        $rgb = $this->i->hexToRgb($hex);
        $this->assertTrue( $hex == $this->i->rgbToHex( $rgb ) );
    }
    function testRgbToHsv() {
        $rgb = $this->i->hexToRgb( generate_hex() );
        $hsv = $this->i->rgbToHsv( $rgb );
        $this->assertTrue( $rgb == $this->i->hsvToRgb( $hsv ) );
    }
    function testHexToRgbStatic() {
        $hex = "ac5ef1";
        $answer = ['r' => '172', 'g' => '94', 'b' => '241'];
        $rgb = $this->i->hexToRgb( $hex );
        $this->assertTrue( $rgb == $answer );
    }
    function testRgbToHexStatic() {
        $answer = "ac5ef1";
        $rgb = ['r' => '172', 'g' => '94', 'b' => '241'];
        $hex = $this->i->rgbToHex( $rgb );
        $this->assertTrue( $hex == $answer );
    }
    function testRgbToHsvStatic() {
        $rgb = ['r' => '172', 'g' => '94', 'b' => '241'];
        $answer = ['h' => '272', 's' => '0.61', 'v' => '0.945'];
        $hsv = $this->i->rgbToHsv( $rgb );
        // We'll round to the same decimal places as the answer.
        $hsv['h'] = round( $hsv['h'] );
        $hsv['s'] = round( $hsv['s'], 2);
        $hsv['v'] = round( $hsv['v'], 3);
        $this->assertTrue( $hsv == $answer );
    }
    function testHsvToRgbStatic() {
        $answer = ['r' => '172', 'g' => '94', 'b' => '241'];
        $hsv = ['h' => '272', 's' => '0.61', 'v' => '0.945'];
        $rgb = $this->i->hsvToRgb( $hsv );
        $this->assertTrue( $rgb == $answer );
    }
    function testRgbStatic() {
        $answer = ['r' => '172', 'g' => '94', 'b' => '241'];
        $hex = "ac5ef1";
        $this->assertTrue( $answer == $this->i->rgb($hex));
    }
    function testHsvStatic() {
        $answer = ['h' => '272', 's' => '0.61', 'v' => '0.945'];
        $hex = "ac5ef1";
        $hsv = $this->i->hsv($hex);
        // We'll round to the same decimal places as the answer.
        $hsv['h'] = round( $hsv['h'] );
        $hsv['s'] = round( $hsv['s'], 2);
        $hsv['v'] = round( $hsv['v'], 3);
        $this->assertTrue( $answer == $hsv );
    }
    function testGetBrightness() {
        $hex = "ac5ef1";
        $answer = 'light';
        $this->assertTrue( $this->i->getBrightness($hex) == $answer);
    } // brightness -- private function
    function testGetLuminance() {
        // We'll round to the 12th decimal place
        $hex = "ac5ef1";
        $answer = 0.52580392156863;
        $answer = round( $answer, 12 );
        $luminance = $this->i->getLuminance($hex);
        $luminance = round( $luminance, 12 );
        $this->assertTrue( $luminance == $answer);
    } // luminance  -- private function






// Color tests:
// Hex: ac5ef1
// RGB: 172, 94, 241
// HSV: 272, .61, .945

}

// Helper functions for tests
//
// Remove a directory tree quickly
function rrmdir($dir) {
    exec("rm -fR {$dir}");
}

// generates a 3 or 6 hex
function generate_hex( $full = TRUE ) {
  if ( $full )
    $n = 6;
  else
    $n = 3;
  $hex = '';
  for( $i=0; $i<$n; $i++) {
    $hex .= get_hex();
  }
  return $hex;
}

// creates a single hex digit
function get_hex( ) {
  $hex = array_merge( range( 'a', 'f' ), range( 0, 9 ) );
  return $hex[ mt_rand( 0, 15 ) ];
}




    // function testLoadLibrary() {
    //   $this->assertTrue( $this->b->library( 'Workflows' ) );
    // }

    // public function testLoadLibraryFail() {
    //     $this->assertFalse( $this->b->library('asdf') );
    // }