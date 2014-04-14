<?php

require_once( 'includes/registry-functions.php' );
require_once( 'includes/install-functions.php' );

$__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
$__cache = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";


if ( ! isset( $bundler_version ) ) {
  // Define the global bundler versions.
  $bundler_version       = file_get_contents( "$__data/meta/version_major" );
  $bundler_minor_version = file_get_contents( "$__data/meta/version_minor" );
}

// Since this is a PHP bundler, we'll assume that the default type is PHP.
function __loadAsset( $name , $version = 'default' , $bundle , $type = 'php' , $json = '' ) {

  global $bundler_version;
  $__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";

  if ( empty( $version ) ) $version = 'default'; // This shouldn't be needed....
  if ( ! empty( $bundle ) ) __registerAsset( $bundle , $name , $version );

  // First: see if the file exists.
  if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );

    if ( $type == 'utility' ) {
      // Utilities should have only a single line invoke file, so that's
      // just fine to consider it a string.
      $cmd = escapeshellcmd("$__data/includes/gatekeeper.sh");
      exec( "$cmd '$name' '$__data/assets/$type/$name/$version/$invoke'");
    }

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
      __installAsset( $json , $version );
    }
  } else if ( ! empty( $json ) ) {
    // Since the json variable is not empty and the asset doesn't exist, we'll
    // assume it's new.
    __installAsset( $json , $version );
  }
  // Let's try this again.
  if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );
    $invoke = explode( "\n" , $invoke );
    foreach ( $invoke as $k => $v ) {
      if ( $v == 'null' ) {
        // Certain utilities might request only the basepath (i.e. Pashua) to be
        // invoked. To get around empty 'invoke' files that might trigger errors,
        // they are populated with the contents 'null' that we need to replace
        // with nothing.
        $v = '';
      }
      $invoke[$k] = "$__data/assets/$type/$name/$version/$v";
    }
    return $invoke;
  }
  // We shouldn't be here, but we'll do this anyway.
  echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know.";
  return FALSE;

} // End loadAsset()