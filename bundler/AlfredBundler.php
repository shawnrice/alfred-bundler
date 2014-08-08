<?php

/**
 * Alfred Bundler PHP API file
 *
 * Main PHP interface for the Alfred Dependency Bundler.
 *
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
   *
   * @access private
   * @var string
   */
  private   $data;

  /**
   * A filepath to the bundler cache directory
   *
   * @access private
   * @var string
   */
  private   $cache;

  /**
   * The MAJOR version of the bundler (which API to use)
   *
   * @access private
   * @var string
   */
  private   $major_version;

  /**
   * The MINOR version of the bundler
   *
   * @access private
   * @var string
   */
  private   $minor_version;

  /**
   * Filepath to an Alfred info.plist file
   *
   * @access private
   * @var string
   */
  private   $plist;

  /**
   * The Bundle ID of the workflow using the bundler
   *
   * @access private
   * @var string
   */
  private   $bundle;

  /**
   * The name of the workflow using the bundler
   *
   * @access private
   * @var string
   */
  private   $name;

  /**
   * The background 'color' of the user's current theme in Alfred (light or dark)
   *
   * @access private
   * @var string
   */
  private   $background;

  // Just a resource to check on a fileinfo thingie.
  public $finfo;

  //
  public $alfredVersion;

  /**
   * The class constructor
   *
   * Sets necessary variables.
   *
   * @access public
   * @param {string} $plist Path to workflow 'info.plist'
   * @return {bool}          Return 'true' regardless
   */
  public function __construct( $plist = '' ) {

    if ( isset( $_ENV['ALFRED_BUNDLER_DEVEL'] ) ) {
      $this->major_version = $_ENV['ALFRED_BUNDLER_DEVEL'];
    } else {

      $this->major_version = file_get_contents(
        __DIR__ . '/meta/version_major' );
    }

    $this->minor_version = file_get_contents(
      __DIR__ . '/meta/version_minor' );

    $this->data   = trim( "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->cache  = trim( "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}" );

    if ( file_exists( $plist ) ) {
      $this->plist  = $plist;
    } else {
      $this->plist = '';
    }

    if ( ! empty( $plist ) ) {
      $this->bundle = exec( "/usr/libexec/PlistBuddy -c 'Print :bundleid' '{$this->plist}'" );
      $this->name   = exec( "/usr/libexec/PlistBuddy -c 'Print :name'     '{$this->plist}'" );
    } else {
      $this->bundle = '';
      $this->name   = '';
    }

    if ( isset( $_ENV[ 'alfred_version' ] ) ) {
      // As of Alfred v2.4 Build 277, environmental variables are available
      // that will make this process a lot easier and faster.
      $this->alfredVersion = array( 'version' => $_ENV[ 'alfred_version' ],
        'build'  => $_ENV[ 'alfred_version_build' ] );
      $this->home = $_ENV[ 'HOME' ];
      $this->alfredPreferences = $_ENV[ 'alfred_preferences' ];
      $this->preferencesHash = $_ENV[ 'alfred_preferences_local_hash' ];
      $this->themeBackground = $_ENV[ 'alfred_theme_background' ];
      $this->theme = $_ENV[ 'alfred_theme' ];

      $plist = "{$this->alfredPreferences}/preferences/local/{$this->preferencesHash}/appearance/prefs.plist";

      if ( ! file_exists( "{$this->data}/data" ) ) {
        mkdir( "{$this->data}/data", 0775, TRUE );
      }

      if ( file_exists( "{$this->data}/data/theme_background" ) ) {
        if ( filemtime( "{$this->data}/data/theme_background" > $plist ) ) {
          $this->background = file_get_contents( "{$this->data}/data/theme_background" );
        } else {
          $update = TRUE;
        }
      } else {
        $update = TRUE;
      }
      if ( isset( $update ) && ( $update == TRUE ) ) {
        // See if RGB value is greater than 127, if so, background is light,
        // else, dark
        preg_match_all( "/rgba\(([0-9]{3}),([0-9]{3}),([0-9]{3}),([0-9.]{4,})\)/", "rgba(236,237,216,0.00)", $matches );
        $r = $matches[1];
        $g = $matches[2];
        $b = $matches[3];
        if ( ( ( $r * 299 ) + ( $g * 587 ) + ( $b * 114 ) ) / 1000 > 127 )
          $this->background = 'light';
        else
          $this->background = 'dark';
        file_put_contents( "{$this->data}/data/theme_background", $this->background );
      }
    } else {
      // Pre Alfred v2.4:277.

      // Do stuff here
      $this->setBackground();
    }


    $this->finfo = finfo_open( FILEINFO_MIME_TYPE );
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
   * @param {string} $type    Type of asset
   * @param {string} $name    Name of asset
   * @param {string} $version Version of asset to load
   * @param {string} $json    = '' Path to json file
   * @return {mixed}             Returns path to utility on success, FALSE on failure
   */
  public function load( $type, $name, $version, $json = '' ) {

    if ( empty( $json ) ) {
      if ( file_exists( __DIR__ . "/meta/defaults/{$name}.json" ) ) { $line = __LINE__;
        $json_path = __DIR__ . "/meta/defaults/{$name}.json";
      } else {
        // JSON File cannot be found
        $error = TRUE;
      }
    } else if ( file_exists( $json ) ) { $line = __LINE__;
        $json_path = $json;
      } else {
      // JSON File cannot be found
      $error = TRUE;
    }

    // Check to see if the JSON is valid
    if ( ! json_decode( file_get_contents( $json_path ) ) ) { $line = __LINE__;
      // JSON file not valid
      $error = TRUE;
    }

    // If we've encountered an error, then write the error and exit
    if ( isset( $error ) && ( $error === TRUE ) ) {
      // There is an error with the JSON file.
      // Output the error to STDERR.

      $this->reportLog( "There is a problem with the __implementation__ of " .
        "the Alfred Bundler when trying to load '{$name}'. Please " .
        "let the workflow author know.", 'CRITICAL', __FILE__, $line );
      return FALSE;
    }

    $json = json_decode( file_get_contents( $json_path ), TRUE );

    // See if the file is installed
    if ( ! file_exists(
        "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) ) {

      if ( ! $this->installAsset(
          "{$this->data}/bundler/meta/defaults/{$name}.json", $version ) ) {
        return FALSE;
      }
    }

    // Register the asset. We don't need to worry about the return.
    $this->register( $name, $version ); $line = __LINE__;
    $this->reportLog( "Registering assset '{$name}'",
      'DEBUG', __FILE__, $line );

    // The file should exist now, but we'll try anyway
    if ( ! file_exists(
        "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) ) {

      return FALSE;
    }

    if ( $type != 'utility' ) {
      // We don't have to worry about gatekeeper
      $this->reportLog( "Loaded '{$name}' version {$version} of type " .
        "'{$type}'", 'INFO', __FILE__, __LINE__ );

      return "{$this->data}/data/assets/{$type}/{$name}/{$version}/"
        . trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
    } else {
      // It's a utility, so let's see if we need gatekeeper
      if ( ! ( isset( $json[ 'gatekeeper' ] )
          && ( $json[ 'gatekeeper' ] == TRUE ) ) ) {

        // We don't have to worry about gatekeeper
        $this->reportLog( "Loaded '{$name}' version {$version} of type " .
          "'{$type}'", 'INFO', __FILE__, __LINE__ );

        return "{$this->data}/data/assets/{$type}/{$name}/{$version}/"
          . trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
      }
    }

    // At this point, we need to check in with gatekeeper

    // Find the icon to pass to the Gatekeeper script
    if ( file_exists( realpath( dirname( $this->plist ) ) . "/icon.png" ) )
      $icon = realpath( dirname( $this->plist ) ) . "/icon.png";
    else
      $icon = '';

    // Create the path variable
    $path = "{$this->data}/data/assets/{$type}/{$name}/{$version}/"
      . $json[ 'versions' ][ $version ][ 'invoke' ];

    // Set the message for the Gatekeeper script (if there is one)
    if ( isset( $json[ 'message' ] ) )
      $message = $json[ 'message' ];
    else
      $message = '';

    // Double check with the gatekeeper function (doesn't necessarily
    // run the gatekeeper script).
    if ( $this->gatekeeper( $name, $path, $message, $icon, $this->bundle ) ) {
      // The utility has been whitelisted, so return the path
      $this->reportLog( "Loaded '{$name}' v{$version} of type '{$type}'.",
        'INFO', __FILE__, __LINE__ );
      return $path;
    } else {
      // The utility has not been whitelisted, so return an error.
      // The gatekeeper function already wrote the error to STDERR.
      return FALSE;
    }

    // We shouldn't get here. If we have, then it's a malformed request.
    // Output the error to STDERR.
    $this->reportLog( "There is a problem with the __implementation__ of " .
      "the Alfred Bundler when trying to load '{$name}'. Please let the " .
      "workflow author know.", 'ERROR', __FILE__, __LINE__ );

    return FALSE;
  }

  /**
   * Loads a utility
   *
   * @since  Taurus 1
   * @access public
   *
   * @param {string} $name    Name of utility
   * @param {string} $version = 'default' Version of utility
   * @param {string} $json    = ''        File path to json
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
   * @param {string} $name    Name of library
   * @param {string} $version = 'default' Version of library
   * @param {string} $json    = ''        File path to json
   * @return {bool}                        TRUE on success, FALSE on failure
   */
  public function library( $name, $version = 'default', $json = '' ) {
    $dir = "{$this->data}/data/assets/php/{$name}/{$version}";
    if ( file_exists( "{$dir}/invoke" ) ) {
      require_once "{$dir}/" . trim( file_get_contents( "{$dir}/invoke" ) );
      return TRUE;
    } else {
      if ( $this->load( 'php', $name, $version, $json ) ) {
        require_once "{$dir}/" . trim( file_get_contents( "{$dir}/invoke" ) );
        return TRUE;
      } else {
        return FALSE;
      }
    }
  }

  /**
   * [binding description]
   *
   * @param [type]  $binding [description]
   *
   * @return  [type]            [description]
   */
  public function binding( $binding ) {
    $bindingsDir = "{$this->data}/bundler/includes/bindings/php";
    if ( file_exists( "{$bindingsDir}/{$binding}.php" ) ) {
      require_once "{$bindingsDir}/{$binding}.php"; $line = __LINE__;
      $this->reportLog( "Loaded '{$binding}' bindings", 'INFO', __FILE__, $line );
      return 0;
    } else {
      $this->reportLog( "'{$binding}' not found.", 'ERROR', __FILE__, $line );
      return 10;
    }
  }

  /**
   * Loads / requires composer packages
   *
   * @param {array} $packages An array of packages to load in composer
   * @return {bool}            True on success, false on failure
   */
  public function composer( $packages ) {
    $composerDir = "{$this->data}/data/assets/php/composer";
    if ( ! file_exists( $composerDir ) )
      mkdir( $composerDir, 0755, TRUE );

    if ( ! file_exists( "{$composerDir}/composer.phar" ) ) {
      $this->download( "https://getcomposer.org/composer.phar", "{$composerDir}/composer.phar" ); $line = __LINE__;
      $this->reportLog( "Installing Composer to `{$composerDir}`", 'INFO', __FILE__, $line );
      // Add check to make sure the that file is complete above...
    }

    $install = FALSE;

    if ( file_exists( "{$composerDir}/bundles/{$this->bundle}/autoload.php" ) ) {
      if ( file_exists( "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/composer.json" ) ) {
        $installDir = "{$this->cache}/{$this->bundle}/composer";
        if ( ! file_exists( $installDir ) )
          mkdir( "{$installDir}", 0775, TRUE );
        $json = json_encode( array( "require" => $packages ) );
        $json = str_replace( '\/', '/', $json ); // Make sure that the json is valid for composer.
        file_put_contents( "{$installDir}/composer.json", $json );

        if ( hash_file( 'md5', "{$installDir}/composer.json" )
          == hash_file( 'md5', "{$this->data}/data/assets/php/composer/bundles/{$this->bundle}/composer.json" ) ) {
          $this->reportLog( "Loaded Composer packages for {$this->bundle}.",
            'INFO', basename( __FILE__ ), __LINE__ );
          require_once(
            "{$composerDir}/bundles/{$this->bundle}/autoload.php" );

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
        $this->reportLog( "Loaded Composer packages for {$this->bundle}.",
          'INFO', basename( __FILE__ ), __LINE__ );
        require_once "{$composerDir}/bundles/{$this->bundle}/autoload.php";
        return TRUE;
      } else {
        $this->reportLog( "ERROR: failed to install packages for {$this->bundle}", 'ERROR', basename( __FILE__ ), __LINE__ );
        $this->logInternal( 'composer', "ERROR: failed to install packages for {$this->bundle}" );
        return FALSE;
      }
    }
  }

  /**
   * Load an icon with optional fallback
   *
   * @TODO   Fix argument order
   *
   * @param {[type]} $font  [description]
   * @param {[type]} $name  [description]
   * @param {[type]} $color [description]
   * @param {[type]} $alter =             FALSE [description]
   * @return {[type]}         [description]
   */
  public function icon( $font, $name, $color = '', $alter = FALSE ) {

    // If the requester is asking for a system icon, then see if it exists, if so
    // return it, otherwise, return FALSE.
    if ( $font == 'system' || $font == 'System' ) {
      if ( file_exists( "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/{$name}.icns" ) ) {
        return "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/{$name}.icns";
      } else {
        $this->reportLog( "System icon '{$name}' does not exist. Instead " .
          "sending an embarrassing replacement.", 'WARNING',
          basename( __FILE__ ), __LINE__ );
        // return the fallback icon
        return "{$this->data}/bundler/meta/icons/default.icns";
      }
    }

    if ( empty( $color ) ) {
      $color = '000000';
      $alter = TRUE;
    }

    // So, named colors cannot work, but we're going to test to see if the
    // color is written in a hex format; if so, we'll make sure that it's in a
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
            if ( ! file_exists( "{$this->data}/data/color-cache" ) )
              mkdir( "{$this->data}/data/color-cache", 0775, TRUE );
            if ( file_exists( "{$this->data}/data/color-cache/{$color}" ) ) {
              $color = file_get_contents( "{$this->data}/data/color-cache/{$color}" );
            } else {
              file_put_contents( "{$this->data}/data/color-cache/{$color}", $this->alterBrightness( $color ) );
              $color = file_get_contents( "{$this->data}/data/color-cache/{$color}" );
            }
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

    // Cycle through the servers until we find one that is up.
    foreach ( $iconServers as $server ) :
      $success = $this->download(
        "{$server}/icon/{$font}/{$color}/{$name}", $iconPath );
    if ( $success === TRUE ) {
      break; // We found one, so break
    }
    endforeach;

    // If success is true, then we downloaded the icon
    if ( $success !== TRUE ) {
      $this->report( "Could not download icon {$name} from {$font}.", 'ERROR', __FILE__, __LINE__ );
      unlink( $iconPath );
      return "{$this->data}/bundler/meta/icons/default.png";
    }

    if ( finfo_file( $this->finfo, $iconPath ) == "image/png" ) {
      // Success. Send the new icon path
      return $iconPath;
    } else {
      $this->reportLog( "Download error with icon '{$name}'. Check argument " .
        "order.", 'ERROR', __FILE__, __LINE__ );
      // unlink( $iconPath );
      return "{$this->data}/bundler/meta/icons/default.png";
    }
    return "{$this->data}/bundler/meta/icons/default.png";
  }

  /**
   * Creates an icns file out of the workflow's 'icon.png' file
   *
   * @return {string} Path to generated icns file
   */
  public function icns() {

    if ( ! file_exists( $this->plist ) )
      return FALSE;
    if ( ( ! isset( $this->bundle ) ) || empty( $this->bundle ) )
      return FALSE;
    if ( ! file_exists(
        realpath( dirname( "{$this->plist}" ) . "/icon.png" ) ) ) {
      return FALSE;
    }

    if ( file_exists( "{$this->cache}/icns/{$this->bundle}.icns" ) ) {
      return "{$this->cache}/icns/{$this->bundle}.icns";
    } else {
      $script = realpath( "'" . __DIR__ . '/includes/png_to_icns.sh' . "'" );
      $icon   = realpath( dirname( "{$this->plist}" ) . "/icon.png" );
      exec( "bash '{$script}' '{$icon}' '{$this->bundle}.icns'" );
      if ( file_exists( "{$this->cache}/icns/{$this->bundle}.icns" ) )
        return "{$this->cache}/icns/{$this->bundle}.icns";
      else
        return FALSE;
    }
  }

  /******************************************************************************
 * BEGIN INSTALL FUNCTIONS
 *****************************************************************************/

  /**
   * Installs an asset based on JSON information
   *
   * @param {string} $json    File path to json
   * @param {string} $version = 'default' Version of asset to install
   * @return {bool}                        TRUE on success, FALSE on failure
   */
  public function installAsset( $json, $version = 'default' ) {
    if ( ! file_exists( $json ) ) {
      $this->reportLog( "Cannot install asset because the JSON file ('{$json}') is not present.", 'ERROR', basename( __FILE__ ), __LINE__ );
      return FALSE;
    }

    // @TODO: Add error checking to make sure that the file is good JSON
    $json = json_decode( file_get_contents( $json ), TRUE );

    if ( $json == null ) {
      $this->reportLog( "Cannot install asset because the JSON file ('{$json}') is not valid.", 'ERROR', basename( __FILE__ ), __LINE__ );
      return FALSE;
    }

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
        $this->reportLog( "Cannot install {$name} because no version found and cannot fallback to 'default'.", 'ERROR', basename( __FILE__ ), __LINE__ );
        $this->logInternal( 'asset', "Cannot install {$type}: {$name}. Version '{$version}' not found." );
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
      if ( ! $this->download( $url[ 'url' ], "{$tmpDir}/{$file}" ) ) {
        $this->reportLog( "Cannot download {$name} at {$url['url']}.", 'ERROR', basename( __FILE__ ), __LINE__ );
        return FALSE; // The download failed, for some reason.
      }

      // @TODO : Convert these to native PHP functions
      if ( $url[ 'method' ] == 'zip' ) {
        // Unzip the file into the cache directory, silently.
        exec( "unzip -qo '{$tmpDir}/{$file}' -d '{$tmpDir}'" );
      } else if ( $url[ 'method' ] == 'tgz' || $url[ 'method' ] == 'tar.gz' ) {
          // Untar the file into the cache directory, silently.
          exec( "tar xzf '{$tmpDir}/{$file}' -C '{$tmpDir}'" );
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
    $this->logInternal( 'asset', "INFO: Installed '{$type}': '{$name}' -- version '{$version}'." );
    $this->reportLog( "Installed '{$type}': '{$name}' -- version '{$version}'.", 'INFO', basename( __FILE__ ), __LINE__ );
    $this->rrmdir( "{$tmpDir}" );
    return TRUE;
  }

  /**
   * Installs composer packages
   *
   * @param {array} $packages List of composer ready packages with versions
   * @return {bool}            TRUE on success, FALSE on failure
   */
  private function installComposerPackage( $packages ) {
    if ( ! is_array( $packages ) ) {
      // The packages variable needs to be an array
      $this->reportLog( "An array must be passed to install Composer assets.", 'ERROR', basename( __FILE__ ), __LINE__ );
      return FALSE;
    }

    $installDir = "{$this->cache}/{$this->bundle}/composer";

    if ( ! file_exists( $installDir ) )
      mkdir( "{$installDir}", 0775, TRUE );

    $json = json_encode( array( "require" => $packages ) );
    $json = str_replace( '\/', '/', $json ); // Make sure that the json is valid for composer.
    file_put_contents( "{$installDir}/composer.json", $json );

    $cmd = "php '{$this->data}/data/assets/php/composer/composer.phar' install -q -d '{$installDir}'";
    exec( $cmd );
    // Add in error checking to make sure that it worked.

    $packages = json_decode( file_get_contents( "{$installDir}/vendor/composer/installed.json" ), TRUE );

    // Files to be changed
    $files = array( 'autoload_psr4.php', 'autoload_namespaces.php', 'autoload_files.php', 'autoload_classmap.php' );
    $destination = "{$this->data}/data/assets/php/composer/vendor";
    $installed = array();

    foreach ( $packages as $package ) :

    $name        = explode( '/', $package[ 'name' ] ); // As: vendor/package
    $vendor      = $name[0];                         // vendor
    $name        = $name[1];                           // package name
    $version     = $package[ 'version' ];           // version installed
    $installed[] = array( 'name' => $name,
      'vendor' => $vendor,
      'version' => $version );

    foreach ( $files as $file ) :
      if ( file_exists( "{$installDir}/vendor/composer/{$file}" ) ) {
        $f = file( "{$installDir}/vendor/composer/{$file}" );
        foreach ( $f as $num => $line ) :
          $line = str_replace( '$vendorDir = dirname(dirname(__FILE__));',  "\$vendorDir = '{$this->data}/data/assets/php/composer/vendor';", $line );
          $line = str_replace( '$baseDir = dirname($vendorDir);', "\$baseDir = '{$this->data}/data/assets/php/composer';", $line );
          $line = str_replace( 'array($vendorDir . \'/' . $vendor . '/' . $name, 'array($vendorDir . \'/' . $vendor . '/' . $name . '-' . $version, $line );
          $f[ $num ] = $line;
        endforeach;
        file_put_contents( "{$installDir}/vendor/composer/{$file}",
          implode( '', $f ) );
      }
    endforeach;
    $this->reportLog( "Rewrote Composer autoload file for workflow.", 'INFO', basename( __FILE__ ), __LINE__ );

    if ( ! file_exists( "{$destination}/{$vendor}/{$name}-{$version}" ) ) {
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

    $this->reportLog( "Successfully installed composer packages. Cleaning up....", 'INFO', basename( __FILE__ ), __LINE__ );

    $this->rrmdir( $installDir );

    return TRUE;
  }

  /******************************************************************************
 * END INSTALL FUNCTIONS
 *****************************************************************************/

  /******************************************************************************
 * BEGIN ICON FUNCTIONS
 *****************************************************************************/

  /**
   * Determines whether a color is 'light' or 'dark'
   *
   * @param {string} $color Hex representation of a color
   * @return {mixed}             Either 'light' or 'dark' or FALSE on fail
   */
  private function checkColor( $color ) {
    // Check if a valid hex color, if not, return FALSE
    if ( ! ( $color = $this->checkHex( $color ) ) )
      return FALSE;
    $color = $this->hexToRgb( $color );
    if ( $this->getLuminance( $color ) > 0.5 )
      return 'light';
    else
      return 'dark';
  }

  /**
   * [getLuminance description]
   *
   * @param [type]  $rgb [description]
   *
   * @return  [type]        [description]
   */
  function getLuminance( $rgb ) {
    return ( 0.3 * $rgb['r' ] + 0.59 * $rgb['g' ] + 0.11 * $rgb['b' ] ) / 255;
  }

  /**
   * Checks to see if a color is a valid hex and normalizes the hex color
   *
   * @param {string} $color A hex color
   * @return {mixed}         FALSE on non-hex or hex color (normalized) to six characters and lowercased
   */
  public function checkHex( $hex ) {
    return $this->validateHex( $this->checkHex( $hex ) );
  }

  /**
   * [normalizeHex description]
   *
   * @param [type]  $hex [description]
   *
   * @return  [type]        [description]
   */
  public function normalizeHex( $hex ) {
    $hex = strtolower( str_replace( '#', '', $hex ) );
    if ( strlen( $hex ) == 3 )
      $hex = preg_replace( "/(.)(.)(.)/", "\\1\\1\\2\\2\\3\\3", $hex );
    return $hex;
  }

  /**
   * [validateHex description]
   *
   * @param [type]  $hex [description]
   *
   * @return  [type]        [description]
   */
  public function validateHex( $hex ) {
    if ( strlen( $hex ) != 3 && strlen( $hex ) != 6 )
      return FALSE; // Not a valid hex value
    if ( ! preg_match( "/([0-9a-f]{3}|[0-9a-f]{6})/", $hex ) )
      return FALSE; // Not a valid hex value
    return TRUE;
  }

  /**
   * Converts Hex color to RGB
   *
   * @param {string} $color A hex color
   * @return {array}         An array of RGB values
   */
  public function hexToRgb( $hex ) {
    $r = hexdec( substr( $hex, 0, 2 ) );
    $g = hexdec( substr( $hex, 2, 2 ) );
    $b = hexdec( substr( $hex, 4, 2 ) );
    return [ 'r' => $r, 'g' => $g, 'b' => $b ];
  }

  /**
   * [rgbToHex description]
   *
   * @param [type]  $rgb [description]
   *
   * @return  [type]        [description]
   */
  public function rgbToHex( $rgb ) {
    $hex .= str_pad( dechex( $rgb['r'] ), 2, '0', STR_PAD_LEFT );
    $hex .= str_pad( dechex( $rgb['g'] ), 2, '0', STR_PAD_LEFT );
    $hex .= str_pad( dechex( $rgb['b'] ), 2, '0', STR_PAD_LEFT );
    return $hex;
  }

  /**
   * Lightens a color
   *
   * @param {string} $color Hex color
   * @return {string}         A hex color that has been 'lightened'
   */
  public function alterBrightness( $color ) {
    $color = $this->checkHex( $color );
    if ( $color === FALSE )
      return FALSE;

    $rgb = $this->hexToRgb( $color );
    $hsv = $this->rgb_to_hsv( $rgb );
    $hsv[ 'v' ] = 1 - $hsv[ 'v' ];
    $rgb = $this->hsv_to_rgb( $hsv );
    return $this->rgbToHex( $rgb );
  }

  /**
   * Converts RGB color to HSV color
   *
   * @param {array} $rgb associative array of rgb values
   * @return {array}       an associate array of hsv values
   */
  function rgbToHsv( $rgb ) {
    $r = $rgb[ 'r' ];
    $g = $rgb[ 'g' ];
    $b = $rgb[ 'b' ];

    $min = min( $r, $g, $b );
    $max = max( $r, $g, $b );
    $chroma = $max - $min;

    //if $chroma is 0, then s is 0 by definition, and h is undefined but 0 by convention.
    if ( $chroma == 0 )
      return [ 'h'   =>   0, 's'   =>   0, 'v'   =>   $max / 255 ];

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
   * @param {array} $hsv associative array of hsv values ( 0 <= h < 360, 0 <= s <= 1, 0 <= v <= 1)
   * @return {array}    An array of RGB values
   */
  function hsvToRgb( $hsv ) {
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
   * @param {string} $plist File path to plist
   * @param {string} $key   Key of plist to read
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
   * @param {string} $url     A URL to the file
   * @param {string} $file    The destination file
   * @param {int}   $timeout =  '3' A timeout variable (in seconds)
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
    $fp = fopen( $file , "w" );

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
      return curl_error( $ch ); // Under some circumstances, if the file cannot
      // be downloaded, then this will return an error
      // stating that $ch is not a valid cURL resource
    }

    $line = __LINE__;
    $this->reportLog( "Downloading `{$url}` ...", 'INFO', basename( __FILE__ ), $line );

    curl_close( $ch );
    fclose( $fp );
    return TRUE;
  }

  private function reportLog( $message, $level, $file, $line ) {

    // These are the appropriate log levels
    $logLevels = array( 0 => 'DEBUG',
      1 => 'INFO',
      2 => 'WARNING',
      3 => 'ERROR',
      4 => 'CRITICAL',
    );

    // Set date/time to avoid warnings/errors.
    if ( ! ini_get( 'date.timezone' ) ) {
      $tz = exec( 'tz=`ls -l /etc/localtime` && echo ${tz#*/zoneinfo/}' );
      ini_set( 'date.timezone', $tz );
    }

    $date = date( 'Y-m-d H:i:s', time() );

    // We'll convert the log level to a string; if the level is not available,
    // then we'll default to INFO
    if ( is_int( $level ) ) {
      if ( isset( $logLevels[ $level ] ) ) {
        $level = $logLevels[ $level ];
      } else {
        file_put_contents( 'php://stderr', "[{$date}] [{$file},{$line}] [WARNING] Log level '$level' " .
          "is not valid. Falling back to 'INFO' (0)" );
        $level = 'INFO';
      }
    } else if ( is_string( $level ) ) {
        if ( ! in_array( $level, $logLevels ) ) {
          file_put_contents( 'php://stderr', "[{$date}] [{$file}:{$line}] [WARNING] Log level '$level' " .
            "is not valid. Falling back to 'INFO' (0)" );
          $level = 'INFO';
        }
      }

    file_put_contents( 'php://stderr', "[{$date}] [" . basename( $file ) . ":{$line}] [{$level}] {$message}" . PHP_EOL );

  }

  /**
   * Prepends a datestamped message to a log file
   *
   * @param {string} $log     name of log file
   * @param {string} $message message to write to log
   * @return {[type]}          [description]
   */
  private function logInternal( $log, $message, $level = 'INFO' ) {

    $log = "{$this->data}/data/logs/{$log}.log";

    // These are the appropriate log levels
    $logLevels = array( 0 => 'DEBUG',
      1 => 'INFO',
      2 => 'WARNING',
      3 => 'ERROR',
      4 => 'CRITICAL',
    );

    // We'll convert the log level to a string; if the level is not available,
    // then we'll default to INFO
    if ( is_int( $level ) ) {
      if ( isset( $logLevels[ $level ] ) ) {
        $level = $logLevels[ $level ];
      } else {
        file_put_contents( 'php://stderr', "BundlerWarning: log level '$level' " .
          "is not valid. Falling back to 'INFO' (0)" );
        $level = 'INFO';
      }
    } else if ( is_string( $level ) ) {
        if ( ! in_array( $level, $logLevels ) ) {
          file_put_contents( 'php://stderr', "BundlerWarning: log level '$level' " .
            "is not valid. Falling back to 'INFO' (0)" );
          $level = 'INFO';
        }
      }

    // Set date/time to avoid warnings/errors.
    if ( ! ini_get( 'date.timezone' ) ) {
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

      $file = file( $log, FILE_SKIP_EMPTY_LINES | FILE_IGNORE_NEW_LINES );

      // Check if the logfile is longer than 500 lines. If so, then trim the
      // last line.
      if ( count( $file ) >= 500 ) {
        unset( $file[499] );
      }

    }

    $message = date( "[D M d H:i:s T Y] " ) . "[{$level}]". $message;
    array_unshift( $file, $message );

    file_put_contents( $log, implode( PHP_EOL, $file ) );
  }

  /**
   * Prepends a datestamped message to a log file
   *
   * @param {string} $message message to write to log
   * @param {string} $log     name of log file
   * @param {mixed} $level   log level
   */
  public function log( $message, $level = 0, $log = 'info' ) {

    // This function is available only to valid workflows with Bundle IDs
    if ( ! isset( $this->bundle ) || empty( $this->bundle ) ) {
      file_put_contents( 'php://stderr',
        "BundlerError: a valid Bundle ID is needed to use the bundler's log " .
        "function" . PHP_EOL );
      return 0;
    }

    // These are the appropriate log levels
    $logLevels = array( 0 => 'INFO',
      1 => 'WARNING',
      2 => 'STRICT WARNING',
      3 => 'RECOVERABLE ERROR',
      4 => 'ERROR',
    );

    // We'll convert the log level to a string; if the level is not available,
    // then we'll default to INFO
    if ( is_int( $level ) ) {
      if ( isset( $logLevels[ $level ] ) ) {
        $level = $logLevels[ $level ];
      } else {
        file_put_contents( 'php://stderr', "BundlerWarning: log level '$level' " .
          "is not valid. Falling back to 'INFO' (0)" );
        $level = 'INFO';
      }
    } else if ( is_string( $level ) ) {
        if ( ! in_array( $level, $logLevels ) ) {
          file_put_contents( 'php://stderr', "BundlerWarning: log level '$level' " .
            "is not valid. Falling back to 'INFO' (0)" );
          $level = 'INFO';
        }
      }

    $logBase = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/" .
      "Workflow Data/{$this->bundle}/logs";

    // Make the directory if it doesn't exist
    if ( ! file_exists( $logBase ) )
      mkdir( $logBase, 0775, TRUE );

    // Define the log file
    $log = "{$logBase}/{$log}.log";

    // Set date/time to avoid warnings/errors.
    if ( ! ini_get( 'date.timezone' ) ) {
      $tz = exec( 'tz=`ls -l /etc/localtime` && echo ${tz#*/zoneinfo/}' );
      ini_set( 'date.timezone', $tz );
    }

    if ( ! file_exists( $log ) ) {
      $file = array();
    } else {
      // This is needed because, Macs don't read EOLs well.
      if ( ! ini_get( 'auto_detect_line_endings' ) )
        ini_set( 'auto_detect_line_endings', TRUE );

      $file = file( $log, FILE_SKIP_EMPTY_LINES | FILE_IGNORE_NEW_LINES );

      // Check if the logfile is longer than 5000 lines. If so, then trim the
      // last line.
      if ( count( $file ) >= 5000 ) {
        unset( $file[4999] );
      }
    }

    // Prepend the message with the date and log level
    $message = date( "[D M d H:i:s T Y]" ) . " [{$level}]: ". $message;

    // Prepend the message to the log file
    array_unshift( $file, $message );

    // Write the log
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
      if ( $f->isFile() ) {
        unlink( $f->getRealPath() ); $line = __LINE__;
        $this->reportLog( "Deleting directory `{$path}`", 'INFO', __FILE__, $line );
      } else if ( ! $f->isDot() && $f->isDir() ) $this->rrmdir( $f->getRealPath() );
      endforeach;
    rmdir( $path ); $line = __LINE__;
    $this->reportLog( "Deleting directory `{$path}`", 'INFO', __FILE__, $line );
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

    if ( ! file_exists( "{$this->data}/data" ) ) {
      mkdir( "{$this->data}/data", 0775, TRUE );
    }

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

  /**
   * Queries Gatekeeper to whitelist apps
   *
   * Invokes the Gatekeeper script if the path has not already been called. The
   * call, if successful, is cached. If the cache file is present, then return
   * the path from there instead of calling the cache again.
   *
   * @access public
   * @since  Taurus 1
   *
   * @param {string} $name    The name of the utility
   * @param {string} $path    The fullpath to the utility
   * @param {string} $message The "permissions" message from the JSON
   * @param {string} $icon    The workflow icon file (if exists)
   * @return {mixed}           FALSE on failure, path to utility on success
   */
  public function gatekeeper( $name, $path, $message = '', $icon = '' ) {

    $assetCache = "{$this->data}/data/call-cache";

    // Make sure the directory exists
    if ( ! ( ( file_exists( $assetCache ) && is_dir( $assetCache ) ) ) )
      mkdir( $assetCache, 0775, TRUE );

    // Cache path for this call
    $key       = md5( "{$name}-{$version}-{$type}-{$json}" );
    $cachePath =      "{$assetCache}/{$key}";

    if ( file_exists( "$cachePath" ) ) {
      $path = file_get_contents( $cachePath );
      if ( file_exists( $path ) ) {
        // The cache has been found, and we have the asset installed already.
        return $path;
      }
    }

    // If we're here, then we need to run the Gatekeeper script

    // Path to gatekeeper script
    $gatekeeper = realpath( dirname( __FILE__ ) ) . '/includes/gatekeeper.sh';

    // Execute the Gatekeeper script
    exec( "bash '{$gatekeeper}' '{$name}' '{$path}' '{$message}' '{$icon}' '{$this->bundle}'", $output, $status ); $line = __LINE__;

    // If the previous call returns a successful status code, then cache the path
    // and return it. Else, move to failure.
    if ( $status == 0 ) {
      file_put_contents( $cachePath, $path );
      return $path;
    }

    // There was an error with the Gatekeeper script (exited with a non-zero
    // status).

    // Output the error to STDERR.
    $this->reportLog( "Bundler Error: '{$name}' is needed to properly run " .
      "this workflow, and it must be whitelisted for Gatekeeper. You " .
      "either denied the request, or another error occured with " .
      " the Gatekeeper script.", 'ERROR', basename( __FILE__ ), $line );

    // So return FALSE as failure.
    return FALSE;
  }

  /**
   * Registers an asset
   *
   * The Bundler keeps a registry of which workflows use which assets.
   *
   * @access public
   * @since  Taurus 1
   *
   * @param {string} $asset   Name of the asset to be registered
   * @param {string} $version Version of asset to use
   * @return {bool}             Returns TRUE on success, FALSE on failure
   */
  public function register( $asset, $version ) {

    // We need the bundle to be set if we are to register the asset
    if ( ( ! isset( $this->bundle ) ) || empty( $this->bundle ) )
      return FALSE;

    // Load the registry data
    if ( ! file_exists( "{$this->data}/data/registry.json" ) ) {
      $registry = array();
    } else {
      if ( ! ( json_decode( file_get_contents( "{$this->data}/data/registry.json" ) ) ) ) {
        // The JSON file is bad -- start over.
        $registry = array();
      } else {
        $registry = json_decode( file_get_contents( "{$this->data}/data/registry.json" ), TRUE );
      }
    }

    if ( isset( $registry[ $asset ] ) ) {
      if ( ! array_key_exists( $version , $registry[ $asset ] ) ) {
        $registry[ $asset ][ $version ] = array();
        $update = TRUE;
      }
      if ( ! is_array( $registry[ $asset ][ $version] ) ) {
        $registry[ $asset ][ $version ] = array();
      }
      if ( ! in_array( $this->bundle , $registry[ $asset ][ $version ] ) ) {
        $registry[ $asset ][ $version ][] = $this->bundle;
        $update = TRUE;
      }
    } else {
      $registry[ $asset ] = array( $version => $this->bundle );
      $update = TRUE;
    }

    if ( $update ) file_put_contents( "{$this->data}/data/registry.json" , utf8_encode( json_encode( $registry ) ) );

    return TRUE;
  }

  /******************************************************************************
 * END HELPER FUNCTIONS
 *****************************************************************************/

  /******************************************************************************
 * BEGIN BONUS FUNCTIONS
 *****************************************************************************/

  /**
   * Uses Terminal Notifer to display a notification
   *
   * @param {string} $title   Title for notification
   * @param {string} $message Message of notification
   * @param {array} $options = array() An array of options that Terminal Notifer takes
   * @return {bool}                      TRUE on success, FALSE on failure
   */
  public function notify( $title, $message, $options = array() ) {

    // @TODO
    // Rewrite to use CD

   }

  /******************************************************************************
 * END BONUS FUNCTIONS
 *****************************************************************************/

}
