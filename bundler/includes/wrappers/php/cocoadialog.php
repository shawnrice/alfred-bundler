<?php

/**
 * PHP API for interacting with OSX dialog spawner CocoaDialog.
 *
 * CocoaDialog is a resource which allows the user to spawn MacOSX aqua dialogs
 * from the command-line. Dialogs are predefined and return input via echo.
 *
 * Official Documentation {@link http://mstratman.github.io/cocoadialog/}
 * LICENSE: GPLv3 {@link https://www.gnu.org/licenses/gpl-3.0.txt}
 *
 * -> Usage
 * ===========================================================================
 *
 * To include this api in your PHP scripts, copy this ``cocoadialog.php`` to
 * a viable place for you to include.
 *
 * Build the CocoaDialog client:
 *
 *     include('cocoadialog');
 *     $client = new CocoaDialog('path to CocoaDialog.app or exec', $debug=Boolean);
 *
 * Now that you have access to the client, you can call specific dialogs:
 *
 *     $my_message_box = $client->msgbox([
 *         'title'=>'My Message Box',
 *         'text'=>'Hello, World!',
 *         'button1'=>'Ok', 'button2'=>'Cancel',
 *         'informative_text'=>'Your information here...',
 *         'icon'=>'home',
 *         'string_output'=>True]);
 *
 *     echo $my_message_box;
 *
 * If the user clicks on the "Ok" button, my_message_box will return ["Ok"]
 * in this script. If, however, the user presses "Cancel", ["Cancel"] will
 * be returned.
 *
 * **NOTE**: The included `debug` parameter is very useful for finding out why
 * your specified parameters are not being shown, or why your parameters are not
 * passing as valid parameters, and thus the dialog is not being spawned.
 *
 * All other dialogs are spawned via similar treatment as shown above.
 * For more info on what parameters are available for a specifc dialog, please
 * visit the `Official Documentation` or play with `debug=True` for a while.
 *
 * To create a progress bar dialog, you have to create a new instance for the
 * progress bar object.
 *
 *     $my_progress_bar = new ProgressBar(
 *         $client,
 *         ['title'=>'My Progress Bar',
 *          'text'=>'Hello, World!',
 *          'percent'=>0,
 *          'icon'=>'info']);
 *
 *     foreach (range(0, 100) as $i) {
 *         $my_progress_bar->update($percent=$i);
 *         time_nanosleep(0, 100000000);
 *     }
 *
 * Whenever the progress bar reaches an EOF, the dialog with kill itself.
 *
 * If you plan to add the `stoppable` feature in your progress bar, you will need
 * to format your loop a little differently.
 *
 *     $my_progress_bar = new ProgressBar(
 *         $client,
 *         ['title'=>'My Progress Bar',
 *          'text'=>'Hello, World!',
 *          'percent'=>0,
 *          'icon'=>'info']);
 *
 *     foreach (range(0, 100) as $i) {
 *         time_nanosleep(0, 100000000);
 *         if ($my_progress_bar->update($percent=$i) == 0) {
 *             break;
 *         }
 *     }
 *
 * The `update` function, returns 1 to signify it is running. When the user stops
 * the progress bar, the `finish` function is called and returns 0 instead.
 *
 *
 * -> Revisions
 * ============================================================================
 * 1.0, 07-28-14: Initial release for (3.0, 0, 'beta')
 *
 * @copyright  Ritashugisha 2014
 * @license    https://www.gnu.org/licenses/gpl-3.0.txt  GPL v3
 * @version    1.0
 */

$AUTHOR = 'Ritashugisha <ritashugisha@gmail.com>';
$DATE = '07-28-14';
$VERSION = 1.0;
$COCOA_VERSION = [3.0, 0, 'beta'];


/**
 * Main class used for interaction with CocoaDialog.
 *
 * Public class used to initialize the CocoaDialog interaction client.
 * Client inintialization is built by:
 *
 *     $client = new CocoaDialog('path to CocoaDailog.app or exec', $debug=bool)
 *
 * Initializes global options (dict) and global icons (list).
 */
class CocoaDialog {

    /**
     * Reference to the CocoaDialog exec.
     * @access private
     * @var string
     */
    private $cocoa;

    /**
     * Switch used for logging to the console.
     * @access private
     * @var boolean
     */
    private $debug;

    /**
     * Reference to a list of global options.
     * @access private
     * @var array
     */
    private $global_options;

