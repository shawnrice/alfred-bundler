<?php

/**
 * PHP API for interacting with OSX dialog spawner Terminal Notifier.
 * 
 * Terminal Notifier is a resource which allows the user to spawn MacOSX notifications
 * from the command-line. Notifications return nothing.
 * 
 * Official Documentation {@link https://github.com/alloy/terminal-notifier}
 * LICENSE: GPLv3 {@link https://www.gnu.org/licenses/gpl-3.0.txt}
 *
 * -> Usage
 * ===========================================================================
 *
 * To include this api in your PHP scripts, copy this ``terminalnotifier.php`` 
 * to a viable place for you to include.
 *
 * Build the Terminal Notifier client:
 *
 *     include('terminalnotifier');
 *     $client = new TerminalNotifier('path to terminal-notifier.app or exec', $debug=Boolean)
 *     
 * Now that you have access to the client, you can call specific dialogs:
 *
 *     $my_notification = $client.notify([
 *         'title'=>'My Notification',
 *         'subtitle'=>'Hello, World!',
 *         'message'=>'Have a nice day!',
 *         'sender'=>'com.apple.Finder']);
 * 
 * **NOTE**: The included `debug` parameter is very useful for finding out why
 * your specified parameters are not being shown, or why your parameters are not
 * passing as valid parameters, and thus the dialog is not being spawned.
 *
 * -> Revisions
 * ============================================================================
 * 1.0, 07-28-14: Initial release
 * 
 * @copyright  Ritashugisha 2014
 * @license    https://www.gnu.org/licenses/gpl-3.0.txt  GPL v3
 * @version    1.0
 */

$AUTHOR = 'Ritashugisha <ritashugisha@gmail.com>';
$DATE = '07-28-14';
$VERSION = 1.0;


/**
 * Main class used for interaction with Terminal Notifier.
 *
 * Public class used to initialize the Terminal Notifier interaction client.
 * Client inintialization is built by:
 *
 *     $client = new TerminalNotifier('path to terminal-notifier.app or exec', $debug=bool)
 *
 * Initializes valid and required options.
 */
class TerminalNotifier {

    /**
     * Reference to Terminal Notifier exec
     *
     * @access private
     * @var string
     */
    private $notifier;

    /**
     * Toggle for log output
     *
     * @access private
     * @var boolean
     */
    private $debug;

    /**
     * Associative array of valid notification options
     *
     * @access private
     * @var array
     */
    private $valid_options;

    /**
     * Array of required notification options
     *
     * @access private
     * @var array
     */
    private $required_options;

    /**
     * This function prints debug logs to the console.
     * 
     * @param string $level Logging level (adapted from Python's logging module)
     * @param string $funct Calling function's name
     * @param integer $lineno Calling functions line number
     * @param string $message Desired message
     */
    function log( $level, $funct, $lineno, $message ) {
        if ( $this->debug ) {
            echo sprintf( "[%-8s] <%s:%d>....%s\xA", strtoupper( $level ), $funct, $lineno, $message );
        }
    }

    /**
     * TerminalNotifier class constructor.
     * 
     * @access public
     * @param string $notifier Path to either terminal-notifier.app or exec
     * @param boolean $debug True if logging is enabled
     */
    public function __construct( $notifier, $debug=False ) {
        $this->notifier = $notifier;
        $this->debug = $debug;
        if ( file_exists( $this->notifier ) ) {
            if ( 'app' === strtolower( pathinfo( $notifier, PATHINFO_EXTENSION ) ) ) {
                $this->notifier = '/' . join( '/', array( trim( $notifier, '/' ), 
                    trim( '/Contents/MacOS/terminal-notifier', '/' ) ) );
                $valid_notifier = file_exists( $this->notifier );
            }
            else {
                $valid_notifier = ( strtolower( basename( $this->notifier ) ) === 'terminal-notifier' );
            }
        }
        else {
            $valid_notifier = False;
        }
        if ( ! $valid_notifier ) {
            $this->log( 'critical', __FUNCTION__, __LINE__, 
                sprintf( 'invalid path to terminal-notifier (%s)', $this->notifier ) );
            die();
        }
        $this->valid_options = [
            'message' => ['string'],
            'title' => ['string'],
            'subtitle' => ['string'],
            'sound' => ['string'],
            'group' => ['string'],
            'remove' => ['string'],
            'activate' => ['string'],
            'sender' => ['string'],
            'appIcon' => ['string'],
            'contentImage' => ['string'],
            'open' => ['string'],
            'execute' => ['string']
        ];
        $this->required_options = ['message'];
    }

