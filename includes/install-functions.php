<?php
/**
 * This file contains PHP functions that can be reused to download and install
 * assets.
 **/

require_once( 'helper-functions.php' );

$bundler_version = 'aries';
$__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
$__cache = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";

function __installAsset( $json , $version ) {
 global $bundler_version, $__data, $__cache;
 if ( file_exists( $json ) ) {
  $json = file_get_contents( $json );
 }

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


 $invoke  = $json[ 'versions' ][ $version ][ 'invoke' ];
 $install = $json[ 'versions' ][ $version ][ 'install' ];

 // Download the file(s).
 foreach ( $json[ 'versions' ][ $version ][ 'files' ] as $url ) {
  $file = __doDownload( $url[ 'url' ] );
  if ( $file == '5' ) return FALSE;
  // File not found on the internets... DIE.
  if ( $url['method'] == 'zip' ) {
   // Unzip the file into the cache directory, silently.
   exec( "unzip -qo '$__cache/$file' -d '$__cache'" );
  } else if ( $url['method'] == 'tgz' || $url['method'] == 'tar.gz' ) {
   // Untar the file into the cache directory, silently.
   exec( "tar xzf '$__cache/$file' -C '$__cache'");
  }
 }

 // For now, any other methods should be taken care of in the install
 // instructions (in the JSON).

 // Make sure that the directory structure exists before we try to put anything there.
 __makeTree( "$__data/assets/$type/$name/$version" );

 // Follow the installation instructions provided in the JSON file.
 // This probably should be changed to work in accordance with the
 // multiple file downloads above. However; well, that's for another
 // version. Right now, the installation procedures should just be
 // written out fully with what's above.
 if ( is_array( $install ) ) {
  foreach ( $install as $i ) {
   // Replace the strings in the INSTALL json with the proper values.
   $i = str_replace( "__FILE__"  , "$__cache/$file" , $i );
   $i = str_replace( "__CACHE__" , "$__cache" , $i );
   $i = str_replace( "__DATA__"  , "$__data/assets/$type/$name/$version/", $i );
   exec( "$i" );
  }
 }
 
 // Make the invoke file.
 file_put_contents( "$__data/assets/$type/$name/$version/invoke" , $invoke );

 __delTree( $__cache ); // Cleanup by deleting the cache directory.

}

function __doDownload( $url ) {
 global $__cache;
 __makeTree( $__cache );
 $file = pathinfo( parse_url( "$url", PHP_URL_PATH ) );
 exec( "curl -sL '$url' > '$__cache/" . $file[ 'basename' ] . "'" );
 if ( file_get_contents( "$__cache/" . $file[ 'basename' ] ) == 'Not Found' ) {
  echo "BUNDLER ERROR: Bad URL";
  return 5;
 } else {
  return $file[ 'basename' ];
 }
}