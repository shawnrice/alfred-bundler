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
 * @package    AlfredBundler
 * @since      File available since Taurus 1
 */

require_once( __DIR__ . '/includes/php-classes/AlfredBundlerLogger.php' );
require_once( __DIR__ . '/includes/php-classes/AlfredBundlerIcon.php' );

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
 * @package   AlfredBundler
 *
 */
class AlfredBundlerInternalClass {

  /**
   * A filepath to the bundler directory
   * @var string
   */
  public   $data;

  /**
   * A filepath to the bundler cache directory
   * @var string
   */
  public   $cache;

  /**
   * The MAJOR version of the bundler (which API to use)
   * @var string
   */
  public   $major_version;

  /**
   * The MINOR version of the bundler
   * @var string
   */
  public   $minor_version;

  /**
   * Filepath to an Alfred info.plist file
   * @var string
   */
  public   $plist;

  /**
   * The Bundle ID of the workflow using the bundler
   * @var string
   */
  public   $bundle;

  /**
   * The name of the workflow using the bundler
   * @var string
   */
  public   $name;

  /**
   * The data directory of the workflow using the bundler
   * @var  string
   */
  public   $workflowData;

  /**
   * The background 'color' of the user's current Alfred theme (light or dark)
   * @var string
   */
  public   $background;

  /**
   * File resource of mimetypes
   * @var  resource
   */
  public   $finfo;

  /**
   * Version of Alfred installed
   * @var  string
   */
  public   $alfredVersion;

  /**
   * Directory for caches
   * @var    array
   */
  private   $caches;

  /**
   * Desc
   * @var    object
   */
  public    $log;

  /**
   * Desc
   * @var    object
   */
  public    $userLog;

  /**
   * Whether or not enviromental variables are present
   * @var    bool
   */
  public    $env;


  /**
   * The class constructor
   *
   * Sets necessary variables.
   * @since  Taurus 1
   * @param  string $options a list of options to configure the instance
   * @return bool          Return 'true' regardless
   */
  public function __construct( $options = [] ) {

    if ( isset( $_ENV['AB_BRANCH'] ) )
      $this->major_version = $_ENV['AB_BRANCH'];
    else
      $this->major_version = file_get_contents(  __DIR__ . '/meta/version_major' );

    $this->minor_version   = file_get_contents(  __DIR__ . '/meta/version_minor' );
    $this->data  = trim( "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->cache = trim( "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}" );
    $this->setup();
    $this->log = new AlfredBundlerLogger( "{$this->data}/data/logs/bundler-{$this->major_version}" );

    if ( isset( $options[ 'log' ] ) )
      $log = $options[ 'log' ];
    else
      $log = 'file';

    if ( isset( $options[ 'wf_log' ] ) && ( $options[ 'wf_log' ] == TRUE ) )
      $this->userLog = new AlfredBundlerLogger( "{$this->workflowData}/{$this->name}", $log );

    return TRUE;
  }

  /**
   * General setup function for variables and directories
   *
   * @since  Taurus 1
   */
  private function setup() {

    // This should be taken care of by the bundlet, but for redundnacy...
    if ( ! file_exists( 'info.plist' ) )
          throw new Exception( 'Using the Alfred Bundler requires a valid info.plist file to be found; in other words, it needs to be used in a workflow. ');

    if ( isset( $_ENV[ 'alfred_version' ] ) )
      $this->setupModern();
    else
      $this->setupDeprecated();

    $this->setupDirStructure();

  }

  /**
   * Sets variables for Alfred v2.4:277+
   *
   * @since  Taurus 1
   */
  private function setupModern() {

    $this->bundle       = $_ENV[ 'alfred_workflow_bundleid' ];
    $this->name         = $_ENV[ 'alfred_workflow_name' ];
    $this->workflowData = $_ENV[ 'alfred_workflow_data' ];
    $this->env          = TRUE;
  }

  /**
   * Sets variables for versions of Alfred pre-2.4:277
   *
   * @since  Taurus 1
   */
  private function setupDeprecated() {

    $this->bundle       = $this->readPlist( 'info.plist', 'bundleid' );
    $this->name         = $this->readPlist( 'info.plist', 'name' );
    $this->workflowData = $_SERVER[ 'HOME' ] .
      "/Library/Application Support/Alfred 2/Workflow Data/" . $this->bundle;
    $this->env          = FALSE;
  }

