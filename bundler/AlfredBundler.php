<?php

/**
 * Alfred Bundler PHP API file
 *
 * Main PHP interface for the Alfred Dependency Bundler.
 *
 * LICENSE: GPLv3 {@link https://www.gnu.org/licenses/gpl-3.0.txt}, or see
 * LICENSE file in the Alfred Bundler directory.
 *
 *
 * @copyright  Shawn Patrick Rice 2014
 * @license    https://www.gnu.org/licenses/gpl-3.0.txt  GPL v3
 * @version    Taurus 1
 * @link       http://shawnrice.github.io/alfred-bundler
 * @since      File available since Aries 1
 */


/**
 * Internal API Class for Alfred Bundler
 *
 * This class is the only one that you should interact with. The rest of the
 * magic that the bundler performs happens under the hood. Also, the backend
 * of the bundler (here the 'AlfredBundlerInternalClass') may change; however,
 * this wrapper will continue to work with the bundler API for the remainder of
 * this major version.
 *
 * @since     Class available since Taurus 1
 *
 */
class AlfredBundlerInternalClass {

  /**
  * A filepath to the bundler directory
  * @access private
  * @var string
  */
  private   $data;

  /**
  * A filepath to the bundler cache directory
  * @access private
  * @var string
  */
  private   $cache;

  /**
  * The MAJOR version of the bundler (which API to use)
  * @access private
  * @var string
  */
  private   $major_version;

  /**
  * The MINOR version of the bundler
  * @access private
  * @var string
  */
  private   $minor_version;

  /**
  * Filepath to an Alfred info.plist file
  * @access private
  * @var string
  */
  private   $plist;

  /**
  * The Bundle ID of the workflow using the bundler
  * @access private
  * @var string
  */
  private   $bundle;

  /**
  * The name of the workflow using the bundler
  * @access private
  * @var string
  */
  private   $name;

  /**
  * The background 'color' of the user's current theme in Alfred (light or dark)
  * @access private
  * @var string
  */
  private   $background;


  /**
   * The class constructor
   *
   * Sets necessary variables.
   *
   * @access public
   * @param  {string} $plist Path to workflow 'info.plist'
   * @return {bool}          Return 'true' regardless
   */
  public function __construct( $plist ) {

    $this->major_version = file_get_contents( __DIR__ . '/meta/version_major' );
    $this->minor_version = file_get_contents( __DIR__ . '/meta/version_minor' );

    $this->data   = trim( "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->cache  = trim( "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->plist  = $plist;
    $this->bundle = exec( "/usr/libexec/PlistBuddy -c 'Print :bundleid' '{$this->plist}'" );
    $this->name   = exec( "/usr/libexec/PlistBuddy -c 'Print :name'     '{$this->plist}'" );

    $this->setBackground();

    // Let's just return something
    return TRUE;
  }

  /**
   * Load an asset using a generic function
   *
   * @TODO Fix registry and gatekeeper calls
   *
   * @since  Taurus 1
   * @access public
   *
   * @param  {string} $type      Type of asset
   * @param  {string} $name      Name of asset
   * @param  {string} $version   Version of asset to load
   * @param  {string} $json = '' Path to json file
   * @return {mixed}             Returns path to utility on success, FALSE on failure
   */
  public function load( $type, $name, $version, $json = '' ) {

    // Currently the ways we implement gatekeeper and the registry here are inefficient
    // Fix that.

    $fork     = realpath( dirname( __FILE__ ) . '/meta/fork.sh' );
    $registry = realpath( dirname( __FILE__ ) . '/meta/registry.php' );

    // Registry script, using the 'fork' wrapper -- we might import this to being native later
    exec( "bash '{$fork}' '/usr/bin/php' '{$registry}' '{$this->bundle}' '{$name}' '{$version}'" );

    // See if we need to do gatekeeper
    if ( file_exists( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) ) {
      if ( $type == 'utility' ) {

        if ( empty( $json ) ) {
          $json = json_decode( file_get_contents( __DIR__ . "/meta/defaults/{$name}.json" ), TRUE );

          if ( isset( $json[ 'gatekeeper' ] ) && ( $json[ 'gatekeeper' ] == TRUE ) ) {

            if ( file_exists( realpath( dirname( $this->plist ) ) . "/icon.png" ) )
              $icon = realpath( dirname( $this->plist ) ) . "/icon.png";
            else
              $icon = '';

            $path = "{$this->data}/data/assets/{$type}/{$name}/{$version}/" . $json[ 'versions' ][ $version ][ 'invoke' ];

            if ( isset( $json[ 'message' ] ) )
              $message = $json[ 'message' ];
            else
              $message = '';

            $this->gatekeeper( $name, $path, $message, $icon, $this->bundle );

          }

          // Grab the default and see if the gatekeeper flag is set
        } else {

          // Load the json and see if the gatekeeper flag is set
          if ( file_exists( $json ) ) {
            $json = json_decode( file_get_contents( $json ), TRUE );
            if ( isset( $json[ 'gatekeeper' ] ) && ( $json[ 'gatekeeper' ] == TRUE ) ) {
              // do gatekeeper
            } else {
              // don't do gatekeeper
            }
          } else {
            // no json file exists this is an error... really.
            return FALSE;
          }
        }
      }
    }


    // Do gatekeeper and path caching stuff as well
    if ( file_exists( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) )
      return "{$this->data}/data/assets/{$type}/{$name}/{$version}/"
        . trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );

    // Well, we need to install the asset

    if ( empty( $json ) ) {
      if ( $this->installAsset( "{$this->data}/bundler/meta/defaults/{$name}.json", $version ) )
        return "{$this->data}/" . trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
      else
        return FALSE;
    } else {
      if ( $this->installAsset( $json, $version ) )
        return "{$this->data}/" . trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
      else
        return FALSE;
    }

    // We shouldn't get here. If we have, then it's a malformed request.
    echo "There is a problem with the __implementation__ of the Alfred Bundler. Please let the workflow author know.";
    return FALSE;
  }

