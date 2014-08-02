<?php

/**
 *
 * Helper script for the bash bundler to read a json file,
 * primarily used to check Gatekeeper calls.
 * 
 */


if ( count( $argv ) < 2 ) {
	echo "Usage: </path/to/file.json> <key>";
	exit( 1 );
}

if ( ! file_exists( $argv[1] ) ) {
	echo "Error: JSON file not found ({$argv[1]})";
	exit( 1 );
}

$json = json_decode( file_get_contents( $argv[1] ) );

if ( ! $json ) {
	echo "Error: JSON file is not valid";
	exit( 1 );
}

if ( ! isset ( $json->{$argv[2]} ) ) {
	echo "FALSE";
	exit( 0 );
} else {
	echo $json->{$argv[2]};
	exit( 0 );
}
