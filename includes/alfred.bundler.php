<?php

$data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";

if ( ! file_exists( "$data" ) ) {
  installUtility();
}

function registerAsset( $json ) {
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";

  // Here, we'll read the json in order to register the asset, download it, and make it available
  // Still need to write the register function.
}

function loadAsset( $name , $version = "default" ) {
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  if ( file_exists( "$data/assets/php/$name/$version") ) {
      $files = scandir("$data/assets/php/$name/$version");

      // Make sure that we get rid of anything that isn't a php file
      foreach ( $files as $k => $f ) {

        if ( ! ( pathinfo($f, PATHINFO_EXTENSION) === "php" ) ) {
          unset( $files[$k] );
        }
        else {
          // Add the full path.
          $files[$k] = "$data/assets/php/$name/$version/$f";
        }
      }
      return $files;
  } else {
    if ( file_exists( "$data/meta/defaults/$name.json") ) {
      require_once( "$data/download.php" );
      $return = downloadFile( $name , $version );

      // Okay, we've downloaded the files, now, let's include them.

      $files = scandir("$data/assets/php/$name/$version");

      // Make sure that we get rid of anything that isn't a php file
      foreach ( $files as $k => $f ) {
        if ( ! ( pathinfo($f, PATHINFO_EXTENSION) == "php" ) ) {
          unset( $files[$k] );
        }
        else {
          // Add the full path.
          $files[$k] = "$data/php/$name/$version/$f";
        }
      }
      return $files;

    }
    return FALSE;
  }

}

function installUtility() {
  // We have to install the utility.
  $git = "https://raw.githubusercontent.com/shawnrice/alfred-bundler/master";
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";

  // Make the directories
  if ( ! file_exists( $data) ) {
    mkdir($data);
  }
  if ( ! file_exists( "$data/meta" ) ) {
    mkdir( "$data/meta" );
  }

  // Download the installer
  exec( "curl -sL '$git/meta/installer.sh' > '$data/meta/installer.sh'" );
  // file_put_contents( "$data/meta/installer.sh" , file_get_contents( "$git/installer.sh" ) );
  // Run the installer
  // At first, I was going to background this, but... well, that would throw errors.
  exec( "sh '$data/meta/installer.sh'" );

  // Run it in the background
  // exec(sprintf("%s > /dev/null 2>&1 &", $cmd));

}
