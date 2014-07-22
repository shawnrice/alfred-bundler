<?php

class AlfredBundlerInternalClass {

  private $data;
  private $cache;
  private $major_version;
  private $plist;
  private $bundle;
  private $background;

  public function __construct( $plist ) {

    $this->major_version = file_get_contents( __DIR__ . '/meta/version_major' );
    $this->minor_version = file_get_contents( __DIR__ . '/meta/version_minor' );

    $this->data   = trim( "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->cache  = trim( "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->plist  = $plist;
    $this->bundle = exec( "/usr/libexec/PlistBuddy -c 'Print :bundleid' '{$this->plist}'" );

  }


/*******************************************************************************
 * BEGIN ICON FUNCTIONS
 * ****************************************************************************/

  /**
   * [icon description]
   * @param  {[type]} $name   [description]
   * @param  {[type]} $font   [description]
   * @param  {[type]} $color  [description]
   * @param  {[type]} $alter =             FALSE [description]
   * @return {[type]}         [description]
   */
  public function icon( $name, $font, $color, $alter = FALSE ) {

    // So, named colors can work, but we're going to test to see if the color is
    // written in a hex format; if so, we'll make sure that it's in a
    // non-abbreviated form.
    if ( $this->checkHex( $color ) )
      $color = $this->checkHex( $color );
    // Check to see if the 'alter' flag is true, if so, try to return the
    // appropriate light/dark icon.
    if ( $alter !== FALSE ) {

      // For background icon functions:
      // To determine the value, we're using a modified version of Clint Strong's
      // SetupIconsForTheme (https://github.com/clintxs/alfred-icons).
      // The new binary just returns 'light' or 'dark' after processing the current
      // theme file.
      if ( ! isset( $this->background ) ) {
        if ( file_exists( __DIR__ . "/includes/LightOrDark" ) )
          $this->background = exec( "'" . __DIR__ . "/includes/LightOrDark'" );
        else
          $this->background = FALSE;
      }

      if ( $this->background !== FALSE ) {
        if ( $this->checkColor( $color ) == $this->background ) {
          if ( $alter !== TRUE ) {
            // Use fallback color
            if ( $alter = $this->checkHex( $alter ) )
              $color = $alter;
          } else {
            if ( $this->background == 'dark' ) $color = $this->lightenColor( $color );
            else $color = $this->darkenColor( $color );
          }
        }
      }
    }

    $iconServers = explode( PHP_EOL, file_get_contents( __DIR__ . "/meta/icon_servers" ) );
    $iconDir = "{$this->data}/data/assets/icons";
    $iconPath = "{$iconDir}/{$font}/{$color}/{$name}.png";

    // If the icon has already been downloaded, then just return the path
    if ( file_exists( $iconPath ) )
      return $iconPath;

    if ( ! file_exists( "{$iconDir}/{$font}/{$color}" ) )
      mkdir( "{$iconDir}/{$font}/{$color}", 0775, TRUE );

    foreach( $iconServers as $server ) :
      // test the server somehow....
    endforeach;

    $success = $this->download( "{$server}/icon/{$font}/{$color}/{$name}", $iconPath );

    if ( $success === TRUE )
      return $iconPath;
    return FALSE;


    // Rewrite to a proper cURL request
        $icon = file_get_contents( "$bd_icon_server_url/$font/$color/$icon" );
        if ( $icon === FALSE )
          die( 'Failed to get icon' ); // Problem getting icon

        file_put_contents( $path, $icon );

        // We have the icon file. It's saved, so just send the path back now.
        return $path;

  }

  /**
   * [checkColor description]
   * @param {[type]} $color [description]
   */
  private function checkColor( $color ) {

    $color = $this->checkHex( $color );
    if ( $color === FALSE )
      return FALSE;

  	// See if RGB value is greater than 140, if so, return light, else, return dark
  	if ( ( ( ( hexdec( substr( $color, 0, 2 ) ) * 299 ) // R
  		     + ( hexdec( substr( $color, 2, 2 ) ) * 587 ) // G
  		     + ( hexdec( substr( $color, 4, 2 ) ) * 114 ) // B
  	  ) / 1000 ) > 140 )
  		return 'light';
  	else
  		return 'dark';
  }

  private function checkHex( $color ) {
    $color = str_replace('#', '', $color);

    // Check if string is either three or six characters
    if ( strlen( $color ) != 3 && strlen( $color ) != 6 )
      return FALSE; // Not a valid hex value
    if ( strlen( $color )  == 3 ) {
      // Check if string has only hex characters
      if ( ! preg_match( "/([0-9a-f]{3})/", $color) )
        return FALSE; // Not a valid hex value
      // Change three character hex to six character hex
      $color = preg_replace( "/(.)(.)(.)/", "\\1\\1\\2\\2\\3\\3", $color );
    } else {
      // Check if string has only hex characters
      if ( ! preg_match( "/([0-9a-f]{6})/", $color) )
        return FALSE; // Not a valid hex value
    }
    return $color;
  }

  function hexToRgb( $color ) {
		$r = hexdec( substr( $color, 0, 2 ) );
		$g = hexdec( substr( $color, 2, 2 ) );
		$b = hexdec( substr( $color, 4, 2 ) );
		return array( 'r' => $r, 'g' => $g, 'b' => $b );
	}

	function lightenColor( $color ) {
    $color = $this->checkHex( $color );
    if ( $color === FALSE ) return FALSE;

		$rgb = $this->hexToRgb( $color );
		$hsv = $this->rgb_to_hsv( $rgb['r'], $rgb['g'], $rgb['b'] );
		if ( $hsv[ 'v' ] < .5 ) {
			$hsv[ 'v' ] = 1 - $hsv[ 'v' ];
		}
		$rgb = $this->hsv_to_rgb( $hsv[ 'h' ], $hsv[ 's' ], $hsv[ 'v' ] );

		return dechex( $rgb[ 'r' ] ) . dechex( $rgb[ 'g' ] ) . dechex( $rgb[ 'b' ] );
	}

	function darkenColor( $color ) {
    $color = $this->checkHex( $color );
    if ( $color === FALSE ) return FALSE;

		$rgb = $this->hexToRgb( $color );
		$hsv = $this->rgb_to_hsv( $rgb['r'], $rgb['g'], $rgb['b'] );
		if ( $hsv[ 'v' ] > .5 ) {
			$hsv[ 'v' ] = 1 - $hsv[ 'v' ];
		}
		$rgb = $this->hsv_to_rgb( $hsv[ 'h' ], $hsv[ 's' ], $hsv[ 'v' ] );

		return dechex( $rgb[ 'r' ] ). dechex( $rgb[ 'g' ] ) . dechex( $rgb[ 'b' ] );
	}

	// I don't understand colors. RGB to HSV conversions from
	// https://stackoverflow.com/questions/3512311/how-to-generate-lighter-darker-color-with-php
	// http://www.actionscript.org/forums/showthread.php3?t=50746 and

	function rgb_to_hsv( $r, $g, $b ) {

		$r = ( $r / 255 );
		$g = ( $g / 255 );
		$b = ( $b / 255 );

    $max = max( $r, $g, $b );
		$min = min( $r, $g, $b );

		$delta = $max - $min;

		$v = $max;

    if ( $max != 0.0 )
      $s = $delta / $max;
    else
      $s = 0.0;

    if ( $s == 0.0 )
      $h = 0.0;
    else {
      if ( $r == $max )
        $h = ( $g - $b ) / $delta;
      else if ( $g == $max )
        $h = 2 + ( $b - $r ) / $delta;
      else if ( $b == $max )
        $h = 4 + ( $r - $g ) / $delta;
    }

    $h *= 60.0;

    if ( $h < 0 ) {
      $h += 360.0;
    }
    $h /= 360;
    return array( 'h' => $h / 360, 's' => $s, 'v' => $v );
	}

	function hsv_to_rgb( $h, $s, $v ) {
		$rgb = array();

		if ( $s == 0 ) {
			$r = $g = $b = $v * 255;
		}
		else {
			$var_h = $h * 6;
			$var_i = floor( $var_h );
			$var_1 = $v * ( 1 - $s );
			$var_2 = $v * ( 1 - $s * ( $var_h - $var_i ) );
			$var_3 = $v * ( 1 - $s * ( 1 - ( $var_h - $var_i ) ) );

			if       ( $var_i == 0 ) { $var_r = $v     ; $var_g = $var_3  ; $var_b = $var_1 ; }
			else if  ( $var_i == 1 ) { $var_r = $var_2 ; $var_g = $v      ; $var_b = $var_1 ; }
			else if  ( $var_i == 2 ) { $var_r = $var_1 ; $var_g = $v      ; $var_b = $var_3 ; }
			else if  ( $var_i == 3 ) { $var_r = $var_1 ; $var_g = $var_2  ; $var_b = $v     ; }
			else if  ( $var_i == 4 ) { $var_r = $var_3 ; $var_g = $var_1  ; $var_b = $v     ; }
			else 					 { $var_r = $v     ; $var_g = $var_1  ; $var_b = $var_2 ; }

			$r = $var_r * 255;
			$g = $var_g * 255;
			$b = $var_b * 255;
		}

		$rgb['r'] = $r;
		$rgb['g'] = $g;
		$rgb['b'] = $b;

		return $rgb;
	}

/*******************************************************************************
 * END ICON FUNCTIONS
 * ****************************************************************************/

    public function utility( $name, $version = 'default', $json = '' ) {
      if ( empty( $json ) ) {
        if ( file_exists( "{$this->data}/data/assets/utility/{$name}/{$version}/invoke" ) )
          return trim( file_get_contents( "{$this->data}/data/assets/utility/{$name}/{$version}/invoke" ) );
        else
          return $this->load( $name, 'utility', $version );
      } else {
        if ( file_exists( $json ) ) {
          return $this->load( $name, 'utility', $version, $json );
        }
      }
      return FALSE;
    }

    public function notify( $title, $message, $options = array() ) {

      if ( isset( $options[ 'sender' ] ) )
        $sender = "-sender '" . $options['sender'] . "'";
      else
        $sender = "";


      if ( isset( $options[ 'appIcon' ] ) )
        $appIcon = "-appIcon '" . $options['appIcon'] . "'";
      else
        $appIcon = "";


      if ( isset( $options[ 'contentImage' ] ) )
        $contentImage = "-contentImage '" . $options['contentImage'] . "'";
      else
        $contentImage = "";


      if ( isset( $options[ 'subtitle' ] ) )
        $subtitle = "-subtitle '" . $options['subtitle'] . "'";
      else
        $subtitle = "";


      if ( isset( $options[ 'group' ] ) )
        $group = "-group '" . $options['group'] . "'";
      else
        $group = "";


      if ( isset( $options[ 'sound' ] ) )
        $sound = "-sound '" . $options['sound'] . "'";
      else
        $sound = "";


      if ( isset( $options[ 'remove' ] ) )
        $remove = "-remove '" . $options['remove'] . "'";
      else
        $remove = "";


      if ( isset( $options[ 'list' ] ) )
        $list = "-list '" . $options['list'] . "'";
      else
        $list = "";


      if ( isset( $options[ 'activate' ] ) )
        $activate = "-activate '" . $options['activate'] . "'";
      else
        $activate = "";


      if ( isset( $options[ 'open' ] ) )
        $openURL = "-openURL '" . $options['openURL'] . "'";
      else
        $openURL = "";


      if ( isset( $options[ 'execute' ] ) )
        $execute = "-execute '" . $options['execute'] . "'";
      else
        $execute = "";


      $tn = $this->utility( 'Terminal-Notifier', 'default' );
      exec( "'{$this->data}/data/assets/utility/Terminal-Notifier/default/$tn' -title '{$title}' -message '{$message}'");
    }

    // This function should find a better name
    public function requireLibrary( $name, $version = 'default', $json = '' ) {
      if ( file_exists( "{$this->data}/data/assets/php/{$name}/{$version}/invoke" ) ) {
        require_once( trim( file_get_contents( "{$this->data}/data/assets/php/{$name}/{$version}/invoke" ) ) );
      } else {
        if ( $this->load( $name, 'php', $version, $json ) )
          require_once( trim( file_get_contents( "{$this->data}/data/assets/php/{$name}/{$version}/invoke" ) ) );
        else {
          return FALSE;
        }
      }
    }

    // How am I going to do this?
    // Also, I need to find a way to make sure that this can change and be
    // updated.
    //
    // Maybe I can create the composer.json file each time and then hash it and
    // compare it to one that has been created
    public function composer( $packages ) {
      $composerDir = "{$this->data}/data/assets/php/composer";
      if ( ! file_exists( $composerDir ) )
        mkdir( $composerDir, 0755, TRUE );

      if ( ! file_exists( "{$composerDir}/composer.phar" ) )
        $this->download( "https://getcomposer.org/composer.phar", "{$composerDir}/composer.phar" );
        // Add check to make sure the that file is complete above...

      if ( file_exists( "{$composerDir}/bundles/{$this->bundle}/autoload.php" ) )
        require_once( "{$composerDir}/bundles/{$this->bundle}/autoload.php" );
      else {
        if ( $this->installComposerPackage( $packages ) === TRUE ) {
          require_once( "{$composerDir}/bundles/{$this->bundle}/autoload.php" );
          return TRUE;
        } else {
          // Do some sort of log and throw an error
          return FALSE;
        }
      }
    }

    /**
     * [installComposerPackage description]
     * @param {array} $json list of composer ready packages with versions
     * @TODO: Write this damn function
     */
    private function installComposerPackage( $packages ) {

// Process
// php composer.phar install -d "/Users/Sven/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/php/composer/tmp"
// Composer could not find a composer.json file in /Users/Sven/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/php/composer/tmp
// So, here is the install recipe:
// (1) create cache install dir --
// (2) create composer.json file in that dir
// (3) run 'php composer.phar install' on that composer.json file
// (4) rename all packages and extensions to (get the versions from vendor/composer/installed.json)
//     (a) vendor/{$VENDOR}/{$PACKAGE}-{$VERSION}
//     (b) extensions/{$EXTENSION}-{$VERSION} ----- OR WE DON'T SUPPORT EXTENSIONS HERE -- YES!
// (5) move vendor/composer to bundles/{$BUNDLEID}/composer
// (6) move vendor/autoload.php to bundles/{$BUNDLEID}/autoload.php
// (6) Alter the following files:
        // autoload_psr4.php
        // autoload_namespaces.php
        // autoload_files.php
        // autoload_classmap.php
  // (a) Change $vendorDir and $baseDir in each.
  // (b) Alter $vendorDir . '$vendor/$package' to '$vendor/$package-$version' in each

// $installDir = "{$this->cache}/{$this->bundle}/composer";
// Step #1
// if ( ! file_exists( $installDir ) )
//   mkdir( "{$installDir}/composer", 0775, TRUE )
//
// Step #2
// $json = json_encode( array( "require" => $packages ) );
// file_put_contents( "{$installDir}/composer.json", $json );
//
// Step #3
// $cmd = "php '{$this->data}/data/assets/php/composer/composer.phar' install -q -d '{$installDir}'";
// exec( $cmd );

    }

  /**
   * Generic function to load an asset
   * @param  {[type]} $name    [description]
   * @param  {[type]} $type    [description]
   * @param  {[type]} $version [description]
   * @param  {[type]} $json    =             '' [description]
   * @return {[type]}          [description]
   */
  public function load( $name, $type, $version, $json = '' ) {
    // Do registry with the bundle stuff here: $this->bundle;
    // Do gatekeeper and path caching stuff as well
    if ( file_exists( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) )
      return trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );

    // Well, we need to install the asset

    if ( empty( $json ) ) {
      if ( $this->installAsset( "{$this->data}/bundler/meta/defaults/{$name}.json", $version ) )
        return trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
      else
        return FALSE;
    } else {
      if ( $this->installAsset( $json, $version ) )
        return trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
      else
        return FALSE;
    }
    // We shouldn't get here
    return FALSE;
  }

