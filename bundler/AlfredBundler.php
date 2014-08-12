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
 * @package    AlfredBundler
 */


// We'll add this in for testing
if ( ! class_exists( 'AlfredBundlerInternalClass' ) ) :
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
 * @package AlfredBundler
 *
 */
class AlfredBundlerInternalClass {

  /**
   * A filepath to the bundler directory
   *
   * @access public
   * @var string
   */
  public   $data;

  /**
   * A filepath to the bundler cache directory
   *
   * @access public
   * @var string
   */
  public   $cache;

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
   * The data directory of the workflow using the bundler
   *
   * @var  string
   */
  private   $workflowData;

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
   * [$caches description]
   *
   * @access private
   * @var    array
   */
  private $caches;

  /**
   * Desc
   *
   * @access public
   * @var    object
   */
  public $log;

  /**
   * Desc
   *
   * @access public
   * @var    object
   */
  public $userLog;

  /**
   * Whether or not enviromental variables are present
   *
   * @access public
   * @var    bool
   */
  public $env;


  /**
   * General setup function for variables and directories
   *
   */
  private function setup() {

    if ( isset( $_ENV[ 'AB_TESTING' ] ) )
      $this->setupTests();
    elseif ( isset( $_ENV[ 'alfred_version' ] ) )
      $this->setupModern();
    else
      $this->setupDeprecated();

    $this->setupDirStructure();

  }

  /**
   * Sets variables for Alfred v2.4:277+
   */
  private function setupModern() {

    if ( ! file_exists( 'info.plist' ) )
      throw new Exception( 'Using the Alfred Bundler requires a valid info.plist file to be found; in other words, it needs to be used in a workflow. ');

    $this->bundle       = $_ENV[ 'alfred_workflow_bundleid' ];
    $this->name         = $_ENV[ 'alfred_workflow_name' ];
    $this->workflowData = $_ENV[ 'alfred_workflow_data' ];
    $this->env          = TRUE;

  }

  /**
   * Sets variables for versions of Alfred pre-2.4:277
   */
  private function setupDeprecated() {

    if ( ! file_exists( 'info.plist' ) )
      throw new Exception( 'Using the Alfred Bundler requires a valid info.plist file to be found; in other words, it needs to be used in a workflow. ');

    $this->bundle       = $this->readPlist( 'info.plist', 'bundleid' );
    $this->name         = $this->readPlist( 'info.plist', 'name' );
    $this->workflowData = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/" . $this->bundle;

    $this->env    = FALSE;

  }

  /**
   * Creates the directories for the bundler
   */
  private function setupDirStructure() {

    // This list is a bit redundant for the logic below, but that's fine.
    $directories = array(
      "{$this->data}/data",
      "{$this->cache}",
      "{$this->cache}/color",
      "{$this->cache}/misc",
      "{$this->cache}/php",
      "{$this->cache}/ruby",
      "{$this->cache}/python",
      "{$this->cache}/utility",
    );

    foreach ( $directories as $dir ) :
    if ( ! file_exists( $dir ) )
      mkdir( $dir, 0775, TRUE );
    endforeach;
  }


/**
 * Simple function to setup to test the bundler outside of Alfred.
 */
  private function setupTests() {
    $this->bundle = $_ENV['alfred_workflow_bundleid'];
    $this->name = $_ENV[ 'alfred_workflow_name' ];

    $this->env = TRUE;
  }

