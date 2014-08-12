<?php


if ( ! class_exists( 'AlfredBundlerIcon' ) ) :
/**
 *
 * A class used to get / manipulate icons...
 *
 * @package AlfredBundler
 * @since   Class available since Taurus 1
 * @TODO document further
 */
class AlfredBundlerIcon {

  public  $background;
  public  $data;
  public  $cache;


  /**
   * Sets the variables to deal with icons
   *
   * @todo decide exactly where the cache is going to live
   *
   * @since Taurus 1
   *
   * @param  object  $bundler   the bundler object that instantiates this
   */
  public function __construct( $bundler ) {

    $this->mime       = finfo_open( FILEINFO_MIME_TYPE );
    $this->bundler    = $bundler; // in case we need any of the variables...
    $this->data       = $this->bundler->data;
    // $this->cache      = $cache;
    $this->colors     = array();
    $this->fallback   = $this->data . '/bundler/meta/icons/default.png';

    $this->setBackground();

    $this->cache = $bundler->cache . '/color';

  }



/*****************************************************************************
 * BEGIN SETUP FUNCTIONS
 ****************************************************************************/

  /**
   * Creates necessary folders for icons
   *
   * @since Taurus 1
   *
   */
  private function setup() {

    if ( ! file_exists( $this->data . '/data' ) )
      mkdir( $this->data . '/data' );

    if ( ! file_exists( $this->cache ) )
      mkdir( $this->cache, 0775, TRUE );

  }


  /**
   * Set the 'background' variable to either 'light' or 'dark'
   *
   * As of Alfred v2.4 Build 277, environmental variables are available that
   * expose the color of the theme background as sRGBa. If those variables
   * are accessible, then we set the background with them.
   *
   * Otherwise, we fallback to a utility that comes with the bundler called
   * 'LightOrDark' that reads the NSColor Object in the plist that Alfred
   * uses to store the themes, and then it returns the value 'light' or 'dark'.
   *
   * @link [http://www.alfredforum.com/topic/4716-some-new-alfred-script-environment-variables-coming-in-alfred-24/] [Alfred 2.4 Environmental Variables]
   *
   * @since Taurus 1
   *
   */
  private function setBackground() {

    if ( isset( $_ENV[ 'alfred_version' ] ) ) {
      // Current Version >= v2.4:277
      $this->setBackgroundFromEnv();
    } else {
      // Current Version < v2.4:277 -- or -- no env vars are set. Maybe
      // you're running this outside of Alfred, eh?
      $this->setBackgroundFromUtil();
    }
    // Make sure we've set the background
    $this->validateBackground();

  }

  /**
   * Sets the background to 'light' or 'dark' based on environmental variables
   * based on a luminance calculation
   *
   * @see setBackground()
   * @see setBackgroundFromUtil()
   * @see getLuminance()
   *
   * @since Taurus 1
   *
   */
  private function setBackgroundFromEnv() {
    $pattern = "/rgba\(([0-9]{3}),([0-9]{3}),([0-9]{3}),([0-9.]{4,})\)/";
    preg_match_all( $pattern, $_ENV[ 'alfred_theme_background' ], $matches );

    $this->background = $this->getLuminance(  array( 'r' => $matches[1],
                                                     'g' => $matches[2],
                                                     'b' => $matches[3] ) );
  }


  /**
   * Sets the theme background color to either 'light' or 'dark'
   *
   * This function checks for the existence of a file and considers the contents
   * versus the modified time of the Alfredpreferences.plist where theme info
   * is stored. If necessary, it uses a utility to determine the 'light/dark'
   * status of the current Alfred theme. This method exists for versions of
   * Alfred pre 2.4 build 277.
   *
   * @see setBackground()
   * @see setBackgroundFromEnv()
   *
   * @since  Taurus 1
   *
   */
  private function setBackgroundFromUtil() {

    // The Alfred preferences plist where the theme information is stored
    $plist = "{$_SERVER[ 'HOME' ]}/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist";
    $cache = "{$this->data}/data/theme_background";
    $util  = "{$this->data}/bundler/includes/LightOrDark";

    if ( ! file_exists( "{$this->data}/data" ) ) {
      mkdir( "{$this->data}/data", 0775, TRUE );
    }

    if ( file_exists( $cache ) ) {
      if ( filemtime( $cache > $plist ) ) {
        $this->background = file_get_contents( $cache );
        return TRUE;
      }
    }

    if ( file_exists( $util ) ) {
      $this->background = exec( "'$util'" );
      file_put_contents( $cache, $this->background );
    } else {
      $this->background = 'dark';
    }

  }


