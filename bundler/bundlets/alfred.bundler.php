<?php

/**
 * PHP implementation of the Alfred Bundler
 *
 * Main PHP interface for the Alfred Dependency Bundler. This file should be
 * the only one from the bundler that is distributed with your workflow.
 * You can use this file and the class contained within it to lazy load a
 * variety of assets that can be used in your workflows.
 *
 * This file is part of the Alfred Bundler, released under the MIT licence.
 * Copyright (c) 2014 The Alfred Bundler Team
 * See https://shawnrice.github.io/alfred-bundler for more information.
 *
 * @copyright  The Alfred Bundler Team 2014
 * @license    http://opensource.org/licenses/MIT  MIT
 * @version    Taurus 1
 * @link       http://shawnrice.github.io/alfred-bundler
 * @package    AlfredBundler
 * @since      File available since Aries 1
 */


/**
 * The PHP interface for the Alfred Bundler
 *
 * This class is the only one that you should interact with. The rest of the
 * magic that the bundler performs happens under the hood. Also, the backend
 * of the bundler (here the 'AlfredBundlerInternalClass') may change; however,
 * this bundlet will continue to work with the bundler API for the remainder of
 * this major version (Taurus). Limited documentation is below, for more
 * detailed documentation, see http://shawnrice.github.io/alfred-bundler.
 *
 * Example usage:
 * <code>
 * require_once( 'alfred.bundler.php' );
 * $b = new AlfredBundler;
 *
 * // Downloads and requires David Ferguson's PHP Workflows library
 * $b->library( 'Workflows' );
 *
 * // Download icons
 * $icon1 = $b->icon( 'elusive', 'dashboard', 'ab332c', TRUE );
 * $icon2 = $b->icon( 'fontawesome', 'adjust', 'aabbcc', '998877');
 * $icon3 = $b->icon( 'fontawesome, 'bug' );
 * $icon4 = $b->icon( 'system', 'Accounts' );
 *
 * // Send a message to the console (shows up in Alfred's debugger)
 * $b->log( 'Loaded icons', 'INFO', 'console' );
 * // Log a message to a logfile found in the workflow's data directory
 * $b->log( 'Initial bootstrap complete, check the log file', 'DEBUG', 'log' );
 * // Send the same message to the console and the log file
 * $b->log( 'Bootstrap completed.', 'INFO', 'both' );
 *
 *
 * // Get Pashua to use later
 * $pashua = $b->utility( 'Pashua' );
 *
 * // Get an asset not included in the "defaults"
 * $myAsset = $b->load( 'utility', 'myAsset', 'latest', '/path/to/json' );
 *
 * // Load 'cocoadialog' with the bundler's wrappers
 * $cocoadialog = $b->wrapper( 'cocoadialog' );
 *
 * // Load/install composer packages
 * $bundler->composer( array(
 *   "monolog/monolog" => "1.10.*@dev"
 * ));
 *
 * </code>
 *
 * @see       AlfredBundlerInternalClass
 * @since     Class available since Taurus 1
 *
 */
class AlfredBundler {

  /**
   * An internal object that interfaces with the PHP Bundler API
   *
   * @access protected
   * @var object
   */
  protected $bundler;

  /**
   * A filepath to the bundler directory
   *
   * We're using this name so it doesn't clash with the internal $data
   * variable.
   *
   * @access public
   * @var string
   */
  private   $_data;

  /**
   * A filepath to the bundler cache directory
   *
   * We're using this name so it doesn't clash with the internal $data
   * variable.
   *
   * @access private
   * @var string
   */
  private   $_cache;

  /**
   * The MAJOR version of the bundler (which API to use)
   *
   * @access private
   * @var string
   */
  private   $_major_version;

