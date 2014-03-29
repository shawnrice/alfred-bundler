<?php

$data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
if ( ! file_exists( "$data" ) ) {
  installUtility();
}
if ( file_exists( "info.plist" ) ) {
  $bundle = exec( "/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'" );
}

// Register: bundle . library
//$registry = json_decode( file_get_contents( "$data/data/registry.json" ) );



loadAsset( 'Workflows' , 'default' , 'com.me');

function registerAsset( $bundle , $asset ) {
  $data   = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  $update = FALSE;
  if ( ! file_exists( $data ) ) mkdir( $data );
  if ( ! file_exists( "$data/data" ) ) mkdir( "$data/data" );
  if ( file_exists( "$data/data/registry.json" ) ) {
    $registry = json_decode( file_get_contents( "$data/data/registry.json" ) , ARRAY_A );
  }

  if ( isset( $registry ) && is_array( $registry ) ) {
    if ( isset( $registry[$bundle] ) ) {
      if ( ! in_array( $asset , $registry[$bundle] ) ) {
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

}

function loadAsset( $name , $version = "default" , $bundle , $kind = "php" , $json = "" ) {
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  if ( empty( $version ) ) {
    $version = "default";
  }
  registerAsset( $bundle , $name , $version );

  // First: see if the file exists.
  // if ( file_exists( "$data/assets/$kind/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    // return file_get_contents( "$data/$kind/$name/$version/invoke" );
  // }
  // File doesn't exist, so let's look to see if it's in the defaults.
  if ( file_exists( "$data/meta/defaults/$name.json" ) ) {

    $info = json_decode( file_get_contents( "$data/meta/defaults/$name.json" ) , ARRAY_A);
    $info =  file_get_contents( "$data/meta/defaults/$name.json" ) ;
    print_r($info);

    $versions = array_keys( $info['versions'] );
    $json = file_get_contents( "$data/meta/defaults/$name.json" );
    if ( in_array( $version , $versions ) ) {
      return doDownload( $json , $version , $data, $kind , $name );
    }
  }
  if ( ! empty( $json ) ) {
    // Since the json variable is not empty and the asset doesn't exist, we'll
    // assume it's new.
    return doDownload( $json , $version , $data, $kind , $name );
  }

  // We shouldn't be getting here, but we'll do this anyway.
  echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know.";
  return FALSE;

}

function doDownload( $json , $version , $data , $kind , $name ) {
  // The json variable contains everything we should need to complete this
  // process.
  $json = json_decode( $json , ARRAY_A );


  // We're going to make the file tree if it doesn't already exist. See
  // helper function below for the recursion-ish technique.
  makeTree( "$data/assets/$kind/$name/$version" );

  $dir = "$data/assets/$kind/$name/$version";
  // Add the invoke commands
  file_put_contents( "$dir/invoke" , $json['invoke'] );
  $method = $json['method'];
  if ( $method == "download" ) {
    if (count($json['versions'][$version]['files']) == 1) {
      $url = current($json['versions'][$version]['files']);
    }
    $file = pathinfo( parse_url( $url , PHP_URL_PATH ) );
    echo "'$dir/" . $file['basename'] . "'";
    echo "HEREHERHE";
    exec( "curl -sL '" . $url . "' > '$dir/" . $file['basename'] . "'");
  }

}

function installUtility() {
  // We have to install the utility.
  // Well, we need to move this to the cache directory...
  $installer = "https://raw.githubusercontent.com/shawnrice/alfred-bundler/initial/meta/installer.sh";
  $data      = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  $cache     = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler";

  // Make the directories
  if ( ! file_exists( $cache ) ) {
    mkdir( $cache );
  }
  if ( ! file_exists( "$cache/installer" ) ) {
    mkdir( "$cache/installer" );
  }
  // Download the installer
  exec( "curl -sL '$installer' > '$cache/installer/installer.sh' && echo 'test'" );
  // Run the installer
  exec( "sh '$cache/installer/installer.sh'" );
}


function makeTree( $dir ) {
  $parts = explode( "/" , $dir );
  foreach ( $parts as $part ) {
    if ( ! empty( $part ) ) {
      $path .= "/$part";
    }
    if ( ! file_exists( $path ) ) {
      if ( ! empty( $path ) ) {
        mkdir($path);
      }
    }
  }
}
