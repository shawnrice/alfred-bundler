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

function downloadFile( $file , $option = "default" ) {

  $HOME     = exec( 'echo $HOME' );
  $data     = "$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  $cache    = "$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler";
  $file     = "$data/meta/defaults/$file.json";
  $json     = json_decode( file_get_contents( $file ), ARRAY_A );
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

  if ( ! file_exists( "$data/assets" ) )
    mkdir( "$data/assets" );
  if ( ! file_exists( "$data/assets/$lang" ) )
    mkdir( "$data/assets/$lang" );
  if ( ! file_exists( "$data/assets/$lang/$name" ) )
    mkdir( "$data/assets/$lang/$name" );
  if ( ! file_exists("$data/assets/$lang/$name/$option") )
    mkdir( "$data/assets/$lang/$name/$option" );

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
    // Whoops. The commented out code goes awesomely haywire.
//     $dirs = explode( "/" , $dir );
//     $di="";
//     foreach( $dirs as $k => $d) {
//       for ($i=0; $i < (count($dirs) + 1); $i++ ) {
//         $di .= $dirs[$i];
//         if ( ! file_exists( "$di" ) ) {
//           mkdir("$di");
//           echo "$di
// ";
//         }
//         $di .= "/";
//       }
//     }
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

// For convenience, from the PHP docs
function delTree( $dir ) {
   $files = array_diff( scandir( $dir ), array( '.' , '..' ) );
    foreach ($files as $file) {
      ( is_dir( "$dir/$file" ) ) ? delTree( "$dir/$file" ) : unlink( "$dir/$file" );
    }
  return rmdir( $dir );
}

/**
 * Makes all the directories in a path if they do not already exist.
 **/
function makeTree( $dir ) {
  $parts = explode( "/" , $dir );
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
