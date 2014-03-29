<?php

/**
*  This is a kind of strange script. What it does is first, read the map, and
*  if the map isn't there, then it generates it and then reads it.
*
*  Next, if finds which operator is being requested and calls the appropriate
*  function that splits the argument string and then queries the map to see
*  if a match exists. If it does exist, then it echoes the version number to use;
*  otherwise, it echoes either "no package" when the package isn't found or
*  "no match" when the match isn't found. After each determination, the script
*  just dies as it's meant to be fed back into a bash script.
**/


$user = exec('echo $USER');
$data = "/Users/$user/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler/assets";

if (! file_exists("$data/python/map.json")) {
  // So, we don't have a map, so let's make one.
  include_once("generate-map.php");
}

$packages = json_decode( file_get_contents( "$data/python/map.json" ) , ARRAY_A );

if ( strpos( $argv[1] , "==" ) ) {
  equality( $argv[1] , $packages );
} else if ( strpos( $argv[1] , ">=" ) ) {
  greater( $argv[1] , $packages );
} else if ( strpos( $argv[1] , "<=" ) ) {
  less( $argv[1] , $packages );
}

function equality( $arg , $packages ) {
  $parts = explode( "==" , $arg );
  $p = array_keys($packages);
  if (! in_array( $parts[0] , $p ) ) {
    echo "no package";
    die();
  } else {
    if ( in_array( $parts[1], $packages[$parts[0]] ) ) {
      echo $parts[0] . "/" . $parts[1];
    } else {
      echo "no match";
      die();
    }
  }
}

function greater( $arg , $packages ) {
  $parts = explode( ">=" , $arg );
  $p = array_keys($packages);
  if (! in_array( $parts[0] , $p ) ) {
    echo "no package";
    die();
  } else {
    foreach ( $packages[$parts[0]] as $version ) {
      if ( $version >= $parts[1] ) {
        echo $parts[0] . "/" . $version;
        die();
      }
    }
    echo "no match";
    die();
  }
  die();
}

function less( $arg , $packages ) {
  $parts = explode( "<=" , $arg );
  $p = array_keys($packages);
  if (! in_array( $parts[0] , $p ) ) {
    echo "no package";
    die();
  } else {
    foreach ( $packages[$parts[0]] as $version ) {
      if ( $version <= $parts[1] ) {
        echo $parts[0] . "/" . $version;
        die();
      }
    }
    echo "no match";
    die();
  }
  die();
}
