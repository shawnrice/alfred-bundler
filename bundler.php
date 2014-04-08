<?php

require_once( 'includes/registry-functions.php' );
require_once( 'includes/helper-functions.php' );

$__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
$__cache = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";


if ( ! isset( $bundler_version ) ) {
  // Define the global bundler versions.
  $bundler_version       = file_get_contents( "$__data/meta/version_major" );
  $bundler_minor_version = file_get_contents( "$__data/meta/version_minor" );
}

// Since this is a PHP bundler, we'll assume that the default type is PHP.
function loadAsset( $name , $version = 'default' , $bundle , $type = 'php' , $json = '' ) {

  global $bundler_version;
  $__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";

  if ( empty( $version ) ) $version = 'default'; // This shouldn't be needed....
  if ( ! empty( $bundle ) ) registerAsset( $bundle , $name , $version );

  // First: see if the file exists.
  if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );
    $invoke = explode( "\n" , $invoke );
    foreach ( $invoke as $k => $v ) {
      $invoke[$k] = "$__data/assets/$type/$name/$version/$v";
    }
    return $invoke;
  }

  // Asset doesn't exist, so let's look to see if it's in the defaults.
  if ( file_exists( "$__data/meta/defaults/$name.json" ) && empty( $json ) ) {

    $info = json_decode( file_get_contents( "$__data/meta/defaults/$name.json" ) , TRUE);
    $versions = array_keys( $info[ 'versions' ] );
    $json = file_get_contents( "$__data/meta/defaults/$name.json" );
    if ( in_array( $version , $versions ) ) {
      doDownload( $json , $version , $__data, $kind , $name );
    }
  } else if ( ! empty( $json ) ) {
    // Since the json variable is not empty and the asset doesn't exist, we'll
    // assume it's new.
    doDownload( $json , $version , $__data, $kind , $name );
  }
  // Let's try this again.
  if ( file_exists( "$__data/assets/$kind/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$__data/assets/$kind/$name/$version/invoke" );
    $invoke = explode( "\n" , $invoke );
    foreach ( $invoke as $k => $v ) {
      $invoke[$k] = "$__data/assets/$kind/$name/$version/$v";
    }
    return $invoke;
  }
  // We shouldn't be here, but we'll do this anyway.
  echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know.";
  return FALSE;

} // End loadAsset()

function doDownload( $json , $version , $__data , $kind , $name ) {
  // The json variable contains everything we should need to complete this
  // process.
  $json  = json_decode( $json , TRUE );
  $cache = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler";

  // We're going to make the file tree if it doesn't already exist. See
  // helper function below for the recursion-ish technique.
  makeTree( "$__data/assets/$kind/$name/$version" );

  $dir = "$__data/assets/$kind/$name/$version";
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


function __installAsset( $json , $version ) {
 global $bundler_version, $__data, $__cache;

 $json = json_decode( $json , TRUE );

 $name = $json[ 'name' ];
 $type = $json[ 'type' ];

 // Check to see if the version asked for is in the json; else, fallback to
 // default if exists; if not, throw error.
 if ( ! isset( $json[ 'versions' ][ $version ] ) ) {
  if ( ! isset( $json['versions'][ 'default' ] ) ) {
   echo "BUNDLER ERROR: No version found and cannot fall back to 'default' version!'";
   return FALSE;
  } else {
   $version = 'default';
  }
 }

 $get     = $json[ $version ][ 'get-method' ];
 $invoke  = $json[ $version ][ 'invoke' ];
 $install = $json[ $version ][ 'install' ];

}

function doDownload( $url ) {
 global $__cache;
 $file = pathinfo( parse_url( "$url", PHP_URL_PATH ) );
 $return = exec( "curl -sL '$url' > '$__cache/" . $file['basename'] . "'" );
}

function doDirect( $url ) {
 global $__cache, $__data;
 exec( "curl -sL $url > '$__cache'");
}

function doZip( $url ) {
 global $__cache, $__data;
 exec( "curl -sL $url > '$__cache'");
 
}

function doTgz( $url ) {
 global $__cache, $__data;
 exec( "curl -sL $url > '$__cache'");
 
}

function doDmb( $url ) {
 global $__cache, $__data;
 exec( "curl -sL $url > '$__cache'");
 
}