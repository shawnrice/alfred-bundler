<?php
/**
 *  This file serves as the backend point to register assets to track which
 *  workflows use which assets. The registry function will be extended in the
 *  future to allow for the uninstallation of orphaned assets.
 *
 **/

if ( count( $argv ) != 4 ) {
  echo "Invoke the registry script with only three arguments.";
  return 5;
}

$bundle  = $argv[1];
$asset   = $argv[2];
$version = $argv[3];

registerAsset( $bundle , $asset , $version );

function registerAsset( $bundle , $asset , $version ) {
  // Exit the function if there is no bundle passed.
  if ( empty( $bundle ) ) return 0;

  $data   = exec( 'echo $HOME' ) . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  $update = FALSE;
  if ( ! file_exists( $data ) ) mkdir( $data );
  if ( ! file_exists( "$data/data" ) ) mkdir( "$data/data" );
  if ( file_exists( "$data/data/registry.json" ) ) {
    $registry = json_decode( file_get_contents( "$data/data/registry.json" ) , TRUE );
  }

  if ( isset( $registry ) && is_array( $registry ) ) {
    if ( isset( $registry[$bundle] ) ) {
      if ( ! in_array( "$asset-$version" , $registry[$bundle] ) ) {
        $registry[$bundle][] = "$asset-$version";
        $update = TRUE;
      }
    } else {
      $register[$bundle]   = array( "$asset-$version" );
      $update = TRUE;
    }
  } else {
    $registry = array( $bundle => array("$asset-$version") );
    $update   = TRUE;
  }

  if ( $update ) file_put_contents( "$data/data/registry.json" , json_encode( $registry ) );

} // End registerAsset()