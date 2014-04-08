<?php

/**
 * Makes all the directories in a path if they do not already exist.
 **/
function makeTree( $dir ) {
  $parts = explode( '/' , $dir );
  $path = '';
  foreach ( $parts as $part ) {
    if ( ! empty( $part ) ) {
      $path .= '/$part';
    }
    if ( ! file_exists( $path ) ) {
      if ( ! empty( $path ) ) {
        mkdir( $path );
      }
    }
  }
} // End makeTree()

// For convenience, from the PHP docs
function delTree( $dir ) {
   $files = array_diff( scandir( $dir ), array( '.' , '..' ) );
    foreach ($files as $file) {
      ( is_dir( "$dir/$file" ) ) ? delTree( "$dir/$file" ) : unlink( "$dir/$file" );
    }
  return rmdir( $dir );
} // End delTree()