  /**
   * The class constructor
   *
   * @return bool Returns successful/failed instantiation
   */
  public function __construct() {

    if ( ! file_exists( 'info.plist' ) ) {
      throw new Exception('The Alfred Bundler cannot be used without an `info.plist` file present.');
      return FALSE;
    }

    if ( isset( $_ENV[ 'AB_BRANCH' ] ) && ! empty( $_ENV[ 'AB_BRANCH' ] ) ) {
      $this->_major_version = $_ENV[ 'AB_BRANCH' ];
    } else {
      $this->_major_version = 'devel';
    }

    // Set date/time to avoid warnings/errors.
    if ( ! ini_get( 'date.timezone' ) ) {
      $tz = exec( 'tz=`ls -l /etc/localtime` && echo ${tz#*/zoneinfo/}' );
      ini_set( 'date.timezone', $tz );
    }

    $this->_data  = "{$_SERVER['HOME']}/Library/Application Support/Alfred 2/" .
      "Workflow Data/alfred.bundler-{$this->_major_version}";
    $this->_cache = "{$_SERVER['HOME']}/Library/Caches/" .
      "com.runningwithcrayons.Alfred-2/Workflow Data/" .
      "alfred.bundler-{$this->_major_version}";

    if ( file_exists( "{$this->_data}/bundler/AlfredBundler.php" ) ) {
      require_once ( "{$this->_data}/bundler/AlfredBundler.php" );
      $this->bundler = new AlfredBundlerInternalClass();
    } else {
      if ( $this->installBundler() === FALSE ) {
        // The bundler could not install itself, so throw an exception.
        throw new Exception('The Alfred Bundler could not be installed.');
        return FALSE;
      } else {
        chmod( "{$this->_data}/bundler/includes/LightOrDark", 0755 );
        // The bundler is now in place, so require the actual PHP Bundler file
        require_once "{$this->_data}/bundler/AlfredBundler.php";
        // Create the internal class object
        $this->bundler = new AlfredBundlerInternalClass();
        $this->bundler->notify(
        'Alfred Bundler',
        'Installation successful. Thank you for waiting.',
        "{$this->_data}/bundler/meta/icons/bundle.png"
      );
      }
    }

    // Call the wrapper to update itself, processed is forked for speed
    exec( "bash '{$this->_data}/bundler/meta/update-wrapper.sh'" );

    return TRUE;
  }

  /**
   * Logs output to the console
   *
   * This method provides very limited console logging functionality. It is
   * employed only by this bundlet only when it is installing the PHP
   * implementation of the Alfred Bundler. A much more robust logging
   * functionality is the the backend, so those methods will be used at all
   * other times.
   *
   * @see     AlfredBundlerInternalClass::log
   * @see     AlfredBundlerLogger::log
   * @see     AlfredBundlerLogger::logFile
   * @see     AlfredBundlerLogger::logConsole
   *
   * @param   string  $message  message to be logged
   * @param   mixed   $level    log level to be recorded
   *
   * @since   Taurus 1
   *
   */
  private function report( $message, $level ) {

    // These are the appropriate log levels
    $logLevels = array( 0 => 'DEBUG',
      1 => 'INFO',
      2 => 'WARNING',
      3 => 'ERROR',
      4 => 'CRITICAL',
    );

    $date = date( 'H:i:s', time() );
    file_put_contents( 'php://stderr', "[{$date}] [{$level}] {$message}" . PHP_EOL );

  }

  /**
   * Passes calls to the internal object
   *
   * Wrapper function that passes all other calls to the internal object when
   * the method has not been found in this class
   *
   * @param string $method Name of method
   * @param array $args   An array of args passed
   * @return mixed          Whatever the internal function sends back
   *
   * @since  Taurus 1
   */
  public function __call( $method, $args ) {

    // Make sure that the bundler installation was not refused
    if ( isset( $_ENV[ 'ALFRED_BUNDLER_INSTALL_REFUSED'] ) ) {
      $bt = array_unshift( debug_backtrace() );
      $date = date( 'H:i:s' );
      $trace = basename( $bt[ 'file' ] ) . ':' . $bt[ 'line' ];
      $message = "Trying to call an Alfred Bundler method ({$method}), but user refused to install the bundler.";
      $this->report( "[{$date}] [{$trace}] {$message}", 'CRITICAL' );
      return FALSE;
    }


    // Check to make sure that the method exists in the
    // 'AlfredBundlerInternalClass' class
    if ( ! method_exists( $this->bundler, $method ) ) {
      // Whoops. We called a non-existent method
      $this->report( "Could not find method [$method] in class 'AlfredBundler'.",
        'ERROR', __FILE__, __LINE__ );
      return FALSE;
    }

    // The method exists, so call it and return the output
    return call_user_func_array( array( $this->bundler, $method ), $args );
  }