  private function readPlist( $plist, $key ) {
    if ( ! file_exists( $plist ) )
      return FALSE;

    return exec( "/usr/libexec/PlistBuddy -c 'Print :bundleid' '{$plist}'" );
  }

  public function download( $url, $file, $timeout = '3' ) {
    // Check the URL here

    // Make sure that the download directory exists
    if ( ! ( file_exists( dirname( $file ) ) && is_dir( dirname( $file ) ) ) )
      return FALSE;

    $ch = curl_init( $url );
    $fp = fopen( $file , "w");

    curl_setopt_array( $ch, array(
      CURLOPT_FILE => $fp,
      CURLOPT_HEADER => FALSE,
      CURLOPT_FOLLOWLOCATION => TRUE,
      CURLOPT_CONNECTTIMEOUT => $timeout
    ) );


    // Curl error codes: http://curl.haxx.se/libcurl/c/libcurl-errors.html
    if ( curl_exec( $ch ) === FALSE ) {
      curl_close( $ch );
      fclose( $fp );
      return curl_error( $ch) ;
    }

    curl_close( $ch );
    fclose( $fp );
    return TRUE;
  }

  private function installAsset( $json, $version = 'default' ) {
    if ( ! file_exists( $json ) ) {
      echo "Error: cannot install asset because the JSON file is not present";
      return FALSE;
    }

    // @TODO: Add error checking to make sure that the file is good JSON
    $json = json_decode( file_get_contents( $json ), TRUE );

    if ( $json == null )
      return FALSE;

    $installDir = "{$this->data}/data/assets/{$json[ 'type' ]}/{$json[ 'name' ]}/{$version}";
    // Make the installation directory if it doesn't exist
    if ( ! file_exists( $installDir ) )
      mkdir( $installDir, 0775, TRUE );

    // Make the temporary directory
    $tmpDir = "{$this->cache}/installers";
    if ( ! file_exists( $tmpDir ) )
      mkdir( $tmpDir, 0775, TRUE );

    $name = $json[ 'name' ];
    $type = $json[ 'type' ];

    // Check to see if the version asked for is in the json; else, fallback to
    // default if exists; if not, throw error.
    if ( ! isset( $json[ 'versions' ][ $version ] ) ) {
      if ( ! isset( $json[ 'versions' ][ 'default' ] ) ) {
        echo "BUNDLER ERROR: No version found and cannot fall back to 'default' version.'";
        $this->log( 'asset', "Cannot install {$type}: {$name}. Version '{$version}' not found." );
        return FALSE;
      } else {
        $version = 'default';
      }
    }
    $invoke  = $json[ 'versions' ][ $version ][ 'invoke' ];
    $install = $json[ 'versions' ][ $version ][ 'install' ];

    // Download the file(s).
    foreach ( $json[ 'versions' ][ $version ][ 'files' ] as $url ) {
      $file = pathinfo( parse_url( $url[ 'url' ], PHP_URL_PATH ) );
      $file = $file[ 'basename' ];
      if ( ! $this->download( $url[ 'url' ], "{$tmpDir}/{$file}" ) )
        return FALSE; // The download failed, for some reason.

      if ( $url[ 'method' ] == 'zip' ) {
        // Unzip the file into the cache directory, silently.
        exec( "unzip -qo '{$tmpDir}/{$file}' -d '{$tmpDir}'" );
      } else if ( $url[ 'method' ] == 'tgz' || $url[ 'method' ] == 'tar.gz' ) {
        // Untar the file into the cache directory, silently.
        exec( "tar xzf '{$tmpDir}/{$file}' -C '{$tmpDir}'");
      }
    }
    if ( is_array( $install ) ) {
      foreach ( $install as $i ) {
        // Replace the strings in the INSTALL json with the proper values.
        $i = str_replace( "__FILE__" , "{$tmpDir}/$file", $i );
        $i = str_replace( "__CACHE__", "{$tmpDir}/",      $i );
        $i = str_replace( "__DATA__" , "{$installDir}/",  $i );
        exec( $i );
      }
    }
    // Add in the invoke file
    file_put_contents( "{$installDir}/invoke", $invoke );
    $this->log( 'asset', "INFO: Installed '{$type}': '{$name}' -- version '{$version}'." );
    return TRUE;
  }