    /**
     * Reference to a list of exceptions for key_name lowercase-ing.
     * @access private
     * @var array
     */
    private $lower_exceptions;

    /**
     * Reference to a list of global icons.
     * @access private
     * @var array
     */
    private $global_icons;

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
     * CocoaDialog class constructor.
     *
     * @access public
     * @param string $cocoa Path to either CocoaDialog.app or exec
     * @param boolean $debug True if logging is enabled
     */
    public function __construct( $cocoa, $debug=False ) {
        $this->cocoa = $cocoa;
        $this->debug = $debug;
        if ( file_exists( $this->cocoa ) ) {
            if ( 'app' === strtolower( pathinfo( $cocoa, PATHINFO_EXTENSION ) ) ) {
                $this->cocoa = '/' . join( '/', array( trim( $cocoa, '/' ), trim( '/Contents/MacOS/cocoadialog', '/' ) ) );
                $valid_cocoa = file_exists( $this->cocoa );
            }
            else {
                $valid_cocoa = ( strtolower( basename( $this->cocoa ) ) === 'cocoadialog' );
            }
        }
        else {
            $valid_cocoa = False;
        }
        if ( ! $valid_cocoa ) {
            $this->log( 'critical', __FUNCTION__, __LINE__, sprintf( 'invalid path to cocoadialog (%s)', $this->cocoa ) );
            die();
        }
        $this->global_options = [
            'title' => ['string'],
            'string_output' => ['boolean'],
            'no_newline' => ['boolean'],
            'width' => ['integer', 'double'],
            'height' => ['integer', 'double'],
            'posX' => ['integer', 'double'],
            'posY' => ['integer', 'double'],
            'timeout' => ['integer', 'double'],
            'timeout_format' => ['string'],
            'icon' => ['string'],
            'icon_bundle' => ['string'],
            'icon_file' => ['string'],
            'icon_size' => ['integer'],
            'icon_height' => ['integer'],
            'icon_width' => ['integer'],
            'icon_type' => ['string'], // Broken option
            'debug' => ['boolean'],
            'help' => ['boolean']
        ];
        $this->lower_exceptions = ['posX', 'posY'];
        $this->global_icons = [
            'addressbook', 'airport', 'airport2', 'application', 'archive', 'bluetooth', 'bonjour', 'atom', 'burn', 'hazard', 'caution', 'cd',
            'cocoadialog', 'computer', 'dashboard', 'dock', 'document', 'documents', 'download', 'eject', 'everyone', 'executable',
            'favorite', 'heart', 'fileserver', 'filevault', 'finder', 'firewire', 'folder', 'folderopen', 'foldersmart', 'gear',
            'general', 'globe', 'group', 'help', 'home', 'info', 'installer', 'ipod', 'movie', 'music', 'network', 'notice', 'package',
            'preferences', 'printer', 'screenshare', 'search', 'find', 'security', 'sound', 'stop', 'x', 'sync', 'trash', 'trashfull',
            'update', 'url', 'usb', 'user', 'person', 'utilities', 'widget'
        ];
    }

    public function _format_passed( $passed ) {
        $new_passed = [];
        foreach ($passed as $k => $v) {
            if ( ! ( in_array( $k, $this->lower_exceptions ) ) ) {
                $new_passed[strtolower( $k )] = $v;
            }
            else {
                $new_passed[$k] = $v;
            }
        }
        return $new_passed;
    }

