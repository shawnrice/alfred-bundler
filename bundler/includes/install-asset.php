<?php

/**
 * This file is part of the Alfred Bundler, released under the MIT licence.
 * Copyright (c) 2014 The Alfred Bundler Team
 * See https://github.com/shawnrice/alfred-bundler for more information
 *
 * @copyright  The Alfred Bundler Team 2014
 * @license    http://opensource.org/licenses/MIT  MIT
 * @version    Taurus 1
 * @link       http://shawnrice.github.io/alfred-bundler
 * @since      File available since Aries 1
 */

/**
 *
 *  @TODO -- Commenting / Documentation
 *
 */

require_once( __DIR__ . '/../AlfredBundler.php' );

$b = new AlfredBundlerInternalClass;

if ( isset( $argv[1] ) ) {
  if ( file_exists( $argv[1] ) ) {
    $json = $argv[1];
  } else {
    file_put_contents( 'php://stderr', "Error: json path not found ('{$argv[1]}')" );
    exit( 1 );
  }
}

if ( ! isset( $argv[2] ) )
  $version = 'latest';
else
  $version = $argv[2];

if ( $version1 = $b->installAsset( $json, $version ) ) {
  if ( $verson1 == $version ) {
    echo $version;
    exit( 0 );
  } else {
    file_put_contents( 'php://stderr', "Error: version {$version} is not valid." );
    file_put_contents( 'php://stderr', "Installed 'latest' instead." );
    echo $version;
    exit( 1 );
  }
}

// Output the error to STDERR.
file_put_contents( 'php://stderr', 'Error with asset installation. See logs.' );
exit( 1 );