    /**
     * Prepends a datestamped message to a log file
     *
     * @param  {string} $log     name of log file
     * @param  {string} $message message to write to log
     * @return {[type]}          [description]
     */
    private function log( $log, $message ) {

      $log = "{$this->data}/data/logs/{$log}.log";

      // Set date/time to avoid warnings/errors.
      if ( ! ini_get('date.timezone') ) {
        $tz = exec( 'tz=`ls -l /etc/localtime` && echo ${tz#*/zoneinfo/}' );
        ini_set( 'date.timezone', $tz );
      }

      if ( ! file_exists( $log ) ) {
        if ( ! file_exists( dirname( $log ) ) )
          mkdir( dirname( $log ), 0775, TRUE );
          $file = array();
      } else {
        // This is needed because, Macs don't read EOLs well.
        if ( ! ini_get( 'auto_detect_line_endings' ) )
          ini_set( 'auto_detect_line_endings', TRUE );

        $file = file( $log );
        // @TODO: set variable for max log length
        // Check if the logfile is longer than 500 lines. If so, then trim the
        // last 50 of those.
        if ( count( $file ) >= 500 ) {
          for ( $i = 450; $i < 500; $i++ ) :
            unset( $file[ $i ] );
          endfor;
        }

      }

      $message = date( "D M d H:i:s T Y -- " ) . $message;
      array_unshift( $file, $message );

      file_put_contents( $log, implode( '', $file ) );
    }


}


