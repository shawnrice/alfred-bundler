<?php

/***
  Main PHP interface for the Alfred Dependency Bundler. This file should be
  the only one from the bundler that is distributed with your workflow.

  See documentation on how to use: http://shawnrice.github.io/alfred-bundler/

  License: GPLv3
***/

class AlfredBundler {

    protected $bundler;
    private $data;
    private $cache;
    private $major_version;

    public function __construct() {

      $this->major_version = 'devel';
      $this->data  = "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}";
      $this->cache = "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}";

      if ( file_exists( "{$this->data}/bundler/AlfredBundler.php" ) ) {
        require_once( "{$this->data}/bundler/AlfredBundler.php" );
        $this->bundler = new AlfredBundlerInternalClass();
      } else {
        $this->install_bundler();
      }

      // Call the wrapper to update itself, this will fork the process to make sure
      // that we do not need to wait and slow down results.
      exec( "bash '{$this->data}/bundler/meta/update-wrapper.sh'" );

    }

    private function install_bundler() {

      // This is a list of mirrors that host the bundler
      $bundler_servers = array(
        "https://github.com/shawnrice/alfred-bundler/archive/{$this->major_version}-latest.zip",
        "https://bitbucket.org/shawnrice/alfred-bundler/get/{$this->major_version}-latest.zip"
      );

      if ( ! file_exists( $this->cache ) )
        mkdir( $this->cache, 0755, TRUE );
      if ( ! file_exists( $this->data ) )
        mkdir( $this->data, 0755, TRUE );

      foreach( $bundler_servers as $server ) :
        $success = $this->download( $server, "{$this->cache}/bundler.zip" );
        if ( $success === TRUE )
          break;
      endforeach;

      if ( $success !== TRUE )
        return FALSE; // Add in error reporting

    echo "Here";
      $zip = new ZipArchive;
      $resource = $zip->open( "{$this->cache}/bundler.zip" );
      if ( $resource !== TRUE ) {
        echo "Uh....";
        return FALSE; // Add in error reporting
      } else {
        $zip->extractTo( "{$this->cache}" );
        $zip->close();
      }

      if ( file_exists( "{$this->data}/bundler") )
        return FALSE; // Add in error reporting

      // Move the bundler into place
      rename( "{$this->cache}/alfred-bundler-{$this->major_version}-latest/bundler",
              "{$this->data}/bundler" );

      require_once( "{$this->data}/bundler/AlfredBundler.php" );
      $this->bundler = new AlfredBundlerInternalClass();

      return TRUE; // The bundler should be in place now
    }

    public function download( $url, $file, $timeout = '3' ) {
      // Check the URL here

      // Make sure that the download directory exists
      if ( ! ( file_exists( dirname( $file ) ) && is_dir( dirname( $file ) ) ) )
        return FALSE;

      $ch = curl_init( $url );
      $fp = fopen( $file , "w");

      curl_setopt_array( $ch, array(
        CURLOPT_FILE => $fp,
        CURLOPT_HEADER => FALSE,
        CURLOPT_FOLLOWLOCATION => TRUE,
        CURLOPT_CONNECTTIMEOUT => $timeout
      ) );


      // Curl error codes: http://curl.haxx.se/libcurl/c/libcurl-errors.html
      if ( curl_exec( $ch ) === FALSE) {
        echo 'Curl error: ' . curl_error($ch);
      } else {
        echo 'Operation completed without any errors';
      }
      curl_close( $ch );
      fclose( $fp );
      return TRUE;
    }


    public function __call( $method, $args )
    {
        if ( ! method_exists( $this->bundler, $method ) ) {
            throw new Exception( "unknown method [$method]" );
        }

        return call_user_func_array( array( $this->bundler, $method ), $args );
    }

}

$bundle = new AlfredBundler;

// // Define the global bundler version.
// $bundler_version       = "devel";
// $bundler_minor_version = '1';
//
// // Let's just make sure that the utility exists before we try to use it.
// $__data = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
// if ( ! file_exists( "$__data" ) ) {
//   $success = __installBundler();
//   if ( $success !== TRUE ) {
//     exit( 'ERROR: failed to install Alfred Bundler -- ' . $success );
//   }
// }
//
// // This file will be there because it either was or we just installed it.
// require_once( "$__data/bundler/AlfredBundler.php" );
//
// // Update logic for the bundler
// // ----------------------------
// // Unfortunately, Apple doesn't let us have the pcntl functions natively, so
// // we'll take a different route and spoof this sort of thing. Here is a not
// // very well developed implementation of forking the update process.
// //
// // if ( ! function_exists('pcntl_fork') )
// //   die('PCNTL functions not available on this PHP installation');
// // else {
// //   $pid = pcntl_fork();
// //
// //   switch($pid) {
// //       case -1:
// //           print "Could not fork!\n";
// //           exit;
// //       case 0:
// //           // Check for bundler minor update
// //           $cmd = "sh '$__data/bundler/meta/update.sh' > /dev/null 2>&1";
// //           exec( $cmd );
// //           break;
// //       default:
// //           print "In parent!\n";
// //   }
// // }
//
//
//
//
// /**
//  *  This is the only function the workflow author needs to invoke.
//  *  If the asset to be loaded is a PHP library, then you just need to call the function,
//  *  and the files will be required automatically.
//  *
//  *  If you are loading a "utility" application, then the function will return the full
//  *  path to the function so that you can invoke it.
//  *
//  *  If you are passing your own json, then include it as a file path.
//  *
//  **/
// function __load( $name , $version = 'default' , $type = 'php' , $json = '' ) {
//   if ( file_exists( 'info.plist' ) ) {
//     // Grab the bundle ID from the plist file.
//     $bundle = exec( "/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'" );
//   } else if ( file_exists( '../info.plist' ) ) {
//     $bundle = exec( "/usr/libexec/PlistBuddy -c 'print :bundleid' '../info.plist'" );
//   } else {
//     $bundle = '';
//   }
//
//   if ( $type == 'php' ) {
//     $assets = __loadAsset( $name , $version , $bundle , strtolower($type) , $json );
//     foreach ($assets as $asset ) {
//       require_once( $asset );
//     }
//     return TRUE;
//   } else if ( $type == 'utility' ) {
//     $asset = __loadAsset( $name , $version , $bundle , strtolower($type) , $json );
//     return str_replace(' ' , '\ ' , $asset[0]);
//   } else {
//     return __loadAsset( $name , $version , $bundle , strtolower($type) , $json );
//   }
//
//   // We shouldn't get here.
//   return FALSE;
//
// } // End __load()
//
// /**
//  * Installs the Alfred Bundler utility.
//  **/
// function __installBundler() {
//   // Install the Alfred Bundler
//
//   global $bundler_version, $__data;
//
//   $installer = "https://raw.githubusercontent.com/shawnrice/alfred-bundler/$bundler_version/bundler/meta/installer.sh";
//   $__cache   = $_SERVER[ 'HOME' ] . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";
//
//   // Make the directories
//   if ( ! file_exists( $__cache ) ) {
//     mkdir( $__cache );
//   }
//   if ( ! file_exists( "$__cache/installer" ) ) {
//     mkdir( "$__cache/installer" );
//   }
//   // Download the installer
//   // I'm throwing in the second bash command to delay the execution of the next
//   // exec() command. I'm not sure if that's necessary.
//   // https://github.com/shawnrice/alfred-bundler/archive/devel-latest.zip
//   exec( "curl -sL '$installer' > '$__cache/installer/installer.sh'" );
//   // Run the installer
//   exec( "sh '$__cache/installer/installer.sh'" );
//
// } // End __installBundler()