    /**
     * Run a process on the host system.
     * 
     * @param string $process Process to be run
     * @return string Output of process
     */
    public function _run_subprocess( $process ) {
        // Preferrably, we should send a string rather than a list in PHP
        if ( gettype( $process ) === 'array' ) {
            $process = join( ' ', $process );
        }
        return shell_exec( $process );
    }

    /**
     * Validate and clean up passed notification options.
     * 
     * @param array $passed Associative array of passed dialog arguemnts
     */
    public function _valid_options( $passed ) {
        $_is_valid = True;

        // First we validate that all $passed options are valid options and \
        // are the coresponding valid type
        foreach ( array_keys( $passed ) as $passed_key ) {
            if ( in_array( $passed_key, array_keys( $this->valid_options ) ) ) {
                if ( ! in_array( gettype( $passed[$passed_key] ), $this->valid_options[$passed_key] ) ) {
                    $this->log( 'warning', __FUNCTION__, __LINE__, 
                        sprintf( 'removing (%s) invalid type, expected (%s), got (%s)',
                        $passed_key,
                        implode( ' or ', array_values( $this->valid_options[$passed_key] ) ),
                        gettype( $passed[$passed_key] ) ) );
                    unset( $passed[$passed_key] );
                }
            }
            else {
                $this->log( 'warning', __FUNCTION__, __LINE__, 
                    sprintf( 'removing (%s) invalid parameter, available are (%s)',
                        $passed_key,
                        implode( ', ', array_keys( $this->valid_options ) ) ) );
                unset( $passed[$passed_key] );
            }
        }

        // Next we can check that the $passed options contain the required \
        // options
        foreach ( $this->required_options as $required_key ) {
            if ( ! in_array( $required_key, array_keys( $passed ) ) ) {
                $this->log( 'error', __FUNCTION__, __LINE__,
                    sprintf( 'missing required parameter (%s)', $required_key ) );
                $_is_valid = False;
            }
        }

        // If the remove option is given, then we sould remove all other \
        // options in order to allow room for notification removal to occur.
        if ( in_array( 'remove', array_keys( $passed ) ) ) {
            $_is_valid = True;
            foreach ( array_keys( $passed ) as $k ) {
                if ( substr( $k, 0, 6 ) !== 'remove' ) {
                    unset( $passed[$k] );
                }
            }
        }

        // PHP is stupid, that's why we have to remember and return the formated passed
        // arguments back to our notification
        return [$_is_valid, $passed];
    }

     /**
     * Display the passed notification after some crutial formatting.
     * 
     * @param array $passed Associative array of passed dialog options
     */
    public function _display( $passed ) {
        $process = ["'$this->notifier'"];
        foreach ( $passed as $k => $v ) {
            array_push( $process, sprintf( '-%s', $k ) );
            // It is important we escape the first character of every value
            // passed. This is a known bug in TN.
            array_push( $process, sprintf( '"\\%s"', $v ) );
        }
        try {
            $this->log('info', __FUNCTION__, __LINE__, implode( ' ', $process ) );
            $this->_run_subprocess( implode( ' ', $process ) );
        } catch (Exception $e) {
            $this->log('critical', __FUNCTION__, __LINE__, $e );
        }
    } 

    /**
     * Spawn a notification with passed arguments
     * 
     * @param array $_passed Associative array of notification arguments
     */
    public function notify( array $_passed ) {
        $_valid = $this->_valid_options( $_passed );
        if ( $_valid[0] ) {
            $this->_display( $_valid[1] );
        }
    }
}