    public function _format_notify( $passed ) {

        // Cleanup for passed hexadecimal colors. CocoaDialog only accepts
        // numbers (xxx or xxxxxx), so just in case users get crazy, we will
        // regrex it.
        $valid_x_placement = ['center', 'left', 'right'];
        $valid_y_placement = ['center', 'top', 'bottom'];
        foreach (['text_color', 'border_color', 'background_top', 'background_bottom'] as $i) {
            if ( in_array( $i, array_keys( $passed ) ) ) {
                preg_match( "/^(.*?)(?P<hex>([0-9a-fA-F]{3}){1,2})$/", $passed[$i], $group );
                if ( $group['hex'] ) {
                    $passed[$i] = $group['hex'];
                }
                else {
                    $this->log('warning', __FUNCTION__, __LINE__,
                        sprintf('removing invalid (%s), got (%s), expected (#XXX or #XXXXXX)',
                            $i, $passed[$i]));
                    unset($passed[$i]);
                }
            }
        }

        // Cleanup/validation for x_placement and y_placement
        foreach ([['x_placement', $valid_x_placement], ['y_placement', $valid_y_placement]] as $i) {
            if ( in_array($i[0], array_keys( $passed ) ) && !( in_array( $passed[$i[0]], $i[1] ) ) ) {
                $this->log('warning', __FUNCTION__, __LINE__,
                    sprintf('removing invalid (%s), got (%s), expected (%s)',
                        $i[0], $passed[$i[0]], implode(' or ', $i[1])));
                unset($passed[$i[0]]);
            }
        }
        return $passed;
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
     * Validate and clean up passed dialog options.
     *
     * @param array $passed Associative array of passed dialog arguemnts
     * @param array $custom_options Associative array of calling dialog's unique arguments
     * @return boolean True if OK for dialog to be shown
     */
    public function _valid_options( $passed, $custom_options ) {

        $_is_valid = True;

        // Join the valid options with the global options into a single associative array
        // and grab the function name
        $valid_passed = array_merge( $custom_options['custom_options'], $this->global_options );
        $_funct = $custom_options['dialog_name'];

        // First, check that all passed options are valid and have a valid corresponding type.
        foreach ( array_keys( $passed ) as $passed_key ) {
            if ( in_array( $passed_key, array_keys( $valid_passed ) ) ) {
                if ( ! in_array( gettype( $passed[$passed_key] ), $valid_passed[$passed_key] ) ) {
                    $this->log( 'warning', __FUNCTION__, __LINE__,
                        sprintf( 'removing (%s) invalid type, expected (%s), got (%s)',
                            $passed_key,
                            implode( ' or ', array_values( $valid_passed[$passed_key] ) ),
                            gettype( $passed[$passed_key] ) ) );
                    unset( $passed[$passed_key] );
                }
            }
            else {
                $this->log( 'warning', __FUNCTION__, __LINE__,
                    sprintf( 'removing (%s) invalid parameter, available are (%s)',
                        $passed_key,
                        implode( ', ', array_keys( $valid_passed ) ) ) );
                unset( $passed[$passed_key] );
            }
        }

        // Next, check that passed options contain the required options.
        foreach ( $custom_options['required_options'] as $required_key ) {
            if ( in_array( $required_key, array_keys( $passed ) ) ) {
                foreach ( ['items', 'with_extensions', 'checked', 'disabled'] as $_lists ) {
                    if ( $_lists === strtolower( $required_key ) ) {
                       if ( count( $passed[$_lists] ) <= 0) {
                            $this->log('error', __FUNCTION__, __LINE__, 'length of items must be > 0');
                            $_is_valid = False;
                        }
                    }
                }
            }
            else {
                $this->log( 'error', __FUNCTION__, __LINE__,
                    sprintf( 'missing required parameter (%s)',
                        $required_key ) );
                $_is_valid = False;
            }
        }

        // Finally, check that (if icon is passed), it is a valid icon in CocoaDialog.
        if ( in_array( 'icon', array_keys( $passed ) ) ) {
            if ( ! in_array( $passed['icon'], $this->global_icons ) ) {
                $this->log( 'warning', __FUNCTION__, __LINE__,
                    sprintf( 'removing invalid icon (%s), available are (%s)',
                        $passed['icon'],
                        implode( ', ', $this->global_icons ) ) );
                unset( $passed['icon'] );
            }
        }

        // PHP is stupid, that's why we have to remember and return the formated passed
        // arguments back to our dialog
        return [$_is_valid, $passed];
    }

    /**
     * Display the passed dialog after some crutial formatting.
     *
     * @param string $funct Dialog name
     * @param array $passed Associative array of passed dialog options
     * @param boolean $return_process True if return process array instead of display
     * @return string Output of dialog
     */
    public function _display( $funct, $passed, $return_process=False ) {
        foreach ( $passed as $k => $v ) {
            $passed[sprintf( '--%s', str_replace( '_', '-', $k ) )] = $passed[$k];
            unset($passed[$k]);
        }
        $process = ["'$this->cocoa'", str_replace( '_', '-', $funct )];
        foreach ( $passed as $k => $v ) {
            if ( 'string' === gettype( $v ) || 'integer' === gettype( $v ) ||
                'float' === gettype( $v ) || ( 'array' === gettype( $v ) && count( $v ) > 0 ) ) {
                array_push( $process, $k );
                if ( 'array' === gettype( $v ) ) {
                    foreach ( $v as $i ) {
                        array_push( $process, sprintf( '"%s"', $i ) );
                    }
                }
                else {
                    array_push( $process, sprintf( '"%s"', strval( $v ) ) );
                }
            }
            else {
                if ( ( 'boolean' === gettype( $v ) ) && $v ) {
                    array_push( $process, $k );
                }
            }
        }
        if ( ! $return_process ) {
            try {
                $this->log('info', __FUNCTION__, __LINE__, implode( ' ', $process ) );
                $dialog = explode( "\n", $this->_run_subprocess( implode( ' ', $process ) ) );
                unset( $dialog[count($dialog) - 1] );
                return $dialog;
            } catch ( Exception $e ) {
                $this->log( 'critical', __FUNCTION__, __LINE__, $e );
            }
        }
        else {
            return $process;
        }
    }

    /**
     * Dialog type bubble
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/bubble_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function bubble(array $_passed) {
        $custom_options = [
            'no_timeout' => ['bool'],
            'alpha' => ['integer', 'double'],
            'x_placement' => ['string'],
            'y_placement' => ['string'],
            'text' => ['string'],
            'text_color' => ['string'],
            'border_color' => ['string'],
            'background_top' => ['string'],
            'background_bottom' => ['string']
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => ['title', 'text'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            $_valid[1] = $this->_format_passed( $_valid[1] );
            $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type notify
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function notify(array $_passed) {
        $custom_options = [
            'description' => ['string'],
            'sticky' => ['boolean'],
            'no_growl' => ['boolean'],
            'alpha' => ['integer', 'double'],
            'x_placement' => ['string'],
            'y_placement' => ['string'],
            'text_color' => ['string'],
            'border_color' => ['string'],
            'background_top' => ['string'],
            'background_bottom' => ['string'],
            'fh' => ['boolean'], // Unknown options
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => ['title', 'description'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            $_valid[1] = $this->_format_passed( $_valid[1] );
            $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type checkbox
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function checkbox(array $_passed) {
        $custom_options = [
            'label' => ['string'],
            'checked' => ['array'],
            'columns' => ['integer'],
            'rows' => ['integer'],
            'disabled' => ['array'],
            'items' => ['array'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => ['button1', 'items'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type radio
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function radio(array $_passed) {
        $custom_options = [
            'label' => ['string'],
            'selected' => ['integer'],
            'columns' => ['integer'],
            'rows' => ['integer'],
            'disabled' => ['array'],
            'items' => ['array'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => ['button1', 'items'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type slider
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function slider(array $_passed) {
        $custom_options = [
            'label' => ['string'],
            'always_show_value' => ['boolean'],
            'min' => ['integer', 'double'],
            'max' => ['integer', 'double'],
            'ticks' => ['integer', 'double'],
            'slider_label' => ['string'],
            'value' => ['integer', 'double'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
            'return_float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => ['button1', 'min', 'max'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type msgbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/msgbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function msgbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => ['button1'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type ok_msgbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/ok-msgbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function ok_msgbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type yesno_msgbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/yesno-msgbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function yesno_msgbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type inputbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/inputbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function inputbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
            'no_show' => ['boolean']
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type standard_inputbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/standard-box_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function standard_inputbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
            'no_show' => ['boolean']
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type secure_inputbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/secure-inputbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function secure_inputbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type secure_standard_inputbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/secure-standard-inputbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function secure_standard_inputbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'informative_text' => ['string'],
            'no_cancel' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type fileselect
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/fileselect_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function fileselect(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'select_directories' => ['boolean'],
            'select_only_directories' => ['boolean'],
            'packages_as_directories' => ['boolean'],
            'select_multiple' => ['boolean'],
            'with_extensions' => ['array'],
            'with_directory' => ['string'],
            'with_file' => ['string']
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type fileselect
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/fileselect_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function filesave(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'packages_as_directories' => ['boolean'],
            'no_create_directories' => ['boolean'],
            'with_extensions' => ['array'],
            'with_directory' => ['string'],
            'with_file' => ['string']
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type textbox
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/textbox_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function textbox(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'text_from_file' => ['string'],
            'informative_text' => ['string'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
            'editable' => ['boolean'],
            'focus_textbox' => ['boolean'],
            'selected' => ['boolean'],
            'scroll_to' => ['string'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type dropdown
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/dropdown_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function dropdown(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'items' => ['array'],
            'pulldown' => ['boolean'],
            'button1' => ['string'],
            'button2' => ['string'],
            'button3' => ['string'],
            'exit_onchange' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }

    /**
     * Dialog type standard_dropdown
     *
     * Valid parameters are listed at:
     * <http://mstratman.github.io/cocoadialog/#documentation3.0/standard-dropdown_control>
     *
     * @param array $_passed Dialog paramenters
     * @return string Output from dialog
     */
    public function standard_dropdown(array $_passed) {
        $custom_options = [
            'text' => ['string'],
            'items' => ['array'],
            'pulldown' => ['boolean'],
            'exit_onchange' => ['boolean'],
            'float' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => __FUNCTION__,
            'required_options' => [],
            'custom_options' => $custom_options
        ];
        $_passed = $this->_format_passed( $_passed );
        $_valid = $this->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            return $this->_display( __FUNCTION__, $_valid[1] );
        }
    }
}

