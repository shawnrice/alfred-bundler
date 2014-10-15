<?php

# TODO: Replace all uses of `is_null` with implementation similar to 
#       that on line 251.

$AUTHOR = 'The Alfred Bundler Team';
$DATE = '10-15-14';
$VERSION = 1.0;


class ScriptFilter {

    private $debug;
    public $header;
    public $entries;
    private $items;

    public function __construct( $debug=False ) {
        $this->debug = $debug;
        $this->header = '<?xml version="1.0" encoding="UTF-8"?>';
        $this->entries = [];
        $this->items = new SimpleXMLElement( '<items/>' );
    }

    public function __toString() {
        return $this->_build_xml();
    }

    private function _build_xml() {
        foreach( $this->entries as $i ) { $i->_build(); }
        $build = dom_import_simplexml( $this->items );
        return sprintf('%s%s', $this->header,
            $build->ownerDocument->saveXML(
                $build->ownerDocument->documentElement
            )
        );
    }

    public function add( $passed ) {
        $_new_entry = new Entry( $this->items, $this->debug );
        $_new_entry->_add( $passed );
        if ( $_new_entry != NULL ) {
            array_push( $this->entries, $_new_entry );
        }
    }

}


class Entry {

    private $debug;
    private $root;
    private $entry_options;
    private $required_options;
    private $_template_adv_subtitle;
    private $_template_adv_text;
    private $_available_type;
    private $_available_icon_type;
    public $item;

    function log( $level, $funct, $lineno, $message ) {
        if ( $this->debug ) {
            echo sprintf( "[%s] [%s:%d] [%s] %s\xA", date('Y-m-d h:i:s'), basename(__FILE__), $lineno, strtoupper( $level ), $message );
        }
    }

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
            (! ( is_null( $_new_passed['valid'] ) ) ) 
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

    private function _validate_item() {
        $_valid = true;
        foreach( $this->required_options as $i ) {
            if ( is_null( $this->item[$i] ) ) {
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
            if ( ( ! ( is_null( $this->item[$k] ) ) ) &&
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
        if ( ! ( is_null( $this->item['icon'] ) ) ) {
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
        if ( ( ! ( is_null( $this->item['arg'] ) ) ) && 
            ( is_null( $this->item['uid'] ) ) ) {
            if ( $this->debug ) {
                $this->log( 'info', __FUNCTION__, __LINE__,
                    '"uid" is NULL, setting "uid" value to "arg" value'
                );
            }
            $this->item['uid'] = $this->item['arg'];
        }
        if ( is_null( $this->item['uid'] ) ) {
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

    public function _build() {
        $_entry = $this->root->addChild('item');
        $_attribs = ['uid', 'valid', 'autocomplete', 'type'];
        $_statics = ['title', 'subtitle', 'arg'];
        foreach ( $_attribs as $i ) {
            if ( ! ( gettype( $this->item[$i] ) == NULL ) ) {
                $_entry->addAttribute( $i, $this->item[$i] );
            }
        }
        foreach ( $_statics as $i ) {
            if ( ! ( is_null( $this->item[$i] ) ) ) {
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
        $_icon_entry = $_entry->addChild( 'icon', $this->icon['icon'] );
        if ( ! ( is_null( $this->item['icon_type'] ) ) ) {
            $_icon_entry->addAttribute( 'type', $this->item['icon_type'] );
        }
        return $_entry;
    }

    public function _add( $passed ) {
        $this->_assign_passed( $passed );
        if ( $this->_validate_item() ) {
            $this->_build();
            return $this;
        }
    }

}
