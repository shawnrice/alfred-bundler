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
function __loadAsset( $name , $version = 'default' , $bundle , $type = 'php' , $json = '' ) {

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
      __doDownload( $json , $version , $__data, $kind , $name );
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

function __installAsset( $json , $version ) {
 global $bundler_version, $__data, $__cache;

 $json = json_decode( $json , TRUE );

 $name = $json[ 'name' ];
 $type = $json[ 'type' ];

 // Check to see if the version asked for is in the json; else, fallback to
 // default if exists; if not, throw error.
 if ( ! isset( $json[ 'versions' ][ $version ] ) ) {
  if ( ! isset( $json[ 'versions' ][ 'default' ] ) ) {
   echo "BUNDLER ERROR: No version found and cannot fall back to 'default' version!'";
   return FALSE;
  } else {
   $version = 'default';
  }
 }

 $get     = $json[ $version ][ 'get-method' ];
 $invoke  = $json[ $version ][ 'invoke' ];
 $install = $json[ $version ][ 'install' ];

 // Download the file(s).
 foreach ( $json[ '$versions' ][ $version ][ 'files' ] as $url ) {
  $file = __doDownload( $url );
  // File not found on the internets... DIE.
  if ( $file == '5' ) return FALSE;
 }

 if ( $get == 'zip' ) {
  // Unzip the file into the cache directory, silently.
  exec( "unzip -qo '$__cache/$file' -d '$__cache'" );
 } else if ( $get == 'tgz' || $get == 'tar.gz' ) {
  // Untar the file into the cache directory, silently.
  exec( "tar xzf '$__cache/$file' -C '$__cache'");
 }

 // For now, any other methods should be taken care of in the install
 // instructions (in the JSON).

 // Follow the installation instructions provided in the JSON file.
 // This probably should be changed to work in accordance with the
 // multiple file downloads above. However; well, that's for another
 // version. Right now, the installation procedures should just be
 // written out fully with what's above.
 if ( is_array( $install ) ) {
  foreach ( $install as $i ) {
   // Replace the strings in the INSTALL json with the proper values.
   $i = str_replace( "__FILE__" , $file , $i );
   $i = str_replace( "__DATA__" , "$__data/assets/$type/$name/$version", $i );
   exec( "$i" );
  }
 }

 // Make the invoke file.
 file_put_contents( "$__data/assets/$type/$name/$version/invoke" , $invoke );

 __delTree( $__cache ); // Cleanup by deleting the cache directory.

}

function __doDownload( $url ) {
 global $__cache;
 $file = pathinfo( parse_url( "$url", PHP_URL_PATH ) );
 exec( "curl -sL '$url' > '$__cache/" . $file['basename'] . "'" );
 if ( file_get_contents( "$__cache/$file" ) == 'Not Found' ) {
  echo "BUNDLER ERROR: Bad URL";
  return 5;
 } else {
  return $file['basename'];
 }
}