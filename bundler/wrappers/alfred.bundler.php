<?php

/**
 * PHP Wrapper for the Alfred Bundler
 *
 * Main PHP interface for the Alfred Dependency Bundler. This file should be
 * the only one from the bundler that is distributed with your workflow. You can
 * use this file and the class contained within it to lazy load a variety of
 * assets that can be used in your workflows.
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
 * The PHP interface for the Alfred Bundler
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
   * Filepath to an Alfred info.plist file
   *
   * @access private
   * @var string
   */
  private   $plist;

  /**
   * The class constructor
   *
   * @param {string} $plist = FALSE   Optional path to info.plist (usually for testing purposes)
   * @return {bool}                    Returns successful / unsuccessful instantiation
   */
  public function __construct( $plist = FALSE ) {
    // Added plist variable for testing purposes

    if ( isset( $ENV[ 'ALFRED_BUNDLER_DEVEL' ] ) && ( ! empty( $ENV[ 'ALFRED_BUNDLER_DEVEL' ] ) ) ) {
      $this->major_version = $ENV[ 'ALFRED_BUNDLER_DEVEL' ];
    } else {
      $this->major_version = 'devel';
    }

    $this->data  = "{$_SERVER['HOME']}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}";
    $this->cache = "{$_SERVER['HOME']}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}";

    // Have a fallback on this one
    if ( $plist === FALSE ) {
      if ( file_exists( 'info.plist' ) ) {
        $this->plist = 'info.plist';
      } else if ( file_exists( '../info.plist' ) ) {
          $this->plist = '../info.plist';
        } else {
        $this->plist = '';
      }
    } else {
      $this->plist = "$plist";
    }

    if ( file_exists( "{$this->data}/bundler/AlfredBundler.php" ) ) {
      require_once __DIR__ . '/../AlfredBundler.php';
      //    For development purposes
      //    require_once( "{$this->data}/bundler/AlfredBundler.php" );
      $this->bundler = new AlfredBundlerInternalClass( $this->plist );
    } else {
      if ( $this->install_bundler( $plist ) === FALSE ) {
        // The bundler could not install itself, so return false
        return FALSE;
      }
    }

    // Call the wrapper to update itself, this will fork the process to make sure
    // that we do not need to wait and slow down results.
    exec( "bash '{$this->data}/bundler/meta/update-wrapper.sh'" );

    return TRUE;
  }

  // this might need to go somewhere else...
  public function report( $message, $level, $file, $line ) {

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
   * Installs the Alfred Bundler
   *
   * @return {bool} Success or failure of installation
   *
   * @access private
   * @since  Taurus 1
   */
  private function install_bundler( $plist ) {

    // Should we put in an AS dialog confirming this?
    if ( file_exists( $plist ) )
      $name = "[" . exec( "/usr/libexec/PlistBuddy -c 'Print :name' '{$plist}'" ) . "]";
    else
      $name = "A workflow that you just invoked";

    $script = "display dialog \"{%Workflow Name%} needs to install the Alfred Bundler in order to function.\" buttons {\"More Info\",\"Stop\",\"Proceed\"} default button 3 with title \"Alfred Bundler\" with icon Note";
    $script = str_replace( '{%Workflow Name%}', $name, $script );
    $confirm = str_replace( 'button returned:', '', exec( "osascript -e '$script'" ) );
    if ( $confirm == 'More Info' ) {
      exec( "open http://shawnrice.github.io/alfred-bundler" );
      die();
    }
    if ( $confirm == 'Stop' ) {
      $line = __LINE__;
      $this->report( "User canceled installation of Alfred Bundler. Unknown and possibly catastrophic effects to follow.", 'CRITICAL', __FILE__, $line );
      return FALSE;
    }
    // Make the bundler cache directory
    if ( ! file_exists( $this->cache ) )
      mkdir( $this->cache, 0755, TRUE );
    // Make the bundler data directory
    if ( ! file_exists( $this->data ) )
      mkdir( $this->data, 0755, TRUE );

    // This is a list of mirrors that host the bundler. A current list is in
    // bundler/meta/bundler_servers, but that file should not exist on the
    // machine -- yet -- because this is the function that installs that file.
    // The 'latest' tag is the current release.
    $suffix = "-latest.zip";
    if ( isset( $ENV[ 'ALFRED_BUNDLER_DEVEL' ] ) && ( ! empty( $ENV[ 'ALFRED_BUNDLER_DEVEL' ] ) ) ) {
      $suffix = ".zip";
    }
    $bundler_servers = array(
      "https://github.com/shawnrice/alfred-bundler/archive/{$this->major_version}{$suffix}",
      "https://bitbucket.org/shawnrice/alfred-bundler/get/{$this->major_version}{$suffix}"
    );

    // Cycle through the servers until we find one that is up.
    foreach ( $bundler_servers as $server ) :
      $success = $this->download( $server, "{$this->cache}/bundler.zip" );
    if ( $success === TRUE )
      break; // We found one, so break
    endforeach;

    // If success is true, then we downloaded a copy of the bundler
    if ( $success !== TRUE ) { $line = __LINE__;
      $this->report( "Could not reach server to download and install Alfred Bundler.", 'CRITICAL', __FILE__, $line );
      unlink( "{$this->cache}/bundler.zip" );
      return FALSE; // Add in error reporting
    }

    // Unzip the bundler archive
    $zip = new ZipArchive;
    $resource = $zip->open( "{$this->cache}/bundler.zip" );
    if ( $resource !== TRUE ) { $line = __LINE__;
      $this->report( "Bundler installation zip file corrupt.", 'CRITICAL', __FILE__, $line );
      if ( file_exists( "{$this->cache}/bundler.zip" ) ) {
        unlink( "{$this->cache}/bundler.zip" );
      }
      return FALSE; // Add in error reporting
    } else {
      $zip->extractTo( "{$this->cache}" );
      $zip->close();
    }

    if ( file_exists( "{$this->data}/bundler" ) ) { $line = __LINE__;
      $this->report( "Bundler already installed. Exiting install script.", 'WARNING', __FILE__, $line );
      return FALSE; // Add in error reporting
    }

    // Move the bundler into place
    // Bitbucket will call this folder something else... dammit.
    // @TODO -- fix for filenames from places other than github
    rename( "{$this->cache}/alfred-bundler-{$this->major_version}-latest/bundler",
      "{$this->data}/bundler" );

    // The bundler is now in place, so require the actual PHP Bundler file
    require_once "{$this->data}/bundler/AlfredBundler.php";

    // The 'AlfredBundler' class is a small wrapper of a class. All the calls
    // send to an 'AlfredBundler' object that do not fit are passed to an
    // 'AlfredBundlerInternalClass' object that does all the heavy lifting.
    $this->bundler = new AlfredBundlerInternalClass( $this->plist );

    $this->report( "Alfred Bundler successfully installed, cleaning up...", 'INFO', __FILE__, __LINE__ );
    unlink( "{$this->cache}/bundler.zip" );
    $this->rrmdir( "{$this->cache}/alfred-bundler-{$this->major_version}-latest" );
    return TRUE; // The bundler should be in place now
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

  /**
   * Passes calls to the internal object
   *
   * Wrapper function that passes all other calls to the internal object when
   * the method has not been found in this class
   *
   * @param {string} $method Name of method
   * @param {array} $args   An array of args passed
   * @return {mixed}          Whatever the internal function sends back
   *
   * @access public
   * @since  Taurus 1
   */
  public function __call( $method, $args ) {
    // Check to make sure that the method exists in the
    // 'AlfredBundlerInternalClass' class
    if ( ! method_exists( $this->bundler, $method ) ) {
      // Whoops. We called a non-existent method
      throw new Exception( "unknown method [$method]" );
    }

    // The method exists, so call it and return the output
    return call_user_func_array( array( $this->bundler, $method ), $args );
  }
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

/*******************************************************************************
 * BEGIN TESTING CODE
 *******************************************************************************/

if ( strpos( $argv[0], basename( __FILE__ ) ) !== FALSE ) {

  $bundler = new AlfredBundler;

  // Icon test
  echo $bundler->icon( 'align-center', 'fontawesome', 'acc321', TRUE ); echo PHP_EOL;
  echo $bundler->icon( 'align-center', 'fontawesome', 'acc321', 'ffffff' );  echo PHP_EOL;

  // Composer Test -- This will not work unless a Bundle ID is present
  $success = $bundler->composer( array(
    "monolog/monolog" => "1.10.*@dev"
  ));

  // Utility Test
  $bundler->utility( 'CocoaDialog' );
  // Library Test
  $bundler->library( 'Workflows' );

}

/*******************************************************************************
 * END TESTING CODE
 *******************************************************************************/

/*******************************************************************************
 * INTERNAL DOCUMENTATION
 *
 * See https://shawnrice.github.io/alfred-bundler for more detailed and current
 * documentation.
 *
 * The Alfred Bundler allows you to lazy load assets. In other words, you do not
 * need to bundle any dependencies with your workflows. Other wrappers for
 * the bundler are available in Bash, Python, and Ruby. There is a simple bundler
 * wrapper that allows any other language to load assets via a Bash script.
 *
 * Assets available:
 *   -- PHP Libraries
 *   -- Utilties (programs)
 *   -- Composer (Packagist) packages
 *   -- Icons
 *
 * Available Methods
 *
 * load:     loads a generic asset
 * library:  loads a PHP library
 * utility:  loads a utility
 * composer: loads any composer packages
 * notify:   sends a notification
 * icon:     loads an icon
 *
 * Examples:
 * $bundle = new AlfredBundler();
 *
 * Load David Ferguson's 'Workflows' Library:
 * $bundle->library( 'Workflows' );
 *
 * Load a PHP library from a custom JSON file:
 * $bundle->library( 'A Custom Library', 'default', '/path/to/custom/json.json' );
 *
 * Load Terminal Notifier through the generic "load" method:
 * $terminalNotifierPath = $bundle->load( 'Terminal-Notifer', '1.5.0', 'utility' );
 * exec("'$terminalNotifierPath' -title 'Title' -message 'Message'");
 *
 * Load the default version of Pashua:
 * $pashuaPath = $bundle->utility( 'Pashua' );
 *
 * Send a notification:
 * $bundle->notify( 'Example Notification', 'This is an example notification.', array( 'sender' => 'Alfred2' ) );
 *
 * Load a 'white' 'fire' icon from the 'elusive' icon font:
 * $icon = $bundle->icon( 'fire', 'elusive', 'ffffff' );

 * Load a 'white' 'fire' icon from the 'elusive' icon font, and fallback to black if the theme is light:
 * $icon = $bundle->icon( 'fire', 'elusive', 'ffffff', '000000' );
 *
 * Load a 'white' 'fire' icon from the 'elusive' icon font, and automatically adjust the icon color if the theme is light:
 * $icon = $bundle->icon( 'fire', 'elusive', 'ffffff', TRUE );
 *
 ******************************************************************************/