  /**
   * Sets the theme background to dark if it isn't set
   *
   * @see setBackground()
   *
   * @since Taurus 1
   */
  public function validateBackground() {

    if ( ! isset( $this->background ) )
      $this->background = 'dark';

    if ( $this->background != 'light' && $this->background != 'dark' )
      $this->background = 'dark';

  }


/*****************************************************************************
 * END SETUP FUNCTIONS
 ****************************************************************************/

/*****************************************************************************
 * BEGIN ICON FUNCTIONS
 ****************************************************************************/

  /**
   * Returns a path to an icon
   *
   * @link [http://icons.deanishe.net] [Icon server documentation]
   *
   * @see parseIconArguments()
   * @see getSystemIcon()
   * @see getIcon()
   * @see downloadIcon()
   * @see tryServers()
   * @see validateImage()
   * @see color()
   * @see prepareIcon()
   *
   * @since Taurus 1
   *
   * @param   array  $args  Associative array that evaluates to
   *                        [ 'font' => font,
   *                          'name' => icon-name,
   *                          'color' => hex-color,
   *                          'alter' => hex-color|bool ].
   *                        The first two are mandatory; color defaults to
   *                        '000000', and alter defaults to FALSE.
   *
   * @return  mixed         FALSE on user error, and file path on success
   */
  public function icon( $args ) {

    if ( count( $args ) < 2 )
      return FALSE;

    if ( ! $args = $this->parseIconArguments( $args ) )
      return FALSE;

    // Return system icon or fallback
    if ( $args[ 'font' ] == 'system' )
      return $this->getSystemIcon( $args[ 'name' ] );

    $args = $this->prepareIcon( $args );

    $dir  = "{$this->data}/data/assets/icons";
    $icon = implode( '/', [ $dir, $args[ 'font' ], $args[ 'color' ], $args[ 'name' ] ] );

    if ( file_exists( $icon . '.png' ) ) {
      return $icon . '.png';
    }

    if ( $this->getIcon( $args ) ) {
      return $icon . '.png';
    }

    return $this->fallback;

  }


  /**
   * Validates and normalizes the arguments for the icon method
   *
   * @see icon()
   *
   * @since Taurus 1
   *
   * @param  array  $args  the arguments passed to icon()
   *
   * @return  array         a normalized version of the input
   */
  private function parseIconArguments( $args ) {

    $args[ 'font' ] = strtolower( trim( $args[ 'font' ] ) );
    if ( ! isset( $args[ 'alter' ] ) ) {
      $args[ 'alter' ] = FALSE;
    }
    if ( ! isset( $args[ 'color' ] ) ) {
      $args[ 'color' ] = '000000';
      $args[ 'alter' ] = TRUE;
    }
    return $args;

  }


  /**
   * Fetches a system icon path
   *
   * @since Taurus 1
   *
   * @param   string  $name  name of a system icon (with no extension)
   *
   * @return  string         path to system icon or fallback
   */
  private function getSystemIcon( $name ) {

    $icon = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/{$name}.icns";

    if ( file_exists( $icon ) )
      return $icon;

    return "{$this->data}/bundler/meta/icons/default.icns";
  }