  /**
   * The class constructor
   *
   * Sets necessary variables.
   *
   * @access public
   * @param string $plist Path to workflow 'info.plist'
   * @return bool          Return 'true' regardless
   */
  public function __construct() {

    if ( isset( $_ENV['AB_BRANCH'] ) ) {
      $this->major_version = $_ENV['AB_BRANCH'];
    } else {
      $this->major_version = file_get_contents(  __DIR__ . '/meta/version_major' );
    }

    $this->minor_version   = file_get_contents(  __DIR__ . '/meta/version_minor' );

    $this->data   = trim( "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->cache  = trim( "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->log = new AlfredBundlerLogger( "{$this->data}/data/logs/bundler-{$this->major_version}" );
    $this->userLog = new AlfredBundlerLogger( "{$this->workflowData}/{$this->name}" );

    $this->setup();

    // Old code... take this out when we know we don't need any of it.
    // if ( isset( $_ENV[ 'alfred_version' ] ) ) {
    //   // As of Alfred v2.4 Build 277, environmental variables are available
    //   // that will make this process a lot easier and faster.
    //   $this->alfredVersion = array( 'version' => $_ENV[ 'alfred_version' ],
    //     'build'  => $_ENV[ 'alfred_version_build' ] );
    //   $this->home = $_ENV[ 'HOME' ];
    //   $this->alfredPreferences = $_ENV[ 'alfred_preferences' ];
    //   $this->preferencesHash = $_ENV[ 'alfred_preferences_local_hash' ];
    //   $this->themeBackground = $_ENV[ 'alfred_theme_background' ];
    //   $this->theme = $_ENV[ 'alfred_theme' ];
    //
    //   $plist = "{$this->alfredPreferences}/preferences/local/{$this->preferencesHash}/appearance/prefs.plist";
    // }


    // Let's just return something
    return TRUE;
  }

  /**
   * Load an asset using a generic function
   *
   *
   * @since  Taurus 1
   * @access public
   *
   * @param string $type    Type of asset
   * @param string $name    Name of asset
   * @param string $version Version of asset to load
   * @param string $json    = '' Path to json file
   * @return mixed             Returns path to utility on success, FALSE on failure
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

      $this->log->log( "There is a problem with the __implementation__ of " .
        "the Alfred Bundler when trying to load '{$name}'. Please " .
        "let the workflow author know.", 'CRITICAL', 'console' );
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
    $this->log->log( "Registering assset '{$name}'",
      'INFO', 'console' );

    // The file should exist now, but we'll try anyway
    if ( ! file_exists(
        "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) ) {

      return FALSE;
    }

    if ( $type != 'utility' ) {
      // We don't have to worry about gatekeeper
      $this->log->log( "Loaded '{$name}' version {$version} of type " .
        "'{$type}'", 'INFO', 'console' );

      return "{$this->data}/data/assets/{$type}/{$name}/{$version}/"
        . trim( file_get_contents( "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) );
    } else {
      // It's a utility, so let's see if we need gatekeeper
      if ( ! ( isset( $json[ 'gatekeeper' ] )
          && ( $json[ 'gatekeeper' ] == TRUE ) ) ) {

        // We don't have to worry about gatekeeper
        $this->log->log( "Loaded '{$name}' version {$version} of type " .
          "'{$type}'", 'INFO', 'console' );

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
      $this->log->log( "Loaded '{$name}' v{$version} of type '{$type}'.",
        'INFO', 'console' );
      return $path;
    } else {
      // The utility has not been whitelisted, so return an error.
      // The gatekeeper function already wrote the error to STDERR.
      return FALSE;
    }

    // We shouldn't get here. If we have, then it's a malformed request.
    // Output the error to STDERR.
    $this->log->log( "There is a problem with the __implementation__ of " .
      "the Alfred Bundler when trying to load '{$name}'. Please let the " .
      "workflow author know.", 'ERROR', 'console' );

    return FALSE;
  }



  public function icon( $font, $name, $color = '000000', $alter = FALSE ) {
    if ( ! isset( $this->icon ) )
      $this->icon = new AlfredBundlerIcon( $this );

    return $this->icon->icon([ 'font' => $font, 'name' => $name, 'color' => $color, 'alter' => $alter ]);
  }

  /**
   * Loads a utility
   *
   * @since  Taurus 1
   * @access public
   *
   * @param string $name    Name of utility
   * @param string $version = 'latest' Version of utility
   * @param string $json    = ''        File path to json
   * @return mixed                       Path to utility on success, FALSE on failure
   */
  public function utility( $name, $version = 'latest', $json = '' ) {
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
   * @param string $name    Name of library
   * @param string $version = 'latest' Version of library
   * @param string $json    = ''        File path to json
   * @return bool                        TRUE on success, FALSE on failure
   */
  public function library( $name, $version = 'latest', $json = '' ) {
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
  public function wrapper( $wrapper ) {
    $bindingsDir = "{$this->data}/bundler/includes/wrapper/php";
    if ( file_exists( "{$wrapperDir}/{$wrapper}.php" ) ) {
      require_once "{$wrapperDir}/{$wrapper}.php"; $line = __LINE__;
      $this->log->log( "Loaded '{$wrapper}' bindings", 'INFO', 'console' );
      return 0;
    } else {
      $this->log->log( "'{$wrapper}' not found.", 'CRITICAL', 'console' );
      return 10;
    }
  }

  /**
   * Loads / requires composer packages
   *
   * @todo refactor into a composer class
   *
   * @param array $packages An array of packages to load in composer
   * @return bool            True on success, false on failure
   */
  public function composer( $packages ) {
    $composerDir = "{$this->data}/data/assets/php/composer";
    if ( ! file_exists( $composerDir ) )
      mkdir( $composerDir, 0755, TRUE );

    if ( ! file_exists( "{$composerDir}/composer.phar" ) ) {
      $this->download( "https://getcomposer.org/composer.phar", "{$composerDir}/composer.phar" ); $line = __LINE__;
      exec( "'{$composerDir}/composer.phar'", $output, $status );
      if ( $status !== 0 ) {
        $this->log->log( "Composer.phar is corrupt. Deleting...", 'CRITICAL', 'console' );
      } else {
        $this->log->log( "Installing Composer.phar to `{$composerDir}`", 'INFO', 'both' );
      }
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
          $this->log->log( "Loaded Composer packages for {$this->bundle}.",
            'INFO', 'console' );
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
        $this->log->log( "Loaded Composer packages for {$this->bundle}.",
          'INFO', 'console' );
        require_once "{$composerDir}/bundles/{$this->bundle}/autoload.php";
        return TRUE;
      } else {
        $this->log->log( "ERROR: failed to install packages for {$this->bundle}", 'ERROR', 'both' );
        return FALSE;
      }
    }
  }



  /**
   * Creates an icns file out of the workflow's 'icon.png' file
   *
   * @return string Path to generated icns file
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
   * @param string $json    File path to json
   * @param string $version = 'latest' Version of asset to install
   * @return bool                        TRUE on success, FALSE on failure
   */
  public function installAsset( $json, $version = 'latest' ) {
    if ( ! file_exists( $json ) ) {
      $this->log->log( "Cannot install asset because the JSON file ('{$json}') is not present.", 'ERROR', 'console' );
      return FALSE;
    }

    // @TODO: Add error checking to make sure that the file is good JSON
    $json = json_decode( file_get_contents( $json ), TRUE );

    if ( $json == null ) {
      $this->log->log( "Cannot install asset because the JSON file ('{$json}') is not valid.", 'ERROR', 'console' );
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
      if ( ! isset( $json[ 'versions' ][ 'latest' ] ) ) {
        $this->log->log( "Cannot install {$name} because no version found and cannot fallback to 'latest'.", 'ERROR', 'both');
        return FALSE;
      } else {
        $version = 'latest';
      }
    }
    $invoke  = $json[ 'versions' ][ $version ][ 'invoke' ];
    $install = $json[ 'versions' ][ $version ][ 'install' ];

    // Download the file(s).
    foreach ( $json[ 'versions' ][ $version ][ 'files' ] as $url ) {
      $file = pathinfo( parse_url( $url[ 'url' ], PHP_URL_PATH ) );
      $file = $file[ 'basename' ];
      if ( ! $this->download( $url[ 'url' ], "{$tmpDir}/{$file}" ) ) {
        $this->log->log( "Cannot download {$name} at {$url['url']}.", 'ERROR', 'console' );
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
    $this->log->log( "Installed '{$type}': '{$name}' -- version '{$version}'.", 'INFO', 'both' );
    $this->rrmdir( "{$tmpDir}" );
    return TRUE;
  }

  /**
   * Installs composer packages
   *
   * @todo refactor into a composer class
   *
   * @param array $packages List of composer ready packages with versions
   * @return bool            TRUE on success, FALSE on failure
   */
  private function installComposerPackage( $packages ) {
    if ( ! is_array( $packages ) ) {
      // The packages variable needs to be an array
      $this->log->log( "An array must be passed to install Composer assets.", 'ERROR', 'console' );
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
    $this->log->log( "Rewrote Composer autoload file for workflow.", 'INFO', 'console' );

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

    $this->log->log( "Successfully installed composer packages. Cleaning up....", 'INFO', 'console' );

    $this->rrmdir( $installDir );

    return TRUE;
  }

  /******************************************************************************
 * END INSTALL FUNCTIONS
 *****************************************************************************/



  /*******************************************************************************
 * BEGIN HELPER FUNCTIONS
 ******************************************************************************/

  /**
   * Returns bundle id of workflow using bundler
   *
   * @return string Bundle id
   */
  public function bundle() {
    return $this->bundle;
  }

  /**
   * Reads a plist value using PlistBuddy
   *
   * @param string $plist File path to plist
   * @param string $key   Key of plist to read
   * @return mixed         FALSE if plist doesn't exist, else value of key
   */
  private function readPlist( $plist, $key ) {
    if ( ! file_exists( $plist ) )
      return FALSE;

    return exec( "/usr/libexec/PlistBuddy -c 'Print :{$key}' '{$plist}'" );
  }

  /**
   * Wraps a cURL function to download files
   *
   * @param string $url     A URL to the file
   * @param string $file    The destination file
   * @param int   $timeout =  '3' A timeout variable (in seconds)
   * @return bool                   True on success and error code / false on failure
   *
   * @access public
   * @since  Taurus 1
   */
  public function download( $url, $file, $timeout = '5' ) {
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

    $this->log->log( "Downloading `{$url}` ...", 'INFO', 'console' );

    curl_close( $ch );
    fclose( $fp );
    return TRUE;
  }


  /**
   * Log function for the user to employ
   *
   * @param   string  $message      message to log
   * @param   mixed   $level        [description]
   * @param   string  $destination  [description]
   *
   * @return  [type]                [description]
   *
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   */
  public function log( $message, $level = 'INFO', $destination = 'log' ) {
    $this->userLog( $message, $level, $destination );
  }

  /**
   * Recursively removes a folder along with all its files and directories
   *
   * @link http://php.net/manual/en/function.rmdir.php#110489
   *
   * @access public
   * @since  Taurus 1
   *
   * @param string $path Path to directory to remove
   */
  public function rrmdir( $path ) {
    // Open the source directory to read in files
    $files = array_diff( scandir( $path ), array( '.', '..' ) );
    foreach ( $files as $file ) {
      if ( is_dir( "{$path}/{$file}" ) )
        $this->rrmdir( "{$path}/{$file}" );
      else if ( file_exists( "{$path}/{$file}" ) )
        unlink( "{$path}/{$file}" );
      else {
        echo "Removing dir error... uh..." . PHP_EOL; // add in proper logging
      }
    }
    return rmdir( $path );
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
   * @param string $name    The name of the utility
   * @param string $path    The fullpath to the utility
   * @param string $message The "permissions" message from the JSON
   * @param string $icon    The workflow icon file (if exists)
   * @return mixed           FALSE on failure, path to utility on success
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
    $this->log->log( "Bundler Error: '{$name}' is needed to properly run " .
      "this workflow, and it must be whitelisted for Gatekeeper. You " .
      "either denied the request, or another error occured with " .
      " the Gatekeeper script.", 'ERROR', 'console' );

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
   * @param string $asset   Name of the asset to be registered
   * @param string $version Version of asset to use
   * @return bool             Returns TRUE on success, FALSE on failure
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
   * @param string $title   Title for notification
   * @param string $message Message of notification
   * @param array $options = array() An array of options that Terminal Notifer takes
   * @return bool                      TRUE on success, FALSE on failure
   */
  public function notify( $title, $message, $options = array() ) {

    // @TODO
    // Rewrite to use CD

   }

  /******************************************************************************
 * END BONUS FUNCTIONS
 *****************************************************************************/

}
endif;

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


if ( ! class_exists( 'AlfredBundlerLogger' ) ) :
/**
 *
 * Simple logging functionality that writes to files or STDERR
 *
 * Usage: just create a single object and reuse it solely. Initialize the
 * object with a full path to the log file (no log extension)
 *
 * This class was written to be part of the PHP implementation of the
 * Alfred Bundler for the bundler's internal logging requirements. However
 * its functionality is also made available to any workflow author implementing
 * the bundler.
 *
 * While you can use this class without going through the bundler, it is
 * easier just to use the logging functionality indirectly via the
 * bundler object.
 *
 * @see       AlfredBundlerInternalClass::log
 *
 * @package   AlfredBundler
 * @since     Class available since Taurus 1
 *
 */
class AlfredBundlerLogger {

  /**
   * Log file
   *
   * Full path to log file with no extension; set by user at instantiation
   *
   * @var  string
   * @since Taurus 1
   */
  public $log;

  /**
   * An array of log levels (int => string )
   *
   * 0 => 'DEBUG'
   * 1 => 'INFO'
   * 2 => 'WARNING'
   * 3 => 'ERROR'
   * 4 => 'CRITICAL'
   *
   * @var  array
   * @since Taurus 1
   */
  protected $logLevels;

  /**
   * Stacktrace information; reset with each message
   *
   * @var  array
   * @since Taurus 1
   */
  private $trace;

  /**
   * File from stacktrace; reset with each message
   *
   * @var  string
   * @since Taurus 1
   */
  private $file;

  /**
   * Line from stacktrace; reset with each message
   *
   * @var  int
   * @since Taurus 1
   */
  private $line;

  /**
   * Log level; reset with each message
   *
   * @var  mixed
   * @since Taurus 1
   */
  private $level;


  /**
   * Sets variables and ini settings to ensure there are no errors
   *
   * @param  string  $log  filename to use as a log
   * @since Taurus 1
   */
  public function __construct( $log ) {

    $this->log = $log . '.log';
    $this->initializeLog();

    // These are the appropriate log levels
    $this->logLevels = array( 0 => 'DEBUG',
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

    // This is needed because, Macs don't read EOLs well.
    if ( ! ini_get( 'auto_detect_line_endings' ) )
      ini_set( 'auto_detect_line_endings', TRUE );

  }


  /**
   * Creates log directory and file if necessary
   * @since Taurus 1
   */
  private function initializeLog() {
    if ( ! file_exists( $this->log ) ) {
      if ( ! is_dir( realpath( dirname( $this->log ) ) ) )
          mkdir( realpath( dirname( $this->log ) ), 0775, TRUE );
      file_put_contents( $this->log, '' );
    }
  }


  /**
   * Checks to see if the log needs to be rotated
   * @since Taurus 1
   */
  private function checkLog() {
    if ( filesize( $this->log ) > 1048576 )
      $this->rotateLog();
  }


  /**
   * Rotates the log
   * @since Taurus 1
   */
  private function rotateLog() {
      $old = substr( $this->log, -4 );
      if ( file_exists( $old . '1.log' ) )
        unlink( $old . '1.log' );

      rename( $this->log, $old . '1.log' );
      file_put_contents( $this->log, '' );
  }


  /**
   * Logs a message to either a file or STDERR
   *
   * After initializing the log object, this should be the only
   * method with which you interact.
   *
   * While you could use this separate from the bundler itself, it is
   * easier to use the logging functionality from the bundler object.
   *
   * @see AlfredBundlerInternalClass::log
   *
   * <code>
   * $log = new AlfredBundlerLogger( '/full/path/to/mylog' );
   * $log->log( 'Write this to a file', 'INFO' );
   * $log->log( 'Warning message to console', 2, 'console' );
   * $log->log( 'This message will go to both the console and the log', 3, 'both');
   * </code>
   *
   *
   * @param   string  $message      message to log
   * @param   mixed   $level        either int or string of log level
   * @param   string  $destination  where the message should appear:
   *                                valid options: 'log', 'console', 'both'
   * @since Taurus 1
   */
  public function log( $message, $level = 'INFO', $destination = 'log' ) {

    // Get the relevant information from the backtrace
    $this->trace = array_shift( debug_backtrace() );
    $this->file = basename( $this->trace[ 'file' ] );
    $this->line = $this->trace[ 'line' ];

    // check / normalize the arguments
    $this->level = $this->normalizeLogLevel( $level );
    $destination = strtolower( $destination );

    if ( $destination == 'log' || $destination == 'both' )
      $this->logFile( $message );
    if ( $destination == 'console' || $destination == 'both' )
      $this->logConsole( $message );

  }

  /**
   * Ensures that the log level is valid
   *
   * @param   mixed  $level   either an int or a string denoting log level
   *
   * @return  string          log level as string
   * @since Taurus 1
   */
  public function normalizeLogLevel( $level ) {

    $date = date( 'H:i:s', time() );

    // If the level is okay, then just return it
    if ( isset( $this->logLevels[ $level ] )
         || in_array( $level, $this->logLevels ) ) {
      return $level;
    }

    // the level is invalid; log a message to the console
    file_put_contents( 'php://stderr', "[{$date}] " .
      "[{$this->file},{$this->line}] [WARNING] Log level '{$level}' " .
      "is not valid. Falling back to 'INFO' (1)" . PHP_EOL );

    // set level to info
    return 'INFO';
  }

  /**
   * Writes a message to the console (STDERR)
   *
   * @param   string  $message  message to log
   * @since Taurus 1
   */
  public function logConsole( $message ) {
    $date = date( 'H:i:s', time() );
    file_put_contents( 'php://stderr', "[{$date}] " .
      "[{$this->file}:{$this->line}] [{$this->level}] {$message}" . PHP_EOL );
  }

  /**
   * Writes message to log file
   *
   * @param   string  $message  message to log
   * @since Taurus 1
   */
  public function logFile( $message ) {
    $date = date( "Y-m-d H:i:s" );
    $message = "[{$date}] [{$this->file}:{$this->line}] " .
               "[{$this->level}] ". $message . PHP_EOL;
    file_put_contents( $this->log, $message, FILE_APPEND | LOCK_EX );
  }


}
endif;