  /**
   * Creates the directories for the bundler
   *
   * @since  Taurus 1
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
      "{$this->cache}/utilities",
    );

    foreach ( $directories as $dir ) :
      // @TODO add in better error handling here (for redundancy)
      if ( ! file_exists( $dir ) )
        mkdir( $dir, 0775, TRUE );
    endforeach;

  }

/**
 * Processes load arguments to get the proper json information
 *
 * @since  Taurus 1
 *
 * @param   string  $type     type of asset
 * @param   string  $name     name of asset
 * @param   string  $version  version of asset
 * @param   string  $json     path to json
 *
 * @return  Array             an array of the asset's json file or false
 */
  public function getJson($type, $name, $version, $json) {
    if ( empty( $json ) ) {
      if ( file_exists( __DIR__ . "/meta/defaults/{$name}.json" ) ) {
        $json_path = __DIR__ . "/meta/defaults/{$name}.json";
      } else {
        // JSON File cannot be found
        $error = TRUE;
      }
    } else if ( file_exists( $json ) ) {
        $json_path = $json;
      } else {
      // JSON File cannot be found
      $error = TRUE;
    }

    // Check to see if the JSON is valid
    if ( isset( $json_path) && ! json_decode( file_get_contents( $json_path ) ) ) {
      // JSON file not valid
      $error = TRUE;
    }

    // If we've encountered an error, then write the error and exit
    if ( isset( $error ) && ( $error === TRUE ) ) {
      // There is an error with the JSON file.
      $this->log->log( "There is a problem with the __implementation__ of " .
        "the Alfred Bundler when trying to load '{$name}'. Please " .
        "let the workflow author know.", 'CRITICAL', 'console' );
      return FALSE;
    }

    return json_decode( file_get_contents( $json_path ), TRUE );
  }

