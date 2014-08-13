<?php

/**
 * Alfred Bundler Logging Fiel
 *
 * Generic interface for logging to files and the console to be used with the
 * PHP implementation of the Alfred Bundler.
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
 * @see       AlfredBundlerInternalClass::debug
 * @see       AlfredBundlerInternalClass::info
 * @see       AlfredBundlerInternalClass::warning
 * @see       AlfredBundlerInternalClass::error
 * @see       AlfredBundlerInternalClass::critical
 * @see       AlfredBundlerInternalClass::console
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
   * Default destination to send a log message to
   *
   * @var  string   options: file, console, both
   */
  private $defaultDestination;

  /**
   * Sets variables and ini settings to ensure there are no errors
   *
   * @param  string  $log                   filename to use as a log
   * @param  string  $destination = 'file'  default destination for messages
   * @since Taurus 1
   */
  public function __construct( $log, $destination = 'file' ) {

    $this->log = $log . '.log';
    $this->initializeLog();

    if ( ! in_array( $destination, [ 'file', 'console', 'both' ] ) )
      $this->defaultDestination = 'file';
    else
      $this->defaultDestination = $destination;

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
   *                                valid options: 'file', 'console', 'both'
   * @since Taurus 1
   */
  public function log( $message, $level = 'INFO', $destination = '', $trace = 0 ) {

    // Set the destination to the default if not implied
    if ( empty( $destination ) )
      $destination = $this->defaultDestination;

    // print_r( debug_backtrace() );

    // Get the relevant information from the backtrace
    $this->trace = debug_backtrace();
    $this->trace = $this->trace[ $trace ];
    $this->file  = basename( $this->trace[ 'file' ] );
    $this->line  = $this->trace[ 'line' ];

    // check / normalize the arguments
    $this->level = $this->normalizeLogLevel( $level );
    $destination = strtolower( $destination );

    if ( $destination == 'file' || $destination == 'both' )
      $this->logFile( $message );
    if ( $destination == 'console' || $destination == 'both' )
      $this->logConsole( $message );

  }

  /**
   * Creates log directory and file if necessary
   * @since Taurus 1
   */
  private function initializeLog() {
    if ( ! file_exists( $this->log ) ) {
      if ( ! is_dir( realpath( dirname( $this->log ) ) ) )
        mkdir( dirname( $this->log ), 0775, TRUE );
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