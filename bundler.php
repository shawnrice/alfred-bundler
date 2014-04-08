<?php



function loadAsset( $name , $version = "default" , $bundle , $kind = "php" , $json = "" ) {
  global $bundler_version;
  $__data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";

  if ( empty( $version ) ) $version = "default"; // This shouldn't be needed....
  if ( ! empty( $bundle ) ) registerAsset( $bundle , $name , $version );

  // First: see if the file exists.
  if ( file_exists( "$__data/assets/$kind/$name/$version/invoke" ) ) {
    // It exists, so just return the invoke parameters.
    $invoke = file_get_contents( "$__data/assets/$kind/$name/$version/invoke" );
    $invoke = explode( "\n" , $invoke );
    foreach ( $invoke as $k => $v ) {
      $invoke[$k] = "$__data/assets/$kind/$name/$version/$v";
    }
    return $invoke;
  }
  // File doesn't exist, so let's look to see if it's in the defaults.
  if ( file_exists( "$__data/meta/defaults/$name.json" ) ) {

    $info = json_decode( file_get_contents( "$__data/meta/defaults/$name.json" ) , TRUE);
    $versions = array_keys( $info['versions'] );
    $json = file_get_contents( "$__data/meta/defaults/$name.json" );
    if ( in_array( $version , $versions ) ) {
      doDownload( $json , $version , $__data, $kind , $name );
    }
  }
  if ( ! empty( $json ) ) {
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

function doDownload( $json , $version , $__data , $kind , $name ) {
  // The json variable contains everything we should need to complete this
  // process.
  $json  = json_decode( $json , TRUE );
  $cache = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler";

  // We're going to make the file tree if it doesn't already exist. See
  // helper function below for the recursion-ish technique.
  makeTree( "$__data/assets/$kind/$name/$version" );

  $dir = "$__data/assets/$kind/$name/$version";
  // Add the invoke commands
  file_put_contents( "$dir/invoke" , $json['invoke'] );
  $method = $json['method'];

  if ( $method == "download" ) {
    if (count($json['versions'][$version]['files']) == 1) {
      $url = current($json['versions'][$version]['files']);
    }
    $file = pathinfo( parse_url( $url , PHP_URL_PATH ) );
    exec( "curl -sL '" . $url . "' > '$dir/" . $file['basename'] . "'");
  } else if ( $method == 'zip' ) {
    exec( "unzip -q '$dir/" . $file['basename'] . "'");
    // DO ZIP LOGIC HERE
  }

} // End doDownload()

/**
 * Installs the Alfred Bundler utility.
 **/
function __installBundler() {
  // Install the Alfred Bundler

  global $bundler_version;

  $installer = "https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version/meta/installer.sh";
  $__data    = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
  $__cache     = exec('echo $HOME') . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";

  // Make the directories
  if ( ! file_exists( $cache ) ) {
    mkdir( $cache );
  }
  if ( ! file_exists( "$__cache/installer" ) ) {
    mkdir( "$__cache/installer" );
  }
  // Download the installer
  // I'm throwing in the second bash command to delay the execution of the next
  // exec() command. I'm not sure if that's necessary.
  exec( "curl -sL '$installer' > '$cache/installer/installer.sh' && echo '..'" );
  // Run the installer
  exec( "sh '$cache/installer/installer.sh' && echo '..' " );

} // End installUtility()

/*******************************************************************************
 *
 ******************************************************************************/

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