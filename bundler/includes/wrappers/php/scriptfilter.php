<?php

/**
 * ScriptFilter API for building Alfred ScriptFilter entries.
 *
 * Documentation {@link ?}
 * LICENSE: MIT {@link http://opensource.org/licenses/MIT}
 * Copyright 2014 The Alfred Bundler Team
 *
 * -> Usage
 * ===========================================================================
 *
 * To include this api in your PHP scripts, copy this ``scriptfilter.php`` to
 * a viable place for you to include.
 *
 * Build the ScriptFilter client:
 *
 *     include('scriptfilter');
 *     $_filter = new ScriptFilter($debug=Boolean);
 *
 * Now that you have access to the client, you can add entries to the filter:
 *
 *     $_filter->add([
 *         'title' => 'My Entry',
 *         'subtitle' => 'A subtitle for my entry',
 *         'arg' => 'My entry\'s argument',
 *         'adv_subtitle' => [
 *             'shift' => 'Subtitle when shift is pressed',
 *             'cmd' => 'Subtitle when cmd is pressed'
 *         ],
 *         'uid' => 'my custom uid',
 *         'icon' => 'path to your icon.png'
 *     ]);
 *
 * This will ensure that this entry will be rendered to XML (along with any
 * other entries that you add) that can be accepted by Alfred's ScriptFilter obj.
 * 
 * In order to obtain the XML, either print the filter name or grab the returned
 * value from the .to_s method.
 * 
 *     # Option 1
 *     puts my_filter
 *     
 *     # Option 2
 *     filter_output = my_filter.to_s
 *
 * 
 * -> Revisons
 * ============================================================================
 * 1.1, 10-14-14: Initial build for just script filter output
 *
 * @copyright  The Alfred Bundler Team
 * @license    http://opensource.org/licenses/MIT MIT
 * @version    1.0
 */

$AUTHOR = 'The Alfred Bundler Team';
$DATE = '10-15-14';
$VERSION = 1.0;


/**
 * Script Filter class used for building XML for a script filter object.
 *
 * Public class used to initialize the main items element and the entries list.
 * Script filter element is built by:
 *
 *      $_filter = $bundler->wrapper('scriptfilter');
 * 
 * Returns items XML (String)
 */
class ScriptFilter {

    /**
     * Switch used for allowing debug messages to be viewed.
     * @access private
     * @var boolean
     */
    private $debug;

    /**
     * Header used for XML string.
     * @access public
     * @var String
     */
    public $header;

    /**
     * List of items in the ScriptFilter.
     * @access public
     * @var Array
     */
    public $entries;

    /**
     * Items object, used to house the entries elements.
     * @access private
     * @var SimpleXMLElement
     */
    private $items;

    /**
     * ScriptFilter class constructor.
     *
     * @access public
     * @param boolean $debug True if logging is enabled
     */
    public function __construct( $debug=False ) {
        $this->debug = $debug;
        $this->header = '<?xml version="1.0" encoding="UTF-8"?>';
        $this->entries = [];
        $this->items = new SimpleXMLElement( '<items/>' );
    }

    /**
     * Method called whenever ScriptFilter object is printed.
     * 
     * @return string Built XML items object
     */
    public function __toString() {
        return $this->_build_xml();
    }

    /**
     * Builds the current XML entries.
     * 
     * @return string The built XML entries
     */ 
    private function _build_xml() {
        foreach( $this->entries as $i ) { $i->_build(); }
        $build = dom_import_simplexml( $this->items );
        return sprintf('%s%s', $this->header,
            $build->ownerDocument->saveXML(
                $build->ownerDocument->documentElement
            )
        );
    }

    /**
     * Adds an entry to the entries array.
     * 
     * @param Array $passed Associative array of desired parameters
     */
    public function add( $passed ) {
        $_new_entry = new Entry( $this->items, $this->debug );
        $_new_entry->_add( $passed );
        if ( $_new_entry != NULL ) {
            array_push( $this->entries, $_new_entry );
        }
    }

}


/**
 * The class used to build ScriptFilter entries.
 */
class Entry {

    /**
     * True if logging is enabled.
     *
     * @access private
     * @var boolean
     */
    private $debug;

    /**
     * Items XML object root.
     *
     * @access private
     * @var SimpleXMLElement
     */
    private $root;

    /**
     * Template reference $item.
     *
     * @access private
     * @var Array
     */
    private $entry_options;

    /**
     * List of required options for the entry to be built.
     *
     * @access private
     * @var Array
     */
    private $required_options;

    /**
     * Template advanced subtitle parameter.
     *
     * @access private
     * @var Array
     */
    private $_template_adv_subtitle;

    /**
     * Template advanced text parameter.
     *
     * @access private
     * @var Array
     */
    private $_template_adv_text;

