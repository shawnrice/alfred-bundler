<?php

/**
 * 
 *  @TODO -- Commenting / Documentation
 * 
 */


require_once( __DIR__ . '/../AlfredBundler.php' );

$b = new AlfredBundlerInternalClass;

print_r( $argv );

if ( isset( $argv[1] ) ) {
  if ( file_exists( $argv[1] ) ) {
    $json = $argv[1];
  } else {
    echo "Error: json path not found ('{$argv[1]}')";
  }
}

if ( ! isset( $argv[2] ) )
  $version = 'default';
else
  $version = $argv[2];

if ( $b->installAsset( $json, $version ) ) {
  echo "Success";
  exit( 0 );
} else {
  // Output the error to STDERR.
  file_put_contents( 'php://stderr', 'Error with asset installation. See logs.' );
  exit( 1 );
}
