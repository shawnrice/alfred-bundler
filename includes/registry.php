<?php
/**
 *  This file serves as the backend point to register assets to track which
 *  workflows use which assets. The registry function will be extended in the
 *  future to allow for the uninstallation of orphaned assets.
 *
 **/

require_once( 'registry-functions.php' );

$bundler_version = "aries";
$__data = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";

if ( ! isset( $bundler_version ) ) {
  // Define the global bundler versions.
  $bundler_version       = file_get_contents( "$__data/meta/version_major" );
  $bundler_minor_version = file_get_contents( "$__data/meta/version_minor" );
}

if ( count( $argv ) != 4 ) {
  echo "Invoke the registry script with only three arguments.";
  die();
}

$bundle  = $argv[1];
$asset   = $argv[2];
$version = $argv[3];

__registerAsset( $bundle , $asset , $version );