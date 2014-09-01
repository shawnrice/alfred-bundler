<?php

$hex = get_hex();

function get_hex() {
    $hex = readline( "Please enter a HEX color: " );
    if ( ! ( validate_hex( $hex = normalize_hex( $hex ) ) ) ) {
        echo "That is not a valid hex color. Try again." . PHP_EOL;
        $hex = get_hex();
    }
    return $hex;
}
echo PHP_EOL;
echo 'Starting conversions for #' . $hex . PHP_EOL;
echo "================================" . PHP_EOL;
echo PHP_EOL;
$rgb = hex_to_rgb( $hex );
echo "Hex(#$hex)   =>   RGB({$rgb['r']}, {$rgb['g']}, {$rgb['b']})" . PHP_EOL;
$hsv = rgb_to_hsv( $rgb );
echo "RGB({$rgb['r']}, {$rgb['g']}, {$rgb['b']})   =>   HSV(" .
    round( $hsv['h'] ) . "°, " .
    round( $hsv['s'] * 100 ) . "%, " .
    round( $hsv['v'] * 100 ) . "%)" . PHP_EOL;
echo PHP_EOL;
echo "======== and back again ========" . PHP_EOL;
$rgb = hsv_to_rgb( $hsv );
echo PHP_EOL;
echo "HSV(" .
    round( $hsv['h'] ) . "°, " .
    round( $hsv['s'] * 100 ) . "%, " .
    round( $hsv['v'] * 100 ) . "%)   =>   RGB({$rgb['r']}, {$rgb['g']}, {$rgb['b']})" . PHP_EOL;
$hex = rgb_to_hex( $rgb );
echo "RGB({$rgb['r']}, {$rgb['g']}, {$rgb['b']})   =>   Hex(#$hex)" . PHP_EOL;
echo PHP_EOL;
echo "Luminance: " . round( luminance( $rgb ) * 100 ) . "% ";

if ( luminance( $rgb ) > 0.5 )
    echo "(light)";
else
    echo "(dark)";
echo PHP_EOL;
echo "================================" . PHP_EOL;

// Checks light or dark
function luminance( $rgb ) {
    return ( 0.3 * $rgb['r' ] + 0.59 * $rgb['g' ] + 0.11 * $rgb['b' ] ) / 255;
}

// normalizes a hex
function normalize_hex( $hex ) {
    $hex = strtolower( str_replace( '#', '', $hex ) );
    if ( strlen( $hex ) == 3 )
        $hex = preg_replace( "/(.)(.)(.)/", "\\1\\1\\2\\2\\3\\3", $hex );
    return $hex;
}

// Validates a hex
function validate_hex( $hex ) {
    if ( strlen( $hex ) != 3 && strlen( $hex ) != 6 )
        return FALSE; // Not a valid hex value
    if ( ! preg_match( "/([0-9a-f]{3}|[0-9a-f]{6})/", $hex ) )
        return FALSE; // Not a valid hex value
    return TRUE;
}

function hex_to_rgb( $hex ) {
    $r = hexdec( substr( $hex, 0, 2 ) );
    $g = hexdec( substr( $hex, 2, 2 ) );
    $b = hexdec( substr( $hex, 4, 2 ) );
    return [ 'r'   =>   $r, 'g'   =>   $g, 'b'   =>   $b ];
}

function rgb_to_hex( $rgb ) {
    $hex .= str_pad( dechex( $rgb['r'] ), 2, '0', STR_PAD_LEFT );
    $hex .= str_pad( dechex( $rgb['g'] ), 2, '0', STR_PAD_LEFT );
    $hex .= str_pad( dechex( $rgb['b'] ), 2, '0', STR_PAD_LEFT );
    return $hex;
}

function rgb_to_hsv( $rgb ) {
    $r = $rgb[ 'r' ];
    $g = $rgb[ 'g' ];
    $b = $rgb[ 'b' ];

    $min = min( $r, $g, $b );
    $max = max( $r, $g, $b );
    $chroma = $max - $min;

    if ( $chroma == 0 ) {
        //if $chroma is 0, then s is 0 by definition, and h is undefined but 0 by convention.
        return [ 'h'   =>   0, 's'   =>   0, 'v'   =>   $max / 255 ];
    }


    if ( $r == $max ) {
        $h = ( $g - $b ) / $chroma;

        if ( $h < 0.0 ) {
            $h += 6.0;
        }
    } else if ( $g == $max ) {
            $h = ( ( $b - $r ) / $chroma ) + 2.0;
        } else {  //$b == $max
        $h = ( ( $r - $g ) / $chroma ) + 4.0;
    }

    $h *= 60.0;
    $s = $chroma / $max;


    $v = $max / 255;

    return [ 'h'   =>   $h, 's'   =>   $s, 'v'   =>   $v ];
}


function hsv_to_rgb( $hsv ) {
    $h = $hsv[ 'h' ];
    $s = $hsv[ 's' ];
    $v = $hsv[ 'v' ];

    $chroma = $s * $v;
    $h /= 60.0;

    $x = $chroma * ( 1.0 - abs( ( fmod( $h, 2.0 ) ) - 1.0 ) );

    if ( $h < 1.0 ) {
        $r = $chroma;
        $g = $x;
    } else if ( $h < 2.0 ) {
            $r = $x;
            $g = $chroma;
        } else if ( $h < 3.0 ) {
            $g = $chroma;
            $b = $x;
        } else if ( $h < 4.0 ) {
            $g= $x;
            $b = $chroma;
        } else if ( $h < 5.0 ) {
            $r = $x;
            $b = $chroma;
        } else if ( $h <= 6.0 ) {
            $r = $chroma;
            $b = $x;
        }

    $min = $v - $chroma;

    $r = round( ( $r + $min ) * 255 );
    $g = round( ( $g + $min ) * 255 );
    $b = round( ( $b + $min ) * 255 );

    // $r = ( $r + $min ) * 255;
    // $g = ( $g + $min ) * 255;
    // $b = ( $b + $min ) * 255;

    return [ 'r'   =>   $r, 'g'   =>   $g, 'b'   =>   $b ];
}