    /**
     * Available entry types.
     *
     * @access private
     * @var Array
     */
    private $_available_type;

    /**
     * Available icon types.
     *
     * @access private
     * @var Array
     */
    private $_available_icon_type;

    /**
     * Item object for XML build.
     *
     * @access public
     * @var Array
     */
    public $item;

    function log( $level, $funct, $lineno, $message ) {
        if ( $this->debug ) {
            echo sprintf( "[%s] [%s:%d] [%s] %s\xA", date('Y-m-d h:i:s'), basename(__FILE__), $lineno, strtoupper( $level ), $message );
        }
    }

    /**
     * Entry constructor.
     * 
     * @param SimpleXMLElement $root Root element of items from filter object
     * @param boolean $debug True if logging is enabled
     */
    public function __construct( $root, $debug ) {
        if ( ! ini_get( 'date.timezone' ) ) {
            $tz = exec( 'tz=`ls -l /etc/localtime` && echo ${tz#*/zoneinfo/}' );
            ini_set( 'date.timezone', $tz );
        }
        $this->root = $root;
        $this->debug = $debug;
        $this->entry_options = [
            'title' => ['string'],
            'subtitle' => ['string'],
            'arg' => ['string'],
            'icon' => ['string'],
            'uid' => ['string'],
            'valid' => ['boolean'],
            'autocomplete' => ['string'],
            'type' => ['string'],
            'icon_type' => ['string'],
            'adv_subtitle' => ['array'],
            'adv_text' => ['array']
        ];
        $this->required_options = ['title'];
        $this->_template_adv_subtitle = [
            'shift' => NULL, 'fn' => NULL, 'ctrl' => NULL,
            'alt' => NULL, 'cmd' => NULL
        ];
        $this->_template_adv_text = ['copy' => NULL, 'largetype' => NULL];
        $this->_available_type = ['file', 'file:skipcheck'];
        $this->_available_icon_type = ['fileicon', 'filetype'];

        $this->item = [
            'uid' => NULL,
            'valid' => NULL,
            'autocomplete' => NULL,
            'type' => NULL,
            'title' => NULL,
            'subtitle' => NULL,
            'arg' => NULL,
            'icon' => NULL,
            'icon_type' => NULL,
            'adv_subtitle' => $this->_template_adv_subtitle,
            'adv_text' => $this->_template_adv_text
        ];
    }

    /**
     * Assign the passed variables to the item array.
     * 
     * @param  Array $passed Associative array of desired parameters
     */
    private function _assign_passed( $passed ) {
        $_new_passed = [];
        foreach( $passed as $k => $v ) {
            $_new_passed[strtolower( $k )] = $v;
        }
        foreach( $_new_passed as $k => $v ) {
            $_found = false;
            foreach( $this->entry_options as $_k => $_v ) {
                if ( $k == $_k ) {
                    $_found = true;
                    if ( ! in_array( gettype( $v ), $_v ) ) {
                        if ( $this->debug ) {
                            $this->log('warning', __FUNCTION__, __LINE__,
                                sprintf( 'removing (%s) invalid type, expected (%s)', $k, join( ' or ', $_v ) ) 
                            );
                        }
                    } else {
                        $this->item[$k] = $v;
                    }
                }
            }
            if ( ! ( $_found ) ) {
                if ( $this->debug ) {
                    $this->log('warning', __FUNCTION__, __LINE__,
                        sprintf( 'removing (%s) unknown parameter, available are (%s)', $k, 
                            join( ', ', array_keys( $this->entry_options ) ) ) 
                    );
                }
            }
        }
        $this->item['valid'] = (
            in_array( 'valid', array_keys( $_new_passed ) ) &&
            (! ( is_null( gettype( $_new_passed['valid'] ) ) ) )
            ? 'no' : 'yes'
        ); 
        $this->item['autocomplete'] = (
            in_array( 'autocomplete', array_keys( $_new_passed ) ) 
            ? $_new_passed['autocomplete'] : ''
        );
        $this->item['uid'] = (
            in_array( 'uid', array_keys( $_new_passed ) ) 
            ? $_new_passed['uid'] : NULL
        );
        $this->item['type'] = (
            in_array( 'type', array_keys( $_new_passed ) ) 
            ? $_new_passed['type'] : NULL
        );
    }