// OLD VERSION

// require_once( 'includes/registry-functions.php' );
// require_once( 'includes/install-functions.php' );

// $__data  = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
// $__cache = $_SERVER[ 'HOME' ] . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";
//
//
// if ( ! isset( $bundler_version ) ) {
//   // Define the global bundler versions.
//   $bundler_version       = trim( file_get_contents( "$__data/meta/version_major" ) );
//   $bundler_minor_version = trim( file_get_contents( "$__data/meta/version_minor" ) );
// }
//
// // Since this is a PHP bundler, we'll assume that the default type is PHP.
// function __loadAsset( $name , $version = 'default' , $bundle , $type = 'php' , $json = '' ) {
//
//   global $bundler_version;
//   $__data = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
//
//
//   if (   empty( $version ) ) $version = 'default'; // This shouldn't be needed....
//   if ( ! empty( $bundle  ) ) __registerAsset( $bundle , $name , $version );
//
//   // First: see if the file exists.
//   if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
//     // It exists, so just return the invoke parameters.
//     $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );
//
//     if ( ( $type == 'utility' ) && ( ! empty( $invoke ) ) && ( $invoke != 'null' ) ) {
//       // Utilities should have only a single line invoke file, so that's
//       // just fine to consider it a string.
//
//       /////////////////////////////////////////////////////////////////////////////////
//       // Let's start the caching checks
//
//       $bd_asset_cache = "$__data/data/call-cache";
//
//       // Make sure the directory exists
//       if ( ! ( ( file_exists( $bd_asset_cache ) && is_dir( $bd_asset_cache ) ) ) )
//         mkdir( $bd_asset_cache );
//
//       // Cache path for this call
//       $key       = md5( "$name-$version-$type-$json" );
//       $cachepath =      "$bd_asset_cache/$key";
//
//       if ( file_exists( "$cachepath" ) ) {
//         $path = file_get_contents( "$cachepath" );
//         if ( file_exists( "$path" ) ) {
//           // The cache has been found, and we have the asset there already.
//           return array( $path );
//         }
//       }
//
//       // The cache hasn't been found, so we'll call gatekeeper
//       $invoke = str_replace("\n", '', $invoke);
//       if ( strpos( $invoke, '.app' ) !== FALSE ) {
//         // Invoke Gatekeeper only when the utility is a .app.
//         // ech
//
//         exec( "bash '$__data/includes/gatekeeper.sh' '$name' '$__data/assets/$type/$name/$version/$name.app'", $output, $return );
//         if ( $return !== 0 ) {
//           return $output[0];
//         } else if ( $return == 0 ) {
//           file_put_contents( "$bd_asset_cache/$key", "$__data/assets/$type/$name/$version/$invoke" );
//           return array( "$__data/assets/$type/$name/$version/$invoke" );
//         }
//       }
//     }
//
//     $invoke = explode( "\n" , $invoke );
//     foreach ( $invoke as $k => $v ) {
//       $invoke[$k] = "$__data/assets/$type/$name/$version/$v";
//     }
//     return $invoke;
//   }
//
//   // Asset doesn't exist, so let's look to see if it's in the defaults.
//   if ( ! empty( $json ) ) {
//     // Since the json variable is not empty and the asset doesn't exist, we'll
//     // assume it's new.
//     __installAsset( $json , $version );
//   } else if ( file_exists( "$__data/meta/defaults/$name.json" ) && empty( $json ) ) {
//     $info = json_decode( file_get_contents( "$__data/meta/defaults/$name.json" ) , TRUE);
//     $versions = array_keys( $info[ 'versions' ] );
//     $json = file_get_contents( "$__data/meta/defaults/$name.json" );
//     if ( in_array( $version , $versions ) ) {
//       __installAsset( $json , $version );
//     }
//   }
//
//   // Let's try this again.
//   if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
//     // It exists, so just return the invoke parameters.
//     $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );
//     $invoke = explode( "\n" , $invoke );
//     foreach ( $invoke as $k => $v ) {
//       if ( $v == 'null' ) {
//         // Certain utilities might request only the basepath (i.e. Pashua) to be
//         // invoked. To get around empty 'invoke' files that might trigger errors,
//         // they are populated with the contents 'null' that we need to replace
//         // with nothing.
//         $v = '';
//       }
//       $invoke[$k] = "$__data/assets/$type/$name/$version/$v";
//     }
//     return $invoke;
//   }
//   // We shouldn't be here, but we'll do this anyway; well, an invalid asset was called.
//   echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know.";
//   return FALSE;
//
// } // End loadAsset()