  /**
   * Gets variables from the AlfredBundlerInternalClass
   *
   * @param   string  $name  name of variable to get
   * @return  mixed         the variable from the internal class object
   *
   * @access public
   * @since  Taurus 1
   */
  public function &__get( $name ) {
    if ( isset( $this->bundler ) && is_object( $this->bundler ) ) {
      if ( isset( $this->bundler->$name ) )
        return $this->bundler->$name;
    }
  }

/******************************************************************************
 *** Begin Installation Functions
 *****************************************************************************/

/**
 * Validates and checks variables for installation
 *
 * @return  bool returns false on failure
 * @since   Taurus 1
 */
private function prepareInstallation() {
  if ( ! file_exists( 'info.plist' ) ) {
    $this->report( "You need a valid `info.plist` to use the Alfred Bundler.", 'CRITICAL' );
    return FALSE;
  }
  if ( isset( $_ENV[ 'alfred_version' ] ) )
    $this->prepareModern();
  else
    $this->prepareDeprecated();

}

/**
 * Sets the name of the workflow
 * Method used for Alfredv2.4:277+
 *
 * @since Taurus 1
 */
private function prepareModern() {
  $this->name = $_ENV[ 'alfred_workflow_name' ];
}

/**
 * Sets the name of the workflow
 * This method is used only for version < Alfredv2.4:277
 *
 * @since Taurus 1
 */
private function prepareDeprecated() {
  $this->name = exec( "/usr/libexec/PlistBuddy -c 'Print :name' 'info.plist'" );
}

/**
 * Prepares the text for the installation confirmation AS dialog
 *
 * @since Taurus 1
 */
private function prepareASDialog() {

  if ( file_exists( 'icon.png' ) ) {
    $icon = realpath( 'icon.png' );
    $icon = str_replace('/', ':', 'icon');
    $icon = substr( $icon, 1, strlen( $icon ) - 1 );
  } else {
    $icon = "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:SideBarDownloadsFolder.icns";
  }
  // Text for the dialog message.
  $text = "{$this->name} needs to install additional components, which will be placed in the Alfred storage directory and will not interfere with your system.

You may be asked to allow some components to run, depending on your security settings.

You can decline this installation, but {$this->name} may not work without them. There will be a slight delay after accepting.";

  $this->script = "display dialog \"$text\" " .
    "buttons {\"More Info\",\"Cancel\",\"Proceed\"} default button 3 " .
    "with title \"{$this->name} Setup\" with icon file \"$icon\"";

}

/**
 * Executes AppleScript dialog confirmation and handles return value
 *
 * @todo decide and implement proper exit behavior for failure
 * @return  bool  confirmation / refusal to install the bundler
 *
 * @since Taurus 1
 */
private function processASDialog() {
  $info = "https://github.com/shawnrice/alfred-bundler/wiki/What-is-the-Alfred-Bundler";
  $confirm = str_replace( 'button returned:', '', exec( "osascript -e '{$this->script}'" ) );
  if ( $confirm == 'More Info' ) {
    exec( "open {$info}" );
    die(); // Stop the workflow. If it's a script filter, then this will happen anyway.
  } else if ( $confirm == 'Proceed' ) {
    return TRUE;
  } else {
    $this->report( "User canceled installation of Alfred Bundler. Unknown " .
      "and possibly catastrophic effects to follow.",
      'CRITICAL' );
    $_ENV[ 'ALFRED_BUNDLER_INSTALL_REFUSED' ] = TRUE;
    return FALSE;
  }
  return TRUE;
}

  /**
   * Makes the data and cache directories for the Bundler
   *
   * @TODO: add in error handling for failed permissions (should be _very_ rare)
   * @since  Taurus 1
   */
  private function prepareDirectories() {
    // Make the bundler cache directory
    if ( ! file_exists( $this->_cache ) )
      mkdir( $this->_cache, 0755, TRUE );
    // Make the bundler data directory
    if ( ! file_exists( $this->_data ) )
      mkdir( $this->_data, 0755, TRUE );
  }

  private function userCanceledInstallation() {
    throw new Exception('The user canceled the installation of the Alfred Bundler.');
  }