    /**
     * Validate the item array for valid parameters
     * 
     * @return boolean True if the item array is valid
     */
    private function _validate_item() {
        $_valid = true;
        foreach( $this->required_options as $i ) {
            if ( is_null( gettype( $this->item[$i] ) ) ) {
                if ( $this->debug ) {
                    $this->log( 'critical', __FUNCTION__, __LINE__,
                        sprintf( 'failed from required option (%s), must be of type (%s)', $i, join( ' or ', $this->entry_options[$i] ) )
                    );
                }
                $_valid = false;
            }
        }
        foreach( [
            'adv_subtitle' => $this->_template_adv_subtitle,
            'adv_text' => $this->_template_adv_text
        ] as $k => $v ) {
            $_to_pop = [];
            foreach( $this->item[$k] as $_k => $_v ) {
                if ( ! ( in_array( $_k, array_keys( $v ) ) ) ) {
                    if ( $this->debug ) {
                        $this->log( 'warning', __FUNCTION__, __LINE__,
                            sprintf( 'removing (%s:%s) invalid option',
                            $k, $_k )
                        );
                    }
                    array_push( $_to_pop, $_k );
                }
            }
            foreach( $_to_pop as $i) {
                unset( $this->item[$k][$i] );
            }
            if ( count( array_keys( $this->item[$k] ) ) <= 0 ) {
                $this->item[$k] = $v;
            }
        }
        foreach( [
            'type' => $this->_available_type,
            'icon_type' => $this->_available_icon_type
        ] as $k => $v ) {
            if ( ( ! ( is_null( gettype( $this->item[$k] ) ) ) ) &&
                ( ! ( in_array( $this->item[$k], $v) ) ) ) {
                if ( $this->debug ) {
                    $this->log( 'warning', __FUNCTION__, __LINE__,
                        sprintf( 'removing (%s) invalid name, expected (%s)',
                        $k, join( ' or ', $v ) )
                    );
                }
                $this->item[$k] = NULL;
            }
        }
        if ( ! ( is_null( gettype( $this->item['icon'] ) ) ) ) {
            if ( ! ( file_exists( $this->item['icon'] ) ) ) {
                if ( $this->debug ) {
                    $this->log( 'warning', __FUNCTION__, __LINE__,
                        sprintf( 'defauling to (icon.png), (%s) does not exist',
                        $this->item['icon'] )
                    );
                }
                $this->item['icon'] = 'icon.png';
            }
        } else {
            $this->item['icon'] = 'icon.png';
        }
        if ( ( ! ( is_null( gettype( $this->item['arg'] ) ) ) ) && 
            ( is_null( gettype( $this->item['uid'] ) ) ) ) {
            if ( $this->debug ) {
                $this->log( 'info', __FUNCTION__, __LINE__,
                    '"uid" is NULL, setting "uid" value to "arg" value'
                );
            }
            $this->item['uid'] = $this->item['arg'];
        }
        if ( is_null( gettype( $this->item['uid'] ) ) ) {
            if ( $this->debug ) {
                $this->log( 'info', __FUNCTION__, __LINE__,
                    '"uid" is NULL and "arg" is NULL, setting "uid" to random 5 digit integer'
                );
            }
            $this->item['uid'] = str_pad(
                rand( 0, pow( 10, 5) - 1), 5, '0', STR_PAD_LEFT 
            );
        }
        return $_valid;
    }

    /**
     * Build the item array into a valid XML entry
     * 
     * @return String XML representation of the item array
     */
    public function _build() {
        $_entry = $this->root->addChild('item');
        $_attribs = ['uid', 'valid', 'autocomplete', 'type'];
        $_statics = ['title', 'subtitle', 'arg'];
        foreach ( $_attribs as $i ) {
            if ( ! ( is_null( gettype( $this->item[$i] ) ) ) ) {
                $_entry->addAttribute( $i, $this->item[$i] );
            }
        }
        foreach ( $_statics as $i ) {
            if ( ! ( is_null( gettype( $this->item[$i] ) ) ) ) {
                $_i_entry = $_entry->addChild( $i, $this->item[$i] );
            }
        }
        foreach ( [
            [
                'tag' => 'subtitle', 
                'attrib' => 'mod', 
                'data' => $this->item['adv_subtitle']
            ],
            [
                'tag' => 'text',
                'attrib' => 'type',
                'data' => $this->item['adv_text']
            ]
        ] as $i ) {
            if ( ! 
                ( count( array_unique( array_values( $i['data'] ) ) ) ) == NULL 
            ) {
                foreach ( $i['data'] as $_k => $_v ) {
                    if ( ! ( is_null( $_v ) ) ) {
                        $_i_entry = $_entry->addChild( $i['tag'], $_v );
                        $_i_entry->addAttribute( $i['attrib'], $_k );
                    }
                }
            }
        }
        $_icon_entry = $_entry->addChild( 'icon', $this->item['icon'] );
        if ( ! ( is_null( $this->item['icon_type'] ) ) ) {
            $_icon_entry->addAttribute( 'type', $this->item['icon_type'] );
        }
        return $_entry;
    }

    /**
     * Method to add and validated the passed desired parameters
     * 
     * @param Array $passed Array of desired parameters
     * @return Entry Entry object
     */
    public function _add( $passed ) {
        $this->_assign_passed( $passed );
        if ( $this->_validate_item() ) {
            return $this;
        }
    }

}