  /**
   * Queries server to download non-local icon
   *
   * @see icon()
   *
   * @since Taurus 1
   *
   * @param   array  $args  Same args as icon()
   *
   * @return  string        Path to icon or fallback
   */
  public function getIcon( $args ) {

    $dir = implode( '/' , [ $this->data, 'data', 'assets', 'icons', $args[ 'font' ], $args[ 'color' ] ] );

    if ( ! file_exists( $dir ) )
      mkdir( $dir, 0775, TRUE );

    $icon = $dir . '/' . $args[ 'name' ];

    $suburl = implode( '/', [ 'icon', $args[ 'font' ], $args[ 'color' ], $args[ 'name' ] ] );
    $success = $this->tryServers( $suburl, $icon );

    // If success is true, then we downloaded the icon
    if ( $success !== TRUE ) {
      unlink( $icon . '.png' );
      return FALSE;
    }

    if ( $this->validateImage( $icon ) ) {
      return $icon . '.png';
    }

    // log error here
    unlink( $icon . '.png' );
    return $this->fallback;

  }


  /**
   * Cycles through a list of servers to download an icon
   *
   * The method tries to get the icon from the first server,
   * if the server is unreachable, then it will go down the
   * list until it succeeds. If none are available, then it
   * reports its failure.
   *
   * @see     icon()
   * @see     getIcon()
   * @see     downloadIcon()
   *
   * @since   Taurus 1
   *
   * @param   array   $args   associative array containing suburl
   *                          arguments: font, name, color
   * @param   string  $icon   filepath to icon destination
   *
   * @return  bool          TRUE on success, FALSE on failure
   */
  public function tryServers( $args, $icon ) {

    $servers = explode( PHP_EOL, file_get_contents( $this->data . "/bundler/meta/icon_servers" ) );

    // Cycle through the servers until we find one that is up.
    foreach ( $servers as $server ) :
      $url = $server . '/' . $args;
      $status = $this->downloadIcon( $url, $icon );
      if ( $status === 0 )
        return TRUE;
    endforeach;

    //logerrorhere
    return FALSE;

  }


  /**
   * Downloads an icon from a server
   *
   * @see     icon()
   * @see     getIcon()
   * @see     tryServers()
   *
   * @since   Taurus 1
   *
   * @param   string  $url   url to file
   * @param   string  $icon  path to file destination
   *
   * @return  int            cURL exit status
   */
  public function downloadIcon( $url, $icon ) {

    $c = curl_init( $url );
    $f = fopen( $icon . '.png', "w" );
    curl_setopt_array( $c, array(
          CURLOPT_FILE => $f,
          CURLOPT_HEADER => FALSE,
          CURLOPT_FOLLOWLOCATION => TRUE,
          CURLOPT_CONNECTTIMEOUT => 2 ) );

    curl_exec( $c );
    fclose( $f );

    $status = curl_errno( $c );
    $info = curl_getinfo($c);

    if ( $info[ 'http_code' ] !== 200 ) {
      // Log the error somehow here to show that it's not a good deal, yo.
      $status = 404;
    }

    curl_close( $c );

    return $status;

  }


  /**
   * Checks a file to see if it is a png.
   *
   * @since   Taurus 1
   *
   * @param   string  $image  file path to alleged image
   *
   * @return  bool            TRUE is a png, FALSE if not
   */
  public function validateImage( $image ) {
    if ( finfo_file( $this->mime, $image . '.png' ) == 'image/png' )
      return TRUE;
    return FALSE;

  }

/*****************************************************************************
 * END ICON FUNCTIONS
 ****************************************************************************/



/*****************************************************************************
 * BEGIN COLOR FUNCTIONS
 ****************************************************************************/

  /**
   * Normalizes and validates a color and adds it to the color array
   *
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  string          a hex normalized and validated hex color
   */
  public function color( $color ) {

    if ( ! in_array( $color, $this->colors ) ) {
      if ( ! $color = $this->checkHex( $color ) )
        return FALSE;
      $this->colors[ $color ][ 'hex' ] = $color;
    }
    return $color;

  }

