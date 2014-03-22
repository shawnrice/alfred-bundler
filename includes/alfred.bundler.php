<?php

$data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";

function registerAsset( ) {
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";

}

function loadAsset( $name , $version = "default" ) {
  $data = exec('echo $HOME') . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler";
  if ( file_exists( "$data/php/$name/$version/") ) {
    if ( file_exists( "$data/php/$name/$version/index.php") ) {
      return "$data/php/$name/$version/index.php";
    } else {
      return FALSE;
    }
  } else {
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
    mkdir($data);
  }

  // Download the installer
  file_put_contents( "$data/meta/installer.sh" , file_get_contents( "$git/installer.sh" ) );
  // Run the installer
  exec( "sh $data/meta/installer.sh" );


  // exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));



}
