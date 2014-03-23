<?php

$home = exec( 'echo "$HOME"' );
$registered = $home . "/alfred.bundler/registered.json";


function registerLibrary( $name , $version = "default" , $language = "php" , $url = "" , $git = "" ) {

  $json = json_decode( utf8_encode( file_get_contents( $registered, TRUE ) ) );


  $git = exec( 'echo `which git`' );

}

// gem fetch
// gem install rake --version 0.3.1 --force --user-install