  /**
   * Installs the Alfred Bundler
   *
   * @return bool Success or failure of installation
   *
   * @since  Taurus 1
   */
  private function installBundler() {

    $this->prepareInstallation();
    $this->prepareASDialog();

    if ( ! $this->processASDialog() ) {
      $this->userCanceledInstallation(); // Throw an exception.
      return FALSE;
    }
    $this->prepareDirectories();

    // This is a list of mirrors that host the bundler. A current list is in
    // bundler/meta/bundler_servers, but that file should not exist on the
    // machine -- yet -- because this is the function that installs that file.
    // The 'latest' tag is the current release.
    $suffix = "-latest.zip";
    if ( isset( $_ENV[ 'AB_BRANCH' ] ) &&
      ( ! empty( $_ENV[ 'AB_BRANCH' ] ) ) ) {
      $suffix = ".zip";
    }
    $bundler_servers = array(
      "https://github.com/shawnrice/alfred-bundler/archive/{$this->_major_version}{$suffix}",
      "https://bitbucket.org/shawnrice/alfred-bundler/get/{$this->_major_version}{$suffix}"
    );

    // Cycle through the servers until we find one that is up.
    foreach ( $bundler_servers as $server ) :
      $success = $this->dl( $server, "{$this->_cache}/bundler.zip" );
      if ( $success === TRUE ) {
        $this->report( "Downloaded Bundler Installation from... {$server}", 'INFO' );
        break; // We found one, so break
      }
    endforeach;

    // If success is true, then we downloaded a copy of the bundler
    if ( $success !== TRUE ) {
      $this->report( "Could not reach server to install Alfred Bundler.", 'CRITICAL' );
      unlink( "{$this->_cache}/bundler.zip" );
      return FALSE;
    }

    // Unzip the bundler archive
    $zip = new ZipArchive;
    $resource = $zip->open( "{$this->_cache}/bundler.zip" );
    if ( $resource !== TRUE ) {
      $this->report( "Bundler install zip file corrupt.", 'CRITICAL' );
      if ( file_exists( "{$this->_cache}/bundler.zip" ) ) {
        unlink( "{$this->_cache}/bundler.zip" );
      }
      return FALSE;
    } else {
      $zip->extractTo( "{$this->_cache}" );
      $zip->close();
    }

    if ( file_exists( "{$this->_data}/bundler" ) ) {
      $this->report( "Bundler already installed. Exiting install script.", 'WARNING' );
      return FALSE; // Add in error reporting
    }

    // Move the bundler into place
    $directoryHandle = opendir( $this->_cache );
    while ( FALSE !== ( $file = readdir( $directoryHandle ) ) ) {
        if ( is_dir( "{$this->_cache}/{$file}" ) && (strpos( $file, "alfred-bundler-" ) === 0 ) ) {
          $bundlerFolder = "{$this->_cache}/{$file}";
          closedir( $directoryHandle );
          break;
        }
    }

    if ( ( ! isset( $bundlerFolder ) ) || ( empty( $bundlerFolder ) ) ) {
      $this->report( "Could not find Alfred Bundler folder in installation zip.", 'CRITICAL' );
      return FALSE;
    }

    rename( "{$bundlerFolder}/bundler", "{$this->_data}/bundler" );

    $this->report( 'Alfred Bundler successfully installed, cleaning up...', 'INFO');
    unlink( "{$this->_cache}/bundler.zip" );
    // We'll do a cheat here to remove the leftover installation files
    exec( "rm -fR '{$bundlerFolder}'" );
    return TRUE; // The bundler should be in place now
  }

  /**
   * Wraps a cURL function to download files
   *
   * This method should be used only by the bundlet to download the
   * bundler from the server
   *
   * @param string $url     A URL to the file
   * @param string $file    The destination file
   * @param int    $timeout = '5' A timeout variable (in seconds)
   * @return bool            True on success and error code / false on failure
   *
   * @since  Taurus 1
   */
  private function dl( $url, $file, $timeout = '5' ) {
    // Check the URL here

    // Make sure that the download directory exists
    if ( ! file_exists( realpath( dirname( $file ) ) ) ) {
      $this->report( "Bundler install directory could not be created.", 'CRITICAL' );
      return FALSE;
    }

    // Create the cURL object
    $ch = curl_init( $url );
    // Open the file that we'll write to
    $fp = fopen( $file , "w" );

    // Set standard cURL options
    curl_setopt_array( $ch, array(
        CURLOPT_FILE => $fp,
        CURLOPT_HEADER => FALSE,
        CURLOPT_FOLLOWLOCATION => TRUE,
        CURLOPT_CONNECTTIMEOUT => $timeout
      ) );


    // Execute the cURL request and check for errors
    if ( curl_exec( $ch ) === FALSE ) {
      // We've run into an error, so, let's handle the error as best as possible
      // Close the connection
      curl_close( $ch );
      // Close the file
      fclose( $fp );

      // If the file has been written (partially), then delete it
      if ( file_exists( $file ) )
        unlink( $file );

      // Return the cURL error
      // Curl error codes: http://curl.haxx.se/libcurl/c/libcurl-errors.html
      return curl_error( $ch ) ;
    }

    // File downloaded without error, so close the connection
    curl_close( $ch );
    // Close the file
    fclose( $fp );

    // Return success
    return TRUE;
  }

/******************************************************************************
 *** End Installation Functions
 *****************************************************************************/

}


// Update logic for the bundler
// ----------------------------
// Unfortunately, Apple doesn't let us have the pcntl functions natively, so
// we'll take a different route and spoof this sort of thing. Here is a not
// very well developed implementation of forking the update process.
//
// if ( ! function_exists('pcntl_fork') )
//   die('PCNTL functions not available on this PHP installation');
// else {
//   $pid = pcntl_fork();
//
//   switch($pid) {
//       case -1:
//           print "Could not fork!\n";
//           exit;
//       case 0:
//           // Check for bundler minor update
//           $cmd = "sh '$__data/bundler/meta/update.sh' > /dev/null 2>&1";
//           exec( $cmd );
//           break;
//       default:
//           print "In parent!\n";
//   }
// }