<?php

/**
 *
 *  This is a temporary file that serves as proof of concept. It should be
 *  rewritten in a more performant language.
 *
 *  Also, there is limited to no error checking here.
 *
 *
 **/

if ( ! isset( $bundler_version ) ) {
  // Define the global bundler versions.
  $bundler_version       = file_get_contents( "$__data/meta/version_major" );
  $bundler_minor_version = file_get_contents( "$__data/meta/version_minor" );
}

function downloadFile( $file , $version = "default" ) {

  global $bundler_version;

  $HOME     = exec( 'echo $HOME' );
  $data     = "$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
  $cache    = "$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";
  $file     = "$data/meta/defaults/$file.json";
  $json     = json_decode( file_get_contents( $file ), TRUE );
  $name     = $json[ 'name' ];
  $lang     = $json[ 'language' ];
  $method   = $json[ 'method' ];
  $invoke   = $json[ 'invoke' ];
  $versions = array_keys( $json[ 'versions' ] );

  if ( in_array( $option, $versions ) ) {
    $version = $json[ 'versions' ][ $option ];
  } else {
    return FALSE;
  }

  if ( ! file_exists("$data/assets/$lang/$name/$option") )
    makeTree( "$data/assets/$lang/$name/$option" );

  if ( $method == 'download' ) {
//    if ( $version['zip'] == 'true' ) {
      // Nothing yet, well, download the zip file. Check function below.
//      $return = download_zip( "$data/assets/$lang/$name/$option" , $version['files']['one'] , 'alp-master/alp' , '' , $cache );
//    } else {
      $return = direct_download( "$data/assets/$lang/$name/$option" , $version['files'], "" );
//    }
  }

  file_put_contents( "$data/assets/$lang/$name/$option/invoke", $invoke );

  return $return;

}

function direct_download( $dir , $files , $data ) {
  if ( ! file_exists("$dir") ) {
    mkdir( "$dir" );
  }
  foreach ( $files as $file ) {
    $f = pathinfo( parse_url( "$file", PHP_URL_PATH ) );
    $return = exec( "curl -sL '$file' > '$dir/" . $f['basename'] . "'" );
  }
  return TRUE;
}

function download_zip( $dir , $url , $folder , $data , $cache ) {
  if ( ! file_exists( "$cache" ) ) mkdir( "$cache" ); // Make cache directory
  $id = uniqid();
  mkdir( "$cache/$id" );
  exec( "curl -sL '$url' > '$cache/$id/$id.zip'" );
  exec( "unzip -qo '$cache/$id/$id.zip' -d '$cache/$id'" );
  if ( file_exists( "$dir" ) ) delTree( $dir );
  exec( "mv -f '$cache/$id/$folder' '$dir'" );
  return TRUE;
}