  /**
   * Prepares the icon arguments for a proper query
   *
   * The color is first normalized. Then, if the `alter` variable
   * has not been set, then it just send the arguments back. Otherwise
   * a check is run to see if the theme background color is
   * the same as the proposed icon color. If not, then it sends back
   * the arguments. If so, then, if the `alter` variable is another
   * hex color, it returns that. If, instead, it is TRUE, then alters
   * the color accordingly so that the icon will best appear on
   * the background.
   *
   * @see     icon()
   * @see     color()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   array  $args  an associative array of args passed to icon()
   *
   * @return  array         possible altered array of args to load an icon
   */
  public function prepareIcon( $args ) {

    $args[ 'color' ] = $this->color( $args[ 'color' ] );

    if ( $args[ 'alter' ] === FALSE )
      return $args;

    if ( $this->brightness( $args[ 'color' ] ) != $this->background )
      return $args;


    if ( ! is_bool( $args[ 'alter' ] ) ) {
      if ( ! $args[ 'color' ] = $this->color( $args[ 'alter' ] ) )
        $args[ 'color' ] = '000000';

      return $args;
    }
    $args[ 'color' ] = $this->altered( $args[ 'color' ] );
    return $args;

  }


/*****************************************************************************
 * BEGIN GETTER FUNCTIONS  (well, we set when not already set)
 ****************************************************************************/

  /**
   * Returns the RGB of a color, and it sets it if necessary
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  hex color
   *
   * @return  array           associative array of RGB values
   */
  public function rgb( $color ) {

    if ( ! isset( $this->colors[ $color ][ 'rgb' ] ) ) {
      $this->colors[ $color ][ 'rgb' ] = $this->hexToRgb( $color );
    }
    return $this->colors[ $color ][ 'rgb' ];

  }



  /**
   * Returns the HSV of a color, and it sets it if necessary
   *
   * @link [https://en.wikipedia.org/wiki/HSL_and_HSV] [color forumulas]
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  hex color
   *
   * @return  array          associative array of HSV values
   */
  public function hsv( $color ) {

    if ( ! isset( $this->colors[ $color ][ 'hsv' ] ) ) {
      if ( ! isset( $this->colors[ $color ][ 'rgb' ] ) ) {
        $this->rgb( $color );
      }
      $this->colors[ $color ][ 'hsv' ] = $this->rgbToHsv( $this->rgb( $color ) );
    }
    return $this->colors[ $color ][ 'hsv' ];

  }


  /**
   * Retrieves the altered color of the original
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  string          a hex color (lighter or darker than the original)
   */
  public function altered( $color ) {

    if ( ! isset( $this->colors[ $color ][ 'altered' ] ) ) {
      if ( ! $this->colors[ $color ][ 'altered' ] = $this->cached( $color ) )
        $this->colors[ $color ][ 'altered' ] = $this->alter( $color );
    }
    return $this->colors[ $color ][ 'altered' ];

  }



  /**
   * Retrieves the luminance of a hex color
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  float           the luminance between 0 and 1
   */
  public function luminance( $color ) {

    if ( ! isset( $this->colors[ $color ][ 'luminance' ] ) ) {
      $this->colors[ $color ][ 'luminance' ] = $this->getLuminance( $color );
    }
    return $this->colors[ $color ][ 'luminance' ];

  }


  /**
   * Queries whether and image is 'light' or 'dark'
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  string          'light' or 'dark'
   */
  private function brightness( $color ) {

    if ( ! isset( $this->colors[ $color ][ 'brightness' ] ) ) {
      $this->colors[ $color ][ 'brightness' ] = $this->getBrightness( $color );
    }
    return $this->colors[ $color ][ 'brightness' ];

  }


  /**
   * Retrieves the cached result of an altered color
   *
   * @since Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  mixed           the altered hex color if found, FALSE if not
   */
  private function cached( $color ) {
    $cache = $this->cache . '/' . md5( $color );
    $key = md5( $color );

    if ( file_exists( $cache ) ) {
      return file_get_contents( $cache );
    }
    return FALSE;

  }


  /**
   * Caches an altered color in the color cache
   *
   * @since Taurus 1
   *
   * @param   string  $color  a hex color
   *
   */
  private function cache( $color ) {

    file_put_contents( $this->cache . '/' . md5( $color ), $this->colors[$color]['altered'] );

  }

/*****************************************************************************
 * END GETTER FUNCTIONS
 ****************************************************************************/

/*****************************************************************************
 * BEGIN CONVERSION FUNCTIONS
 ****************************************************************************/