  /**
   * Load an asset using a generic function
   *
   * @since  Taurus 1
   * @param string $type    Type of asset
   * @param string $name    Name of asset
   * @param string $version Version of asset to load
   * @param string $json    Path to json file
   * @return mixed          Path to utility on success, FALSE on failure
   */
  public function load( $type, $name, $version, $json = '' ) {

    $json = $this->getJson( $type, $name, $version, $json  );

    // See if the file is installed
    if ( ! file_exists(
        "{$this->data}/data/assets/{$type}/{$name}/{$version}/invoke" ) ) {

      if ( ! $this->installAsset(
          "{$this->data}/bundler/meta/defaults/{$name}.json", $version ) ) {
        return FALSE;
      }
    }

    // Register the asset. We don't need to worry about the return.
    $this->register( $name, $version );
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
    if ( file_exists( 'icon.png' ) )
      $icon = realpath( 'icon.png' );
    else
      $icon = 'default';

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
    if ( $this->gatekeeper( $name, $path, $message, $icon ) ) {
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

/**
 * Retrieves an icon
 *
 * Actually, this method just wraps around the method from the Icon class.
 *
 * @since  Taurus 1
 *
 * @param   string   $font   name of font
 * @param   string   $name   name of icon
 * @param   string   $color  hex color
 * @param   boolean  $alter  whether to alter the icon's color
 *
 * @return  string           a path to the icon
 */
  public function icon( $font, $name, $color = '000000', $alter = FALSE ) {
    if ( ! isset( $this->icon ) )
      $this->icon = new AlfredBundlerIcon( $this );

    return $this->icon->icon([ 'font' => $font, 'name' => $name, 'color' => $color, 'alter' => $alter ]);
  }

  /**
   * Loads a utility
   *
   * @since  Taurus 1
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
   * Loads a wrapper object
   *
   * @since  Taurus 1
   *
   * @param   string   $wrapper  name of wrapper to load
   * @param   boolean  $debug    turn debugging off / on
   * @return  object             a wrapper object
   */
  public function wrapper( $wrapper, $debug = FALSE ) {
    $wrapperPointer = [
        'cocoadialog'=>'cocoaDialog',
        'terminalnotifier'=>'terminal-notifier'
    ];
    $wrappersDir = "{$this->data}/bundler/includes/wrappers/php";
    if ( file_exists( "{$wrappersDir}/{$wrapper}.php" ) ) {
      require_once "{$wrappersDir}/{$wrapper}.php";
      $this->log->log( "Loaded '{$wrapper}' bindings", 'INFO', 'console' );
      return new $wrapper( $this->utility( $wrapperPointer[strtolower( $wrapper )] ), $debug );
    } else {
      $this->log->log( "'{$wrapper}' not found.", 'ERROR', 'console' );
      return 10;
    }
  }

  /**
   * Installs Composer into the bundler's data directory
   *
   * @since Taurus 1
   */
  public function installComposer() {
    if ( ! file_exists( "{$this->composerDir}/composer.phar" ) ) {
      $this->download( "https://getcomposer.org/composer.phar", "{$this->composerDir}/composer.phar" );
      exec( "php '{$this->composerDir}/composer.phar'", $output, $status );
      if ( $status !== 0 ) {
        $this->log->log( "Composer.phar is corrupt. Deleting...", 'CRITICAL', 'console' );
        $this->rrmdir( $this->composerDir );
        return false;
      } else {
        $this->log->log( "Installing Composer.phar to `{$this->composerDir}`", 'INFO', 'both' );
        return true;
      }
    }
    return true;
  }

  /**
   * Loads / requires composer packages
   *
   * @todo refactor into a composer class
   * @since  Taurus 1
   *
   * @param array $packages An array of packages to load in composer
   * @return bool            True on success, false on failure
   */
  public function composer( $packages ) {

    if ( ! file_exists( $this->composerDir = "{$this->data}/data/assets/php/composer" ) )
      mkdir( $this->composerDir, 0775, TRUE );

    if ( ! $this->installComposer() )
      return false;
    $install = FALSE;

    if ( file_exists( "{$this->composerDir}/bundles/{$this->bundle}/autoload.php" ) ) {
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
            "{$this->composerDir}/bundles/{$this->bundle}/autoload.php" );

          return TRUE;
        } else {
          $install = TRUE;
          if ( file_exists( "{$this->composerDir}/bundles/{$this->bundle}" ) ) {
            $this->rrmdir( "{$this->composerDir}/bundles/{$this->bundle}" );
          }
        }
      }
    } else {
      $install = TRUE;
    }

    if ( $install === TRUE )
      return $this->doComposerInstall( $packages );

