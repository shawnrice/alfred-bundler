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
$bundler_version="aries";

// Let's just make sure that the utility exists before we try to use it.
$data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
if ( ! file_exists( "$data" ) ) {
  installUtility();
}

/**
 *  This is the only function the workflow author needs to invoke.
 *  If the asset to be loaded is a PHP library, then you just need to call the function,
 *  and the files will be required automatically.
 *
 *  If you are loading a "utility" application, then the function will return the full
 *  path to the function so that you can invoke it.
 *
 **/
function __load( $name , $version = 'default' , $kind = 'php' , $json = '' ) {
  if ( file_exists( "info.plist" ) ) {
    // Grab the bundle ID from the plist file.
    $bundle = exec( "/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'" );
  } else {
    $bundle = '';
  }

  if ( $kind == "php" ) {
    $assets = loadAsset( $name , $version , $bundle , strtolower($kind) , $json );
    foreach ($assets as $asset ) {
      require_once( $asset );
    }
    return TRUE;
  } else if ( $kind == "utility" ) {
    $asset = loadAsset( $name , $version , $bundle , strtolower($kind) , $json );
    $asset = str_replace(' ' , '\ ' , $asset[0]);
    return $asset;
  } else {
    return loadAsset( $name , $version , $bundle , strtolower($kind) , $json );
  }

  // We shouldn't get here.
  return FALSE;

} // End __load()



function loadAsset( $name , $version = "default" , $bundle , $kind = "php" , $json = "" ) {
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";

  if ( empty( $version ) ) $version = "default"; // This shouldn't be needed....
  if ( ! empty( $bundle ) ) registerAsset( $bundle , $name , $version );

  // First: see if the file exists.
  if ( file_exists( "$data/assets/$kind/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$data/assets/$kind/$name/$version/invoke" );
    $invoke = explode( "\n" , $invoke );
    foreach ( $invoke as $k => $v ) {
      $invoke[$k] = "$data/assets/$kind/$name/$version/$v";
    }
    return $invoke;
  }
  // File doesn't exist, so let's look to see if it's in the defaults.
  if ( file_exists( "$data/meta/defaults/$name.json" ) ) {

    $info = json_decode( file_get_contents( "$data/meta/defaults/$name.json" ) , TRUE);
    $versions = array_keys( $info['versions'] );
    $json = file_get_contents( "$data/meta/defaults/$name.json" );
    if ( in_array( $version , $versions ) ) {
      doDownload( $json , $version , $data, $kind , $name );
    }
  }
  if ( ! empty( $json ) ) {
    // Since the json variable is not empty and the asset doesn't exist, we'll
    // assume it's new.
    doDownload( $json , $version , $data, $kind , $name );
  }
  // Let's try this again.
  if ( file_exists( "$data/assets/$kind/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$data/assets/$kind/$name/$version/invoke" );
    $invoke = explode( "\n" , $invoke );
    foreach ( $invoke as $k => $v ) {
      $invoke[$k] = "$data/assets/$kind/$name/$version/$v";
    }
    return $invoke;
  }
  // We shouldn't be here, but we'll do this anyway.
  echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know.";
  return FALSE;

} // End loadAsset()

function doDownload( $json , $version , $data , $kind , $name ) {
  // The json variable contains everything we should need to complete this
  // process.
  $json  = json_decode( $json , TRUE );
  $cache = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler";

  // We're going to make the file tree if it doesn't already exist. See
  // helper function below for the recursion-ish technique.
  makeTree( "$data/assets/$kind/$name/$version" );

  $dir = "$data/assets/$kind/$name/$version";
  // Add the invoke commands
  file_put_contents( "$dir/invoke" , $json['invoke'] );
  $method = $json['method'];

  if ( $method == "download" ) {
    if (count($json['versions'][$version]['files']) == 1) {
      $url = current($json['versions'][$version]['files']);
    }
    $file = pathinfo( parse_url( $url , PHP_URL_PATH ) );
    exec( "curl -sL '" . $url . "' > '$dir/" . $file['basename'] . "'");
  } else if ( $method == 'zip' ) {
    exec( "unzip -q '$dir/" . $file['basename'] . "'");
    // DO ZIP LOGIC HERE
  }

} // End doDownload()

/**
 * Installs the Alfred Bundler utility.
 **/
function installUtility() {
  // We have to install the utility.
  // Well, we need to move this to the cache directory...
  $installer = "https://raw.githubusercontent.com/shawnrice/alfred-bundler/initial/meta/installer.sh";
  $data      = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  $cache     = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler";

  // Make the directories
  if ( ! file_exists( $cache ) ) {
    mkdir( $cache );
  }
  if ( ! file_exists( "$cache/installer" ) ) {
    mkdir( "$cache/installer" );
  }
  // Download the installer
  exec( "curl -sL '$installer' > '$cache/installer/installer.sh' && echo 'test'" );
  // Run the installer
  exec( "sh '$cache/installer/installer.sh'" );

} // End installUtility()

/**
 * Makes all the directories in a path if they do not already exist.
 **/
function makeTree( $dir ) {
  $parts = explode( "/" , $dir );
  $path = "";
  foreach ( $parts as $part ) {
    if ( ! empty( $part ) ) {
      $path .= "/$part";
    }
    if ( ! file_exists( $path ) ) {
      if ( ! empty( $path ) ) {
        mkdir( $path );
      }
    }
  }
} // End makeTree()