  /**
   * Converts a Hex color to an RGB Color
   *
   * @see     color()
   * @see     prepareicon()
   * @see     checkhex()
   * @see     validatehex()
   * @see     normalizehex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     rgbtohex()
   * @see     rgbtohsv()
   * @see     hsvtorgb()
   * @see     alter()
   * @see     getluminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color A hex color
   * @return  array          An array of RGB values
   */
  public function hexToRgb( $hex ) {

    $r = hexdec( substr( $hex, 0, 2 ) );
    $g = hexdec( substr( $hex, 2, 2 ) );
    $b = hexdec( substr( $hex, 4, 2 ) );
    return [ 'r' => $r, 'g' => $g, 'b' => $b ];

  }


  /**
   * Converts an RGB color to a Hex color
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   array  $rgb an associative array of RGB values
   *
   * @return  string      a hex color
   */
  public function rgbToHex( $rgb ) {

    $hex .= str_pad( dechex( $rgb[ 'r' ] ), 2, '0', STR_PAD_LEFT );
    $hex .= str_pad( dechex( $rgb[ 'g' ] ), 2, '0', STR_PAD_LEFT );
    $hex .= str_pad( dechex( $rgb[ 'b' ] ), 2, '0', STR_PAD_LEFT );
    return $hex;

  }


  /**
   * Converts RGB color to HSV color
   *
   * @link [https://en.wikipedia.org/wiki/HSL_and_HSV] [color forumulas]
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   array $rgb associative array of rgb values
   *
   * @return  array     an associate array of hsv values
   */
  public function rgbToHsv( $rgb ) {

    $r = $rgb[ 'r' ];
    $g = $rgb[ 'g' ];
    $b = $rgb[ 'b' ];


    $min = min( $r, $g, $b );
    $max = max( $r, $g, $b );
    $chroma = $max - $min;

    //if $chroma is 0, then s is 0 by definition, and h is undefined but 0 by convention.
    if ( $chroma == 0 ) {
      return [ 'h' => 0, 's' => 0, 'v' => $max / 255 ];
    }

    if ( $r == $max ) {
      $h = ( $g - $b ) / $chroma;

      if ( $h < 0.0 )
        $h += 6.0;

    } else if ( $g == $max ) {
        $h = ( ( $b - $r ) / $chroma ) + 2.0;
      } else {  //$b == $max
      $h = ( ( $r - $g ) / $chroma ) + 4.0;
    }

    $h *= 60.0;
    $s = $chroma / $max;
    $v = $max / 255;

    return [ 'h' => $h, 's' => $s, 'v' => $v ];

  }

  /**
   * Convert HSV color to RGB
   *
   * @link    [https://en.wikipedia.org/wiki/HSL_and_HSV] [color forumulas]
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   array $hsv associative array of hsv values ( 0 <= h < 360, 0 <= s <= 1, 0 <= v <= 1)
   *
   * @return  array  An array of RGB values
   */
  public function hsvToRgb( $hsv ) {

    $h = $hsv[ 'h' ];
    $s = $hsv[ 's' ];
    $v = $hsv[ 'v' ];

    $chroma = $s * $v;
    $h /= 60.0;
    $x = $chroma * ( 1.0 - abs( ( fmod( $h, 2.0 ) ) - 1.0 ) );
    $min = $v - $chroma;

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

    $r = round( ( $r + $min ) * 255 );
    $g = round( ( $g + $min ) * 255 );
    $b = round( ( $b + $min ) * 255 );

    return [ 'r' => $r, 'g' => $g, 'b' => $b ];

  }


  /**
   * Gets the luminance of a color between 0 and 1
   *
   * @link    https://en.wikipedia.org/wiki/Luminance_(relative)
   * @link    https://en.wikipedia.org/wiki/Luma_(video)
   * @link    https://en.wikipedia.org/wiki/CCIR_601
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   mixed  $color a hex color (string) or an associative array of RGB values
   *
   * @return  float         Luminance on a scale of 0 to 1
   */
  public function getLuminance( $color ) {

    if ( ! is_array( $color ) )
      $rgb = $this->rgb( $color );
    else
      $rgb = $color;

    return ( 0.299 * $rgb[ 'r' ] + 0.587 * $rgb[ 'g' ] + 0.114 * $rgb[ 'b' ] ) / 255;

  }


