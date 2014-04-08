<?php

/***
  Usage: at minimum, you need to use load( 'asset_name' );
  This minimal usage works IF and ONLY IF the library is found in the
  meta/defaults folder as ASSET.json (case sensitive). If you want to use a
  version other than the newest (when the include files were written), then you
  need to specify a version. If the library or the library version is not included
  in the meta/defaults/ASSET.json file, then you need to append custom JSON to
  let the bundler know where to find the file and how to get it. Look at the
  meta/defaults/schema.json and the documentation to see how to contruct this JSON.
  If you think that the library you need should be included as a default (i.e.
  your use of it is not entirely an edge case), then send a pull request to the
  github repo with the appropriate json file.

  To use an asset, you need to send the name (case sensitive), version, kind,
  and custom json -- at most.

  You don't have to do anything to install the bundler or include it in anyway
  other than requiring this file because it will install the bundler if it isn't
  already there.

  Since this is the PHP bundler, the "kind" defaults to php. If you want to use
  a helper utility, then use the "utility" argument as the "kind."

  Remember, currently, the bundler is in early development, so there may be...
  "quirks."

  If you would like to contribute to the project, then find it on github or contact
  the repo author via the forums or the Packal contact page:
  http://www.packal.org/contact

  Cheers.

***/

// Define the global bundler version.
$bundler_version       = "aries";
$bundler_minor_version = '.1';

// Let's just make sure that the utility exists before we try to use it.
$__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
if ( ! file_exists( "$__data" ) ) {
  __installBundler();
}

// This file will be there because it either was or we just installed it.
require_once( "$__data/bundler.php" );

/**
 *  This is the only function the workflow author needs to invoke.
 *  If the asset to be loaded is a PHP library, then you just need to call the function,
 *  and the files will be required automatically.
 *
 *  If you are loading a "utility" application, then the function will return the full
 *  path to the function so that you can invoke it.
 *
 **/
function __load( $name , $version = 'default' , $type = 'php' , $json = '' ) {
  if ( file_exists( "info.plist" ) ) {
    // Grab the bundle ID from the plist file.
    $bundle = exec( "/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'" );
  } else {
    $bundle = '';
  }

  if ( $type == "php" ) {
    $assets = __loadAsset( $name , $version , $bundle , strtolower($type) , $json );
    foreach ($assets as $asset ) {
      require_once( $asset );
    }
    return TRUE;
  } else if ( $type == "utility" ) {
    $asset = __loadAsset( $name , $version , $bundle , strtolower($type) , $json );
    $asset = str_replace(' ' , '\ ' , $asset[0]);
    return $asset;
  } else {
    return __loadAsset( $name , $version , $bundle , strtolower($type) , $json );
  }

  // We shouldn't get here.
  return FALSE;

} // End __load()

/**
 * Installs the Alfred Bundler utility.
 **/
function __installBundler() {
  // Install the Alfred Bundler

  global $bundler_version, $__data;

  $installer = "https://raw.githubusercontent.com/shawnrice/alfred-bundler/$bundler_version/meta/installer.sh";
  $__cache   = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";

  // Make the directories
  if ( ! file_exists( $__cache ) ) {
    mkdir( $__cache );
  }
  if ( ! file_exists( "$__cache/installer" ) ) {
    mkdir( "$__cache/installer" );
  }
  // Download the installer
  // I'm throwing in the second bash command to delay the execution of the next
  // exec() command. I'm not sure if that's necessary.
  exec( "curl -sL '$installer' > '$__cache/installer/installer.sh'" );
  // Run the installer
  exec( "sh '$__cache/installer/installer.sh'" );

} // End installUtility()