  /**
   * Loads a utility
   *
   * @since  Taurus 1
   * @access public
   *
   * @param  {string} $name                Name of utility
   * @param  {string} $version = 'default' Version of utility
   * @param  {string} $json    = ''        File path to json
   * @return {mixed}                       Path to utility on success, FALSE on failure
   */
  public function utility( $name, $version = 'default', $json = '' ) {
    if ( empty( $json ) ) {
        return $this->load( 'utility', $name, $version );
    } else {
      if ( file_exists( $json ) ) {
        return $this->load( 'utility', $name, $version, $json );
      }
    }
    return FALSE;
  }

  /**
   * Loads / requires a library
   *
   * @since  Taurus 1
   * @access public
   *
   * @param  {string} $name                Name of library
   * @param  {string} $version = 'default' Version of library
   * @param  {string} $json    = ''        File path to json
   * @return {bool}                        TRUE on success, FALSE on failure
   */
  public function library( $name, $version = 'default', $json = '' ) {
    $dir = "{$this->data}/data/assets/php/{$name}/{$version}";
    if ( file_exists( "{$dir}/invoke" ) ) {
      require_once( "{$dir}/" . trim( file_get_contents( "{$dir}/invoke" ) ) );
      return TRUE;
    } else {
      if ( $this->load( 'php', $name, $version, $json ) ) {
        require_once( "{$dir}/" . trim( file_get_contents( "{$dir}/invoke" ) ) );
        return TRUE;
      } else {
        return FALSE;
      }
    }
  }