/**
 * Seperate class used for interaction with CocoaDialog's progress bar.
 *
 * Client inintialization is built by:
 *
 *     $client = new ProgressBar('path to CocoaDialog.app or exec', [associative array of dialog arguements], $dialog=bool)
 *
 * NOTE: Currently broken due to CocoaDialog's exception thrown when opening process with stdin.
 * Possibly fixable.
 */
class ProgressBar {

    /**
     * Storage for CocoaDialog client
     *
     * @access private
     * @var CocoaDialog
     */
    private $cocoa;

    /**
     * Persistent storage for progress percent
     *
     * @access private
     * @var integer
     */
    private $percent;

    /**
     * Persistent storate for progress text
     *
     * @access private
     * @var string
     */
    private $text;

    /**
     * Persistent storage of read/write pipes
     *
     * @access private
     * @var IO
     */
    private $pipe;

    /**
     * Persistent storage of proc_open object
     *
     * @access private
     * @var proc_open
     */
    private $proc;

    /**
     * Progress class constructor.
     *
     * @param string $cocoa Path to CocoaDialog.app or exec
     * @param array $_passed Progress dialog arguemnts (associative array)
     * @param boolean $debug True if logging is enabled
     */
    public function __construct( $cocoa, array $_passed ) {
        $this->cocoa = $cocoa;
        if ( get_class($this->cocoa) != 'CocoaDialog' ) {
            echo sprintf( "[%-8s] <%s:%d>....%s\n",
                'CRITICAL', get_class($this), __LINE__, 'invalid cocoadialog client' );
            die();
        }
        $custom_options = [
            'text' => ['string'],
            'percent' => ['integer', 'double'],
            'indeterminate' => ['boolean'],
            'float' => ['boolean'],
            'stoppable' => ['boolean'],
        ];
        $custom_options = [
            'dialog_name' => get_class($this),
            'required_options' => ['percent', 'text'],
            'custom_options' => $custom_options
        ];
        $_passed = $this->cocoa->_format_passed( $_passed );
        $_valid = $this->cocoa->_valid_options( $_passed, $custom_options );
        if ( $_valid[0] ) {
            $this->percent = $_valid[1]['percent'];
            $this->text = $_valid[1]['text'];
            $process = implode( ' ', $this->cocoa->_display( strtolower( $custom_options['dialog_name'] ), $_valid[1], $return_process=True ) );
            $this->proc = proc_open( $process, [['pipe', 'r'], ['pipe', 'w']], $this->pipe );
            if ( is_resource( $this->proc ) ) {
                $this->pipe[1];
            }
        }
    }

    /**
     * Update the current progress bar's state.
     *
     * @param integer $percent Percentage filled of progress bar dialog
     * @param string $text Test of progress bar dialog
     * @return integer 1 if running 0 if stopped
     */
    public function update( $percent=NULL, $text=NULL ) {
        $this->percent = ( is_null( $percent ) ) ? $this->percent : $percent;
        $this->text = ( is_null( $text ) ) ? $this->text : $text;
        if ( is_resource( $this->proc ) && ( proc_get_status( $this->proc )['running'] ) ) {
            fwrite( $this->pipe[0], sprintf( "%s %s\n", $this->percent, $this->text ) );
            return 1;
        }
        else {
            return $this->finish();
        }
    }

    /**
     * Kill the progress bar dialog.
     *
     * @return integer 0 when killed
     */
    public function finish() {
        proc_terminate( $this->proc );
        return 0;
    }

}
