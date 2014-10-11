#!/usr/bin/env python
# encoding: utf-8

"""
ScriptFilter API for building Alfred ScriptFilter entries.

.. module:: scriptfilter
    :platform: MacOSX
    :synopsis: Create and build XML for Alfred's ScriptFilter output.
.. moduleauthor:: Ritashugisha <ritashugisha@gmail.com>

`Documentation <?>`_.
`License MIT <http://opensource.org/licenses/MIT>`_.
`Copyright 2014 The Alfred Bundler Team`_.

-> Revisons
===============================================================================
1.1, 10-9-14: Initial build for just script filter output
"""

import os
import logging
import random
import xml.etree.ElementTree as etree

logging.basicConfig(
    level=logging.DEBUG,
    format=('[%(asctime)s] '
            '[{}:%(lineno)d] '
            '[%(levelname)s] '
            '%(message)s').format(os.path.basename(__file__)),
    datefmt='%Y-%m-%d %H:%M:%S'
)

AUTHOR = 'The Alfred Bundler Team'
DATE = '10-9-14'
VERSION = '1.0'


class ScriptFilter:

    """ Script Filter class used for building XML for a script filter object.
    
    Public class used to initailize the main items element and the entries list
    Script filter element is built by:

        filter_output = alfredworkflow.filters.ScriptFilter()

    :returns: Built items XML
    :rtype: ``str`` or ``unicode``
    """

    def __init__(self, debug=False):
        """ Initialize the ScriptFilter object."""

        self.debug = debug
        self.log = logging.getLogger(self.__class__.__name__)
        self.header = '<?xml version="1.0" encoding="UTF-8"?>'
        self.entries = []
        self.items = etree.Element('items')

    def __repr__(self):
        """ Get the object's current XML output.
        
        Simply printing or returning the object variable will call this method

            return filter_output

        :returns: Built XML from the items element
        :rtype: ``str`` or ``unicode``
        """
        return self.get()

    def _build_xml(self):
        """ Build the XML for the current entries.

        :returns: Built XML from the items element
        :rtype: ``str`` or ``unicode``
        """

        [i._build() for i in self.entries]
        return '{}{}'.format(self.header, etree.tostring(self.items))

    def get(self):
        """ Grab the built XML if you need the values before printing them.

        :returns: Built XML from the items element
        :rtype: ``str`` or ``unicode``
        """

        return self._build_xml()

    def add(self, **passed):
        """ Add an entry to the script filter object.

        Parameters must be passed as variable references

            add(title='Title', subtitle='Subtitle', arg='Argument')

        :param title: Title of the entry
        :type title: ``str`` or ``unicode``
        :param subtitle: Subtitle of the entry
        :type subtitle: ``str`` or ``unicode``
        :param arg: Argument of entry
        :type arg: ``str`` or ``unicode``
        :param icon: Valid path to icon for entry
        :type icon: ``str`` or ``unicode``
        :param uid: UID of the entry
        :type uid: ``str`` or ``unicode``
        :param valid: True if the entry is valid
        :type valid: ``bool``
        :param autocomplete: String to be autocompleted
        :type autocomplete: ``str`` or ``unicode``
        :param type: Entry type ('file' or 'file:skipcheck')
        :type type: ``str`` or ``unicode``
        :param icon_type: Entry icon type ('fileicon' or 'filetype')
        :type icon_type: ``str`` or ``unicode``
        :param adv_subtitle: Advanced subtitle dictionary
        :type adv_subtitle: ``dict``
        :param adv_text: Advanced text dictionary
        :type adv_text: ``dict``
        """
        _new_entry = ScriptFilter.Entry(self.items)._add(**passed)
        if _new_entry != None:
            self.entries.append(_new_entry)


    class Entry:

        """ Nested ScriptFilter Entry class used to build the XML for an entry.

        Initializes the refernce to both the ``items`` root as well as the
        single item entry under self.item

        :param root: The items element
        :type root: xml.etree.ElementTree
        """

        def __init__(self, root):
            """ Initializes the Entry object."""

            self.log = logging.getLogger('{}::{}'.format(
                os.path.splitext(os.path.basename(__file__))[0],
                self.__class__.__name__
            ))
            self.root = root

            self.entry_options = {
                'title': (str, unicode,),
                'subtitle': (str, unicode,),
                'arg': (str, unicode,),
                'icon': (str, unicode,),
                'uid': (str, unicode,),
                'valid': (bool,),
                'autocomplete': (str, unicode,),
                'type': (str, unicode,),
                'icon_type': (str, unicode,),
                'adv_subtitle': (dict,),
                'adv_text': (dict,)
            }
            self.required_options = ['title']

            self._template_adv_subtitle = {
                'shift': None, 'fn': None, 'ctrl': None, 
                'alt': None, 'cmd': None
            }
            self._template_adv_text = {'copy': None, 'largetype': None}
            self._available_type = ['file', 'file:skipcheck']
            self._available_icon_type = ['fileicon', 'filetype']

            self.item = {
                'uid': None,
                'valid': True,
                'autocomplete': None,
                'type': None,
                'title': None,
                'subtitle': None,
                'arg': None,
                'icon': None,
                'icon_type': None,
                'adv_subtitle': self._template_adv_subtitle,
                'adv_text': self._template_adv_text
            }

        def _assign_passed(self, passed):
            """ Assigned the passed variables to self.item dictionary.

            :param passed: Passed argument dictionary
            :type passed: **kwargs
            """
            _new_passed = {}
            for k, v in passed.iteritems():
                _new_passed[k.lower()] = v

            # Add passed variables to self.item if it is of valid type
            for k, v in _new_passed.iteritems():
                _found = False
                for _k, _v in self.entry_options.iteritems():
                    if (k == _k):
                        _found = True
                        if type(v) in _v:
                            self.item[k] = v
                        else:
                            self.log.warning((
                                'removing {} -> invalid type '
                                '"{}", expecting type {}'.format(k, v, _v))
                            )
                if not _found:
                    self.log.warning((
                        'removing {} -> '
                        'unknown parameter'.format(k))
                    )


            # TODO: Shrink this cleanup down...
            # Cleanup the entry attributes
            self.item['valid'] = (
                'no' if ('valid' in _new_passed.keys()) and \
                not _new_passed['valid'] else 'yes'
            )
            self.item['autocomplete'] = (
                _new_passed['autocomplete'] if 'autocomplete' in \
                _new_passed.keys() else ''
            )
            self.item['uid'] = (
                _new_passed['uid'] if 'uid' in _new_passed.keys() else None
            )
            self.item['type'] = (
                _new_passed['type'] if 'type' in _new_passed.keys() else None
            )


        def _validate_item(self):
            """ Validate (and fix) the self.item dictionary's values."""
            _valid = True

            # Validate that the required options are present
            for i in self.required_options:
                if self.item[i] == None:
                    self.log.error((
                        'stopping -> required option '
                        '"{}" was not passed correctly'
                    ).format(i))
                    _valid = False

            # Fix up the advanced dictionary based parameters
            for k, v in {
                'adv_subtitle': self._template_adv_subtitle, 
                'adv_text': self._template_adv_text
            }.iteritems():
                _to_pop = []
                for i in self.item[k]:
                    if (i not in v.keys()):
                        self.log.warning((
                            'removing {}:{} -> '
                            'invalid option "{}"'.format(k, i, i))
                        )
                        _to_pop.append(i)
                [self.item[k].pop(i) for i in _to_pop]
                if len(self.item[k].keys()) <= 0:
                    self.item[k] = v

            # Fix up the explicit single selection based parameters
            for k, v in {
                'type': self._available_type,
                'icon_type': self._available_icon_type
            }.iteritems():
                if self.item[k] != None and self.item[k] not in v:
                    self.log.warning((
                        'removing {} -> invalid "{}", '
                        'removing'.format(k, self.item[k]))
                    )
                    self.item[k] = None

            # Validate that the passed icon exists, defaults to icon.png
            if self.item['icon'] != None:
                if not os.path.exists(self.item['icon']):
                    self.log.warning((
                        'defaulting to "icon.png" -> icon '
                        '"{}" does not exist'.format(self.item['icon']))
                    )
                    self.item['icon'] = 'icon.png'

            # If the UID is empty but the argument isn't,
            # let the UID equal the argument
            if (self.item['arg'] != None) and (self.item['uid'] == None):
                self.item['uid'] = self.item['arg']

            # Backup method, assigns the UID to a random 5 digit number
            if self.item['uid'] == None:
                self.item['uid'] = str(random.randint(10**(5-1), (10**5)-1))

            return _valid

        def _build(self):
            """ Build the self.item dictionary into a ElementTree object.

            Assumes that the self.item dictionary is validated
            """
            _entry = etree.SubElement(self.root, 'item')

            # Distinguish between entry attributes and sub-elements
            _attribs = ['uid', 'valid', 'autocomplete', 'type']
            _statics = ['title', 'subtitle', 'arg']

            # Add attributes to entry
            for i in _attribs:
                if self.item[i] != None:
                    _entry.attrib[i] = self.item[i]

            # Add sub-elements to entry
            for i in _statics:
                if self.item[i] != None:
                    _i_entry = etree.SubElement(_entry, i)
                    _i_entry.text = self.item[i]

            # Format and add dictionary based parameters
            for i in [
                {
                    'tag': 'subtitle',
                    'attrib': 'mod',
                    'data': self.item['adv_subtitle']
                },
                {
                    'tag': 'text',
                    'attrib': 'type',
                    'data': self.item['adv_text']
                }
            ]:
                if not all(v == None for v in i['data'].itervalues()):
                    for _k, _v in i['data'].iteritems():
                        if _v != None:
                            _i_entry = etree.SubElement(_entry, i['tag'])
                            _i_entry.attrib[i['attrib']] = _k
                            _i_entry.text = _v

            # Add the icon entry
            _icon_entry = etree.SubElement(_entry, 'icon')
            _icon_entry.text = self.item['icon']
            if self.item['icon_type'] != None:
                _icon_entry.attrib['type'] = self.item['icon_type']

            return _entry

        def _add(self, **passed):
            """ Helper method to manage adding the validated entry.

            :param passed: Passed argument dictionary
            :type passed: **kwargs
            :returns: The entry object
            :rtype: ScriptFilter.Entry
            """
            self._assign_passed(passed)
            if (self._validate_item()):
                return self