  /**
   * Loads / requires composer packages
   *
   * @param  {array} $packages An array of packages to load in composer
   * @return {bool}            True on success, false on failure
   */
  public function composer( $packages ) {
    $composerDir = "{$this->data}/data/assets/php/composer";
    if ( ! file_exists( $composerDir ) )
      mkdir( $composerDir, 0755, TRUE );

    if ( ! file_exists( "{$composerDir}/composer.phar" ) )
      $this->download( "https://getcomposer.org/composer.phar", "{$composerDir}/composer.phar" );
      // Add check to make sure the that file is complete above...

    $install = FALSE;

    if ( file_exists( "{$composerDir}/bundles/{$this->bundle}/autoload.php" ) ) {
      if ( file_exists( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/composer.json" ) ) {
        $installDir = "{$this->cache}/{$this->bundle}/composer";
        if ( ! file_exists( $installDir ) )
          mkdir( "{$installDir}", 0775, TRUE );
        $json = json_encode( array( "require" => $packages ) );
        $json = str_replace('\/', '/', $json ); // Make sure that the json is valid for composer.
        file_put_contents( "{$installDir}/composer.json", $json );

        if ( hash_file( 'md5', "{$installDir}/composer.json" ) == hash_file( 'md5', "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/composer.json" ) ) {
          require_once( "{$composerDir}/bundles/{$this->bundle}/autoload.php" );
          return TRUE;
        } else {
          $install = TRUE;
          if ( file_exists( "{$composerDir}/bundles/{$this->bundle}" ) ) {
            $this->rrmdir( "{$composerDir}/bundles/{$this->bundle}" );
          }
        }
      }
    } else {
      $install = TRUE;
    }

    if ( $install == TRUE ) {
      if ( is_dir( "{$composerDir}/bundles/{$this->bundle}" ) ) {
        $this->rrmdir( "{$composerDir}/bundles/{$this->bundle}" );
      }
      if ( $this->installComposerPackage( $packages ) === TRUE ) {
        require_once( "{$composerDir}/bundles/{$this->bundle}/autoload.php" );
        return TRUE;
      } else {
        $this->log( 'composer', "ERROR: failed to install packages for {$this->bundle}" );
        return FALSE;
      }
    }
  }

  /**
   * Load an icon with optional fallback
   *
   * @TODO   Fix argument order
   *
   * @param  {[type]} $font   [description]
   * @param  {[type]} $name   [description]
   * @param  {[type]} $color  [description]
   * @param  {[type]} $alter =             FALSE [description]
   * @return {[type]}         [description]
   */
  public function icon( $font, $name, $color = '', $alter = FALSE ) {

    // If the requester is asking for a system icon, then see if it exists, if so
    // return it, otherwise, return FALSE.
    if ( $font == 'system' || $font == 'System' ) {
      if ( file_exists( "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/{$name}.icns" ) )
        return "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/{$name}.icns";
      else
        return FALSE;
    }

    if ( empty( $color ) ) {
      $color = '000000';
      $alter = TRUE;
    }

    // So, named colors can work, but we're going to test to see if the color is
    // written in a hex format; if so, we'll make sure that it's in a
    // non-abbreviated form.
    if ( $this->checkHex( $color ) )
      $color = $this->checkHex( $color );
    // Check to see if the 'alter' flag is true, if so, try to return the
    // appropriate light/dark icon.
    if ( $alter !== FALSE ) {

      if ( $this->background !== FALSE ) {
        if ( $this->checkColor( $color ) == $this->background ) {
          if ( $alter !== TRUE ) {
            // Use fallback color
            if ( $alter = $this->checkHex( $alter ) )
              $color = $alter;
          } else {
            if ( $this->background == 'dark' ) $color = $this->alterBrightness( $color );
            else $color = $this->alterBrightness( $color );
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
   * Creates the 'icon.png' file into an icns file
   *
   * @return {string} Path to generated icns file
   */
  public function icns() {

    if ( ! file_exists( $this->plist ) )
      return FALSE;
    if ( ( ! isset( $this->bundle ) ) || empty( $this->bundle ) )
      return FALSE;

    if ( file_exists( "{$this->cache}/icns/{$this->bundle}.icns" ) ) {
      return "{$this->cache}/icns/{$this->bundle}.icns";
    } else {
      $script = realpath( "'" . __DIR__ . '/includes/make_icns.sh' . "'" );
      $icon   = realpath( dirname( "{$this->plist}" ) . "/icon.png" );
      exec( "bash '{$script}' '{$icon}' '{$this->bundle}.icns'" );
      if ( file_exists( "{$this->cache}/icns/{$this->bundle}.icns" ) )
        return "{$this->cache}/icns/{$this->bundle}.icns";
      else
        return FALSE;
    }
  }

/*******************************************************************************
 * BEGIN INSTALL FUNCTIONS
 ******************************************************************************/

  /**
   * Installs an asset based on JSON information
   *
   * @param  {string} $json                File path to json
   * @param  {string} $version = 'default' Version of asset to install
   * @return {bool}                        TRUE on success, FALSE on failure
   */
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
   * Installs composer packages
   *
   * @param  {array} $packages List of composer ready packages with versions
   * @return {bool}            TRUE on success, FALSE on failure
   */
  private function installComposerPackage( $packages ) {
    if ( ! is_array( $packages) ) // The packages variable needs to be an array
      return FALSE;

    $installDir = "{$this->cache}/{$this->bundle}/composer";

    if ( ! file_exists( $installDir ) )
      mkdir( "{$installDir}", 0775, TRUE );

    $json = json_encode( array( "require" => $packages ) );
    $json = str_replace('\/', '/', $json ); // Make sure that the json is valid for composer.
    file_put_contents( "{$installDir}/composer.json", $json );

    $cmd = "php '{$this->data}/data/assets/php/composer/composer.phar' install -q -d '{$installDir}'";
    exec( $cmd );

    $packages = json_decode( file_get_contents( "{$installDir}/vendor/composer/installed.json" ), TRUE );

    // Files to be changed
    $files = array( 'autoload_psr4.php', 'autoload_namespaces.php', 'autoload_files.php', 'autoload_classmap.php' );
    $destination = "{$this->data}/data/assets/php/composer/vendor";
    $installed = array();

    foreach( $packages as $package ) :

      $name = explode( '/', $package[ 'name' ] ); // As: vendor/package
      $vendor = $name[0];                         // vendor
      $name = $name[1];                           // package name
      $version = $package[ 'version' ];           // version installed
      $installed[] = array( 'name' => $name, 'vendor' => $vendor, 'version' => $version );

      foreach( $files as $file ) :
        if ( file_exists( "{$installDir}/vendor/composer/{$file}" ) ) {
          $f = file( "{$installDir}/vendor/composer/{$file}" );
          foreach ( $f as $num => $line ) :
            $line = str_replace( '$vendorDir = dirname(dirname(__FILE__));',  "\$vendorDir = '{$this->data}/data/assets/php/composer/vendor';", $line );
            $line = str_replace( '$baseDir = dirname($vendorDir);', "\$baseDir = '{$this->data}/data/assets/php/composer';", $line );
            $line = str_replace( 'array($vendorDir . \'/' . $vendor . '/' . $name, 'array($vendorDir . \'/' . $vendor . '/' . $name . '-' . $version, $line );
            $f[ $num ] = $line;
          endforeach;
          file_put_contents( "{$installDir}/vendor/composer/{$file}", implode( '', $f ) );
        }
      endforeach;

      if ( ! file_exists( "{$destination}/{$vendor}/{$name}-{$version}") ) {
        if ( ! file_exists( "{$destination}/{$vendor}" ) )
          mkdir( "{$destination}/{$vendor}", 0775, TRUE ); // Make the vendor dir if necessary
        rename( "{$installDir}/vendor/{$vendor}/{$name}", "{$destination}/{$vendor}/{$name}-{$version}" );
      }
    endforeach;
    if ( ! file_exists( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}" ) )
      mkdir( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}", 0775, TRUE );

    if ( ! file_exists( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/packages.json" ) ) {
      $data = str_replace( '\/', '/', json_encode( $installed ) );
      file_put_contents( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/packages.json", $data );
    }

    rename( "{$installDir}/vendor/composer", "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/composer" );
    rename( "{$installDir}/vendor/autoload.php", "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/autoload.php" );
    file_put_contents( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/composer.json", $json );

    $this->rrmdir( $installDir );

    return FALSE;
  }

/*******************************************************************************
 * END INSTALL FUNCTIONS
 ******************************************************************************/

/*******************************************************************************
 * BEGIN ICON FUNCTIONS
 * ****************************************************************************/

  /**
   * Determines whether a color is 'light' or 'dark'
   *
   * @param  {string} $color     Hex representation of a color
   * @return {mixed}             Either 'light' or 'dark' or FALSE on fail
   */
  private function checkColor( $color ) {

    $color = $this->checkHex( $color );
    // Check if a valid hex color, if not, return FALSE
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

  /**
   * Checks to see if a color is a valid hex and normalizes the hex color
   *
   * @param  {string} $color A hex color
   * @return {mixed}         FALSE on non-hex or hex color (normalized) to six characters and lowercased
   */
  private function checkHex( $color ) {
    $color = str_replace('#', '', $color);
    $color = strtolower( $color );

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

  /**
   * Converts Hex color to RGB
   *
   * @param  {string} $color A hex color
   * @return {array}         An array of RGB values
   */
  function hexToRgb( $color ) {
		$r = hexdec( substr( $color, 0, 2 ) );
		$g = hexdec( substr( $color, 2, 2 ) );
		$b = hexdec( substr( $color, 4, 2 ) );
		return array( 'r' => $r, 'g' => $g, 'b' => $b );
	}

  /**
   * Lightens a color
   *
   * @param  {string} $color  Hex color
   * @return {string}         A hex color that has been 'lightened'
   */
	function alterBrightness( $color ) {
    $color = $this->checkHex( $color );
    if ( $color === FALSE ) return FALSE;

		$rgb = $this->hexToRgb( $color );
		$hsv = $this->rgb_to_hsv( $rgb['r'], $rgb['g'], $rgb['b'] );
		$hsv[ 'v' ] = 1 - $hsv[ 'v' ];
		$rgb = $this->hsv_to_rgb( $hsv[ 'h' ], $hsv[ 's' ], $hsv[ 'v' ] );

    foreach ( $rgb as $key => $val ) :
      if ( strlen( dechex( $val ) ) == 1 ) $rgb[ $key ] = '0' . dechex( $val );
      else $rgb[ $key ] = dechex( $val );
    endforeach;

    return $rgb[ 'r' ] . $rgb[ 'g' ] . $rgb[ 'b' ];
	}

	// I don't understand colors. RGB to HSV conversions adapted from
	// https://stackoverflow.com/questions/3512311/how-to-generate-lighter-darker-color-with-php
	// http://www.actionscript.org/forums/showthread.php3?t=50746 and

  /**
   * Converts RGB color to HSV color
   *
   * @param  {int} $r   Red value
   * @param  {int} $g   Green value
   * @param  {int} $b   Blue value
   * @return {array}    An array of H S V values
   */
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
    return array( 'h' => $h, 's' => $s, 'v' => $v );
	}

  /**
   * Convert HSV color to RGB
   *
   * @param  {float} $h H value
   * @param  {float} $s S value
   * @param  {float} $v V value
   * @return {array}    An array of RGB values
   */
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
			else 					           { $var_r = $v     ; $var_g = $var_1  ; $var_b = $var_2 ; }

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

/*******************************************************************************
 * BEGIN HELPER FUNCTIONS
 ******************************************************************************/

  /**
   * Returns bundle id of workflow using bundler
   *
   * @return {string} Bundle id
   */
  public function bundle() {
    return $this->bundle;
  }

  /**
   * Reads a plist value using PlistBuddy
   *
   * @param  {string} $plist File path to plist
   * @param  {string} $key   Key of plist to read
   * @return {mixed}         FALSE if plist doesn't exist, else value of key
   */
  private function readPlist( $plist, $key ) {
    if ( ! file_exists( $plist ) )
      return FALSE;

    return exec( "/usr/libexec/PlistBuddy -c 'Print :{$key}' '{$plist}'" );
  }

  /**
   * Wraps a cURL function to download files
   *
   * @param  {string} $url            A URL to the file
   * @param  {string} $file           The destination file
   * @param  {int}    $timeout =  '3' A timeout variable (in seconds)
   * @return {bool}                   True on success and error code / false on failure
   *
   * @access public
   * @since  Taurus 1
   */
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

      $file = file( $log, FILE_SKIP_EMPTY_LINES );

      // Check if the logfile is longer than 500 lines. If so, then trim the
      // last line.
      if ( count( $file ) >= 500 ) {
          unset( $file[499] );
      }

    }

    $message = date( "D M d H:i:s T Y -- " ) . $message;
    array_unshift( $file, $message );

    file_put_contents( $log, implode( PHP_EOL, $file ) );
  }

  /**
  * Recursively removes a folder along with all its files and directories
  *
  * @link http://ben.lobaugh.net/blog/910/php-recursively-remove-a-directory-and-all-files-and-folder-contained-within
  *
  * @access public
  * @since  Taurus 1
  *
  * @param {string} $path Path to directory to remove
  */
  public function rrmdir( $path ) {
    // Open the source directory to read in files
    $i = new DirectoryIterator( $path );
    foreach ( $i as $f ) :
      if ( $f->isFile() ) unlink( $f->getRealPath() );
      else if( ! $f->isDot() && $f->isDir() ) $this->rrmdir( $f->getRealPath() );
    endforeach;
    rmdir( $path );
  }

  /**
   * Determines the background color and set $this->background
   *
   * This function checks for the existence of a file and considers the contents
   * versus the modified time of the Alfredpreferences.plist where theme info
   * is stored. If necessary, it uses a utility to determine the 'light/dark'
   * status of the current Alfred theme.
   *
   * @access public
   * @since  Taurus 1
   * @return {bool}  TRUE on success, FALSE on failure
   */
  private function setBackground() {

    // For background icon functions:
    // To determine the value, we're using a modified version of Clint Strong's
    // SetupIconsForTheme (https://github.com/clintxs/alfred-icons).
    // The new binary just returns 'light' or 'dark' after processing the current
    // theme file.

    // The Alfred preferences plist where the theme information is stored
    $plist = "{$_SERVER[ 'HOME' ]}/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist";

    if ( file_exists( "{$this->data}/data/theme_background" ) ) {
      if ( filemtime( "{$this->data}/data/theme_background" > $plist ) ) {
        $this->background = file_get_contents( "{$this->data}/data/theme_background" );
        return TRUE;
      }
    }

    if ( file_exists( __DIR__ . "/includes/LightOrDark" ) ) {
      $this->background = exec( "'" . __DIR__ . "/includes/LightOrDark'" );
      file_put_contents( "{$this->data}/data/theme_background", $this->background );
      return TRUE;
    } else {
      $this->background = FALSE;
      return FALSE;
    }
  }

  public function gatekeeper( $name, $path, $message = '', $icon = '' ) {

    $assetCache = "{$this->data}/data/call-cache";

    // Make sure the directory exists
    if ( ! ( ( file_exists( $assetCache ) && is_dir( $assetCache ) ) ) )
      mkdir( $assetCache, 0775, TRUE );

    // Cache path for this call
    $key       = md5( "{$name}-{$version}-{$type}-{$json}" );
    $cachePath =      "$assetCache/$key";

    if ( file_exists( "$cachePath" ) ) {
      $path = file_get_contents( "$cachePath" );
      if ( file_exists( "$path" ) ) {
        // The cache has been found, and we have the asset there already.
        return $path;
      }
    }

    // Path to gatekeeper script
    $gatekeeper = realpath( dirname( __FILE__ ) ) . '/includes/gatekeeper.sh';

    // Execute the Gatekeeper script
    exec( "bash '{$gatekeeper}' '{$name}' '{$path}' '{$message}' '{$icon}' '{$this->bundle}'", $output, $status );

    return $status;
  }

/*******************************************************************************
 * END HELPER FUNCTIONS
 ******************************************************************************/

/*******************************************************************************
 * BEGIN BONUS FUNCTIONS
 ******************************************************************************/
  /**
   * Uses Terminal Notifer to display a notification
   *
   * @param  {string} $title             Title for notification
   * @param  {string} $message           Message of notification
   * @param  {array}  $options = array() An array of options that Terminal Notifer takes
   * @return {bool}                      TRUE on success, FALSE on failure
   */
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


    $tn = $this->utility( 'Terminal-Notifier' );
    exec( "'$tn' -title '{$title}' -message '{$message}'", $output, $status );

    // Return value based on exit status code
    if ( $status )
      return FALSE;
    else
      return TRUE;
  }

/*******************************************************************************
 * END BONUS FUNCTIONS
 ******************************************************************************/

}




//   if (   empty( $version ) ) $version = 'default'; // This shouldn't be needed....
//   if ( ! empty( $bundle  ) ) __registerAsset( $bundle , $name , $version );
//
//       /////////////////////////////////////////////////////////////////////////////////
//       // Let's start the caching checks
//

//
//       // The cache hasn't been found, so we'll call gatekeeper
//       $invoke = str_replace("\n", '', $invoke);
//       if ( strpos( $invoke, '.app' ) !== FALSE ) {
//         // Invoke Gatekeeper only when the utility is a .app.
//         // ech
//         if ( $this->plist ) {
//           $icon = dirname( $this->plist );
//           if ( file_exists( "{$icon}/icon.png" ) ) {
//             exec( "bash '$__data/includes/gatekeeper.sh' '$name' '$__data/assets/$type/$name/$version/$name.app' '{$icon}/icon.png' '{$this->bundle}'", $output, $return );
//           }
//         }
//         exec( "bash '$__data/includes/gatekeeper.sh' '$name' '$__data/assets/$type/$name/$version/$name.app'", $output, $return );
//         if ( $return !== 0 ) {
//           return $output[0];
//         } else if ( $return == 0 ) {
//           file_put_contents( "$bd_asset_cache/$key", "$__data/assets/$type/$name/$version/$invoke" );
//           return array( "$__data/assets/$type/$name/$version/$invoke" );
//         }
//       }
//     }
