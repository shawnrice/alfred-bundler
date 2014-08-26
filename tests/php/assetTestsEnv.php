<?php



// AlfredBundlerInternalClass
// setup                    --> setUp (and all others)
// setupModern              --> setUp (and all others)
// setupDeprecated          --> tested in assetTestsNoEnv
// setupDirStructure        --> setUp (and all others)
// load                     --> testLoad
// icon                     --> testIcon
// utility                  --> testUtility
// library                  --> testLibrary
// wrapper
// composer                 --> testComposer
// icns
// installAsset             --> testLoad / testUtility / testLibrary
// installComposerPackage   --> testComposer
// bundle
// readPlist                --> tested in assetTestsNoEnv
// download                 --> testLoad / testUtility / testLibrary
// reportLog
// logInternal
// log
// rrmdir
// gatekeeper               --> testGatekeeper
// register
// notify                   --> setUp (when the bundler isn't installed)


class IconTests extends PHPUnit_Framework_TestCase
{

    function setUp() {
        $_ENV['AB_BRANCH'] = 'devel';
        $_ENV[ 'alfred_version' ]  = '2.4';
        $_ENV[ 'alfred_theme_background' ]  = 'rgba(255,255,255,0.98)';
        $_ENV[ 'alfred_workflow_bundleid' ] = 'com.bundler.testing.poop';
        $_ENV[ 'alfred_workflow_name' ]     = 'PHP BUNDLER TESTING FRAMEWORK';
        $_ENV[ 'alfred_workflow_data' ]     = $_SERVER['HOME'].'/Library/Application Support/Alfred 2/Workflow Data/com.bundler.testing.poop';

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

    // function testGatekeeper() {
    //     $wrapper = $this->b->utility('viewer');
    //     $this->assertTrue( is_object( $wrapper ) );
    // }

}