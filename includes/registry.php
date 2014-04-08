<?php
/**
 *  This file serves as the backend point to register assets to track which
 *  workflows use which assets. The registry function will be extended in the
 *  future to allow for the uninstallation of orphaned assets.
 *
 **/

// Define the global bundler version.
$bundler_version="aries";

if ( count( $argv ) != 4 ) {
  echo "Invoke the registry script with only three arguments.";
  die();
}

$bundle  = $argv[1];
$asset   = $argv[2];
$version = $argv[3];

registerAsset( $bundle , $asset , $version );

function registerAsset( $bundle , $asset , $version ) {
  global $bundler_version;

  // Exit the function if there is no bundle passed.
  if ( empty( $bundle ) ) return 0;

  $data   = exec( 'echo $HOME' ) . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
  $update = FALSE;
  if ( ! file_exists( $data ) ) mkdir( $data );
  if ( ! file_exists( "$data/data" ) ) mkdir( "$data/data" );
  if ( file_exists( "$data/data/registry.json" ) ) {
    $registry = json_decode( file_get_contents( "$data/data/registry.json" ) , TRUE );
  }

  if ( isset( $registry ) && is_array( $registry ) ) {
    if ( isset( $registry[ $asset ] ) ) {
      if ( ! in_array( $version , $registry[ $asset ] ) ) {
        $registry[ $asset ][ $version ] = array();
        $update = TRUE;
      }
      if ( ! in_array( $bundle , $registry[ $asset ][ $version ] ) ) {
        $registry[ $asset ][ $version ][] = $bundle;
        $update = TRUE;
      }
    } else {
      $registry[$asset] = array();
      $registry[ $asset ][ $version ] = array( $bundle );
      $update = TRUE;
    }
  } else {
    $registry = array();
    $registry[ $asset ] = array();
    $registry[ $asset ][ $version ] = array();
    $registry[ $asset ][ $version ][] = $bundle;
    $update = TRUE;
  }

  if ( $update ) file_put_contents( "$data/data/registry.json" , utf8_encode( json_encode( $registry ) ) );

} // End registerAsset()