    return TRUE;
  }

  /**
   * Executes and checks the composer install packages method
   *
   * @since Taurus 1
   *
   * @param   array  $packages  an array of packages to be installed
   * @return  bool
   */
  public function doComposerInstall( $packages ) {
    if ( is_dir( "{$this->composerDir}/bundles/{$this->bundle}" ) )
      $this->rrmdir( "{$this->composerDir}/bundles/{$this->bundle}" );

    if ( $this->installComposerPackage( $packages ) === TRUE ) {
      $this->log->log( "Loaded Composer packages for {$this->bundle}.", 'INFO', 'console' );
      require_once "{$this->composerDir}/bundles/{$this->bundle}/autoload.php";
      return TRUE;
    }

    $this->log->log( "ERROR: failed to install packages for {$this->bundle}", 'ERROR', 'both' );
    return FALSE;
  }

  /**
   * Creates an icns file out of the workflow's 'icon.png' file
   *
   * @since  Taurus 1
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

  /****************************************************************************
   * BEGIN INSTALL FUNCTIONS
   ***************************************************************************/

  /**
   * Installs an asset based on JSON information
   *
   * @since  Taurus 1
   * @param string $json    File path to json
   * @param string $version = 'latest' Version of asset to install
   * @return bool                        TRUE on success, FALSE on failure
   */
  public function installAsset( $json, $version = 'latest' ) {
    if ( ! file_exists( $json ) ) {
      $this->log->log( "Cannot install asset because the JSON file ('{$json}') is not present.", 'ERROR', 'console' );
      return FALSE;
    }

    $json = json_decode( file_get_contents( $json ), TRUE );

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

    // Check to make sure that the JSON is valid.
    if ( $json == null ) {
      $this->log->log( "Cannot install asset because the JSON file ('{$json}') is not valid.", 'ERROR', 'console' );
      return FALSE;
    }

    $installDir = "{$this->data}/data/assets/{$json[ 'type' ]}/{$json[ 'name' ]}/{$version}";

    if ( file_exists( "{$installDir}/invoke" ) )
      return $installDir . "/" . file_get_contents( "{$installDir}/invoke" );

    // Make the installation directory if it doesn't exist
    if ( ! file_exists( $installDir ) )
      mkdir( $installDir, 0775, TRUE );

    // Make the temporary directory
    $tmpDir = "{$this->cache}/installers";
    if ( ! file_exists( $tmpDir ) )
      mkdir( $tmpDir, 0775, TRUE );

    $name = $json[ 'name' ];
    $type = $json[ 'type' ];


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
    return $version;
  }

  /**
   * Installs composer packages
   *
   * @todo    refactor into a composer class
   * @since   Taurus 1
   * @param   array $packages List of composer ready packages with versions
   * @return  bool            TRUE on success, FALSE on failure
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
    $vendor      = $name[0];                           // vendor
    $name        = $name[1];                           // package name
    $version     = $package[ 'version' ];              // version installed
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

  /****************************************************************************
   * END INSTALL FUNCTIONS
   *
   * BEGIN HELPER FUNCTIONS
   ***************************************************************************/

  /**
   * Returns bundle id of workflow using bundler
   *
   * @since  Taurus 1
   * @return string Bundle id
   */
  public function bundle() {
    return $this->bundle;
  }

  /**
   * Reads a plist value using PlistBuddy
   *
   * @since  Taurus 1
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
   * @since  Taurus 1
   * @param string $url     A URL to the file
   * @param string $file    The destination file
   * @param int   $timeout =  '3' A timeout variable (in seconds)
   * @return bool                   True on success and error code / false on failure
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
   * @param   string  $message        message to log
   * @param   mixed   $level='INFO'   level of the log message
   * @param   string  $destination='' destination ( file, console, both )
   *                                  an empty argument will use the default
   *                                  destination set at instantiation
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   */
  public function log( $message, $level = 'INFO', $destination = '' ) {
    $this->userLog->log( $message, $level, $destination, 3 );
  }

  /**
   * Wraps around 'log' to level 'DEBUG'
   *
   * @param   string  $message        message to log
   * @param   string  $destination='' destination ( file, console, both )
   *                                  an empty argument will use the default
   *                                  destination set at instantiation
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   * @see AlfredBundlerInternalClass:log
   */
  public function debug( $message, $destination = '' ) {
    $this->userLog->log( $message, 'DEBUG', $destination, 3 );
  }

  /**
   * Wraps around 'log' to level 'INFO'
   *
   * @param   string  $message        message to log
   * @param   string  $destination='' destination ( file, console, both )
   *                                  an empty argument will use the default
   *                                  destination set at instantiation
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   * @see AlfredBundlerInternalClass:log
   */
  public function info( $message, $destination = '' ) {
    $this->userLog->log( $message, 'INFO', $destination, 3 );
  }

  /**
   * Wraps around 'log' to level 'WARNING'
   *
   * @param   string  $message        message to log
   * @param   string  $destination='' destination ( file, console, both )
   *                                  an empty argument will use the default
   *                                  destination set at instantiation
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   * @see AlfredBundlerInternalClass:log
   */
  public function warning( $message, $destination = '' ) {
    $this->userLog->log( $message, 'WARNING', $destination, 3 );
  }

  /**
   * Wraps around 'log' to level 'ERROR'
   *
   * @param   string  $message        message to log
   * @param   string  $destination='' destination ( file, console, both )
   *                                  an empty argument will use the default
   *                                  destination set at instantiation
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   * @see AlfredBundlerInternalClass:log
   */
  public function error( $message, $destination = '' ) {
    $this->userLog->log( $message, 'ERROR', $destination, 3 );
  }

  /**
   * Wraps around 'log' to level 'CRITICAL'
   *
   * @param   string  $message        message to log
   * @param   string  $destination='' destination ( file, console, both )
   *                                  an empty argument will use the default
   *                                  destination set at instantiation
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   * @see AlfredBundlerInternalClass:log
   */
  public function critical( $message, $destination = '' ) {
    $this->userLog->log( $message, 'CRITICAL', $destination, 3 );
  }

  /**
   * Wraps around 'log' to send to 'console'
   *
   * @param   string  $message  message to log
   * @param   mixed   $level    level of log
   * @since Taurus 1
   * @see AlfredBundlerLogger:log
   * @see AlfredBundlerInternalClass:log
   */
  public function console( $message, $level = 'INFO' ) {
    $this->userLog->log( $message, $level, 'console', 3 );
  }

  /**
   * Recursively removes a folder along with all its files and directories
   *
   * @link http://php.net/manual/en/function.rmdir.php#110489
   * @since  Taurus 1
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
   * @since  Taurus 1
   * @param string $name    The name of the utility
   * @param string $path    The fullpath to the utility
   * @param string $message The "permissions" message from the JSON
   * @param string $icon    The workflow icon file (if exists)
   * @return mixed           FALSE on failure, path to utility on success
   */
  public function gatekeeper( $name, $path, $message = '', $icon = '' ) {

    $assetCache = "{$this->cache}/utilities";

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
    $gatekeeper = realpath( __DIR__ ) . '/includes/gatekeeper.sh';
    // Execute the Gatekeeper script
    exec( "bash '{$gatekeeper}' '{$name}' '{$path}' '{$message}' '{$icon}' '{$this->bundle}'", $output, $status );

    // If the previous call returns a successful status code, then cache
    // the path and return it. Else, move to failure.
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
      " the Gatekeeper script.", 'ERROR', 'both' );

    // So return FALSE as failure.
    return FALSE;
  }

  /**
   * Registers an asset
   *
   * The Bundler keeps a registry of which workflows use which assets.
   * @since  Taurus 1
   * @param string $asset   Name of the asset to be registered
   * @param string $version Version of asset to use
   * @return bool             Returns TRUE on success, FALSE on failure
   */
  public function register( $asset, $version ) {

    // We need the bundle to be set if we are to register the asset
    if ( ( ! isset( $this->bundle ) ) || empty( $this->bundle ) )
      return FALSE;

    // Load the registry data
    $registry = array();

    if ( file_exists( "{$this->data}/data/registry.json" ) )
        $registry = json_decode( file_get_contents( "{$this->data}/data/registry.json" ), TRUE );

    if ( isset( $registry[ $asset ] ) ) {

      if ( ! array_key_exists( $version , $registry[ $asset ] ) ) {
        $registry[ $asset ][ $version ] = array();
        $update = TRUE;
      }
      if ( ! is_array( $registry[ $asset ][ $version ] ) ) {
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

    if ( $update )
      file_put_contents( "{$this->data}/data/registry.json", utf8_encode( json_encode( $registry ) ) );

    return TRUE;
  }

  /**
   * Uses CocoaDialog to display a notification
   *
   * @since  Taurus 1
   * @param  string $title   Title for notification
   * @param  string $message Message of notification
   * @param  string $icon    An array of options that Terminal Notifer takes
   * @return bool           TRUE on success, FALSE on failure
   */
  public function notify( $title, $message, $icon = null ) {
    if ( gettype( $title ) !== 'string' || gettype( $message ) !== 'string' )
      return false;

    if ( $icon === null ) {
      if ( file_exists( 'icon.png' ) )
        $icon = 'icon.png';
    }

    $client = $this->wrapper( 'CocoaDialog' );
    $icon_type = 'icon';
    if ( ( ! is_null( $icon ) ) && ( gettype( $icon ) === 'string' ) ) {
      if ( ! file_exists( $icon ) ) {
        if ( ! in_array( $icon, $client->global_icons ) ) {
          $icon_type = null;
        }
      } else {
        $icon_type = 'icon_file';
      }
    } else {
      $icon_type = null;
    }
    $notification = [
      'title'=>$title,
      'description'=>$message,
      'alpha'=>1,
      'background_top'=>'ffffff',
      'background_bottom'=>'ffffff',
      'border_color'=>'ffffff',
      'text_color'=>'000000',
      'no_growl'=>true,
    ];
    if ( ! is_null( $icon_type ) ) {
      $notification[$icon_type] = $icon;
    }
    $client->notify( $notification );
    return true;

   }

}
endif;