  /**
   * Determines whether a color is 'light' or 'dark'
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  string          either 'light' or 'dark'
   */
  public function getBrightness( $color ) {

    if ( isset( $this->colors[ $color ][ 'brightness' ] ) )
      return $this->colors[ $color ][ 'brightness' ];

    if ( $this->luminance( $color ) > .5 )
      $this->colors[ $color ][ 'brightness' ] = 'light';
    else
      $this->colors[ $color ][ 'brightness' ] = 'dark';

    return $this->colors[ $color ][ 'brightness' ];

  }


  /**
   * Either lightens or darkens an image
   *
   * The function starts with a hex color and converts it into
   * an RGB color space and then to an HSV color space. The V(alue)
   * in HSV is set between 0 (black) and 1 (white), which is a
   * measure of 'brightness' where 0.5 is neutral. Thus, we retain
   * the hue and saturation and keep the relative brightness of the
   * color by pushing it on the other side of neutral but at the
   * same distance from neutral. E.g.: 0.7 becomes 0.3; 0.12 becomes
   * 0.88; 0.0 becomes 1.0; and 0.5 becomes 0.5.
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color  a hex color
   *
   * @return  string          a hex color
   */
  public function alter( $color ) {

    $hsv = $this->hsv( $color );
    $hsv[ 'v' ] = 1 - $hsv[ 'v' ];
    $rgb = $this->hsvToRgb( $hsv );
    $this->colors[ $color ][ 'altered' ] = $this->rgbToHex( $rgb );
    $altered = $this->color( $this->colors[ $color ][ 'altered' ] );

    $this->cache( $color ); // Cache the conversion

    return $this->colors[ $color ][ 'altered' ];

  }

 /*****************************************************************************
 * END CONVERSION FUNCTIONS
 ****************************************************************************/

 /*****************************************************************************
 * BEGIN VALIDATION / NORMALIZATION FUNCTIONS
 ****************************************************************************/

  /**
   * Checks to see if a color is a valid hex and normalizes the hex color
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     validateHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $color A hex color
   *
   * @return  mixed       FALSE on non-hex or hex color (normalized) to six characters and lowercased
   */
  public function checkHex( $hex ) {

    return $this->validateHex( $this->normalizeHex( $hex ) );

  }


  /**
   * Normalizes all hex colors to six, lowercase characters
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     validateHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $hex a hex color
   *
   * @return  string      a normalized hex color
   */
  public function normalizeHex( $hex ) {

    $hex = strtolower( str_replace( '#', '', $hex ) );
    if ( strlen( $hex ) == 3 )
      $hex = preg_replace( "/(.)(.)(.)/", "\\1\\1\\2\\2\\3\\3", $hex );
    return $hex;

  }

  /**
   * Validates a hex color
   *
   * @see     color()
   * @see     prepareIcon()
   * @see     checkHex()
   * @see     normalizeHex()
   * @see     rgb()
   * @see     hsv()
   * @see     luminance()
   * @see     brightness()
   * @see     altered()
   * @see     hexToRgb()
   * @see     rgbToHex()
   * @see     rgbToHsv()
   * @see     hsvToRgb()
   * @see     alter()
   * @see     getLuminance()
   * @see     getBrightness()
   *
   * @since   Taurus 1
   *
   * @param   string  $hex a hex color
   *
   * @return  mixed   FALSE on failure, the hex value on success
   */
  public function validateHex( $hex ) {

    if ( strlen( $hex ) != 3 && strlen( $hex ) != 6 )
      return FALSE; // Not a valid hex value
    if ( ! preg_match( "/([0-9a-f]{3}|[0-9a-f]{6})/", $hex ) )
      return FALSE; // Not a valid hex value
    return $hex;

  }


/*****************************************************************************
 * END VALIDATION / NORMALIZATION FUNCTIONS
 ****************************************************************************/
/*****************************************************************************
 * END COLOR FUNCTIONS
 ****************************************************************************/

}

endif;

