#!/usr/bin/ruby

# ScriptFilter API for building Alfred ScriptFilter entries.
#
# .. module:: scriptfilter
#     :platform: MacOSX
#     :synopsis: Create and build XML for Alfred's ScriptFilter output.
# .. moduleauthor:: Ritashugisha <ritashugisha@gmail.com>
#
# `Documentation <?>`_.
# `License MIT <http://opensource.org/licenses/MIT>`_.
# `Copyright 2014 The Alfred Bundler Team`_.
#
# -> Usage
# =============================================================================
#
# To include this api in your Ruby scripts, copy this ``scriptfilter.rb`` to
# a viable place for you to import.
#
# Import the ScriptFilter client:
#
#     require './scriptfilter'
#     my_filter = Alfred::ScriptFilter(debug=false)
#
# Now that you have access to the client, you can add entries to the filter.
#
#     my_filter.add(
#         title: 'My Entry',
#         subtitle: 'A subtitle for my entry',
#         arg: 'My entry\'s passed argument',
#         adv_subtitle: {
#             shift: 'Subtitle when shift is pressed',
#             cmd: 'Subtitle when cmd is pressed'
#         },
#         uid: 'my custom uid',
#         icon: 'path to your icon.png'
#     )
#
# This will ensure that this entry will be rendered to XML (along with any
# other entries that you add) that can be accepted by Alfred's ScriptFilter obj.
#
# In order to obtain the XML, either print the filter name or grab the returned
# value from the .to_s method.
#
#     # Option 1
#     puts my_filter
#
#     # Option 2
#     filter_output = my_filter.to_s
#
#
# -> Revisons
# =============================================================================
# 1.1, 10-14-14: Initial build for just script filter output



module Alfred

$AUTHOR = 'The Alfred Bundler Team'
$DATE = '10-11-14'
$VERSION = 1.0

require 'xml'


# Script Filter class used for building XML for a script filter object.
# 
# Public class used to initalize the main items element and the entries list.
# Script filter element is built by:
# 
#     _filter = bundler.wrapper('scriptfilter')
#     
# :returns: Build items XML
# :rtype: String
class Scriptfilter

    @@debug
    @@_root_doc
    @@header
    @entries
    @@items

    # Initialize the ScriptFilter object.
    # 
    # :param debug: Allow debugging for script filter object
    # :type debug: Boolean
    def initialize(debug=false)
        @@debug = debug
        @@items = XML::Document.new
        @@header = '<?xml version="1.0" encoding="UTF-8"?>'
        @entries = []
        @@items.root = XML::Node.new('items')
    end

    # Get the object's current XML output.
    # 
    # Simply printing or returning the object variable will call this method
    # 
    #     return _filter
    # 
    # :returns: Built XML from the items element
    # :rtype: String
    def to_s()
        @entries.each{ |i| i._build() }
        return '%s%s' % [@header, @@items.to_s]
    end

    # Add an entry to the script filter object.
    #
    # Parameters must be passed as variable references
    #
    #     add(title: 'Title', subtitle: 'Subtitle', arg: 'Argument')
    #
    # :param title: Title of the entry
    # :type title: String
    # :param subtitle: Subtitle of the entry
    # :type subtitle: String
    # :param arg: Argument of entry
    # :type arg: String
    # :param icon: Valid path to icon for entry
    # :type icon: String
    # :param uid: UID of the entry
    # :type uid: String
    # :param valid: True if the entry is valid
    # :type valid: Boolean
    # :param autocomplete: String to be autocompleted
    # :type autocomplete: String
    # :param type: Entry type ('file' or 'file:skipcheck')
    # :type type: String
    # :param icon_type: Entry icon type ('fileicon' or 'filetype')
    # :type icon_type: String
    # :param adv_subtitle: Advanced subtitle dictionary
    # :type adv_subtitle: Hash
    # :param adv_text: Advanced text dictionary
    # :type adv_text: Hash
    def add(passed)
        _new_entry = Alfred::Entry.new(@@items, @@debug)._add(passed)
        if _new_entry != nil
            @entries << _new_entry
        end
    end

end

# ScriptFilter Entry class used to build the XML for an entry.
class Entry

    @@debug
    @@items
    @item

    def self.log(level, funct, lineno, message)
        if @@debug
            $stdout.write "[%s] [%s:%d] [%s] %s\n" % [
                Time.now.strftime('%Y-%m-%d %H:%M:%S'),
                File.basename(__FILE__),
                lineno,
                level.upcase,
                message
            ]
        end
    end

    def self._passed_lower(passed)
        new_passed = {}
        passed.each_pair do |k,v|
            new_passed.merge!({k.downcase => v})
        end
        return new_passed
    end

    # Initailizes the Entry object.
    # 
    # Initializes the reference to the @@items 
    # root as well as the single item entry under @item
    # 
    # :param items: @@items from ScriptFilter object
    # :type items: XML::Document::Node
    # :param debug: Allow debugging for entry manipulation
    # :type debug: Boolean
    def initialize(items, debug)
        @@items = items
        @@debug = debug
        @@entry_options = {
            title: [String],
            subtitle: [String],
            arg: [String],
            icon: [String],
            uid: [String],
            valid: [TrueClass, FalseClass],
            autocomplete: [String],
            type: [String],
            icon_type: [String],
            adv_subtitle: [Hash],
            adv_text: [Hash]
        }
        @@required_options = ['title']
        @@_template_adv_subtitle = {
            shift: nil, fn: nil, ctrl: nil,
            alt: nil, cmd: nil
        }
        @@_template_adv_text = {copy: nil, largetype: nil}
        @@_available_type = ['file', 'file:skipcheck']
        @@_available_icon_type = ['fileicon', 'filetype']
        
        @item = {
            uid: nil,
            valid: true,
            autocomplete: nil,
            type: nil,
            title: nil,
            subtitle: nil,
            arg: nil,
            icon: nil,
            icon_type: nil,
            adv_subtitle: @@_template_adv_subtitle,
            adv_text: @@_template_adv_text
        }
    end

    # Assign the passed variables to @item hash
    # 
    # :param passed: Passed argument hash
    # :type passed: Hash
    def _assign_passed(passed)
        _new_passed = self.class._passed_lower(passed)
        _new_passed.each_pair do |k,v|
            _found = false
            @@entry_options.each_pair do |_k,_v|
                if (k == _k)
                    _found = true
                    if not (_v.include? v.class)
                        if @@debug
                            self.class.log('warning', __method__, __LINE__,
                                'removing (%s) invalid type, expected (%s)' %
                                [k, _v.join(' or ')])
                        end
                    else
                        @item[k] = v
                    end
                end
            end
            if (!_found)
                if @@debug
                    self.class.log('warning', __method__, __LINE__,
                        'removing (%s) unknown parameter, available are (%s)' %
                        [k, @@entry_options.keys.join(', ')])
                end
            end
        end

        @item[:valid] = (
            _new_passed.keys.include? 'valid'.to_sym and \
            _new_passed[:valid].nil?
        ) ? 'no' : 'yes'
        @item[:autocomplete] = (
            _new_passed.keys.include? 'autocomplete'.to_sym
        ) ? _new_passed[:autocomplete] : ''
        @item[:uid] = (
            _new_passed.keys.include? 'uid'.to_sym
        ) ? _new_passed[:uid] : nil
        @item[:type] = (
            _new_passed.keys.include? 'type'.to_sym
        ) ? _new_passed[:type] : nil

    end

    # Validate (and fix) the @item hash's values.
    def _validate_item()
        _valid = true

        @@required_options.each do |i|
            if @item[i.to_sym] == nil
                if @@debug
                    self.class.log('critical', __method__, __LINE__,
                        'failed from required option (%s) must be of type (%s)' %
                        [i, @@entry_options[i.to_sym].join(' or ')])
                    _valid = false
                end
            end
        end

        {
            adv_subtitle: @@_template_adv_subtitle,
            adv_text: @@_template_adv_text
        }.each_pair do |k,v|
            _to_pop = []
            @item[k].each do |i|
                unless v.keys.include? i[0]
                    if @@debug
                        self.class.log('warning', __method__, __LINE__,
                            'removing (%s:%s) invalid option' % 
                            [k, i])
                    end
                    _to_pop << i
                end
            end
            _to_pop.each do |i|
                @item[k].delete i
            end
            if @item[k].length <= 0
                @item[k] = v
            end
        end

        {
            type: @@_available_type,
            icon_type: @@_available_icon_type
        }.each_pair do |k,v|
            if @item[k] != nil and not v.include? @item[k]
                if @@debug
                    self.class.log('warning', __method__, __LINE__,
                        'removing (%s) invalid name, expected (%s)' % 
                        [k, v.join(' or ')])
                end
                @item[k] = nil
            end
        end

        if @item[:icon] != nil
            if not File.exists? @item[:icon]
                if @@debug
                    self.class.log('warning', __method__, __LINE__,
                        'defaulting to (icon.png), (%s) does not exist' % 
                        [@item[:icon]])
                end
                @item[:icon] = 'icon.png'
            end
        else
            @item[:icon] = 'icon.png'
        end

        if @item[:arg] != nil and @item[:uid] == nil
            if @@debug
                self.class.log('info', __method__, __LINE__,
                    '"uid" is nil, setting "uid" value to "arg" value')
            end
            @item[:uid] = @item[:arg]
        end

        if @item[:uid] == nil
            if @@debug
                self.class.log('info', __method__, __LINE__,
                    '"uid" is nil and "arg" is nil, setting "uid" to random 5 digit integer')
            end
            @item[:uid] = '%05d' % rand(10 ** 5)
        end

        return _valid
    end

    # Build the @item hash into an XML::Node
    # 
    # Assumes that the @item hash is validated
    def _build()
        _entry = XML::Node.new('item')
        _attribs = ['uid', 'valid', 'autocomplete', 'type']
        _statics = ['title', 'subtitle', 'arg']

        _attribs.each do |i|
            if @item[i.to_sym] != nil
                XML::Attr.new(_entry, i, @item[i.to_sym])
            end
        end

        _statics.each do |i|
            if @item[i.to_sym] != nil
                _i_entry = XML::Node.new(i)
                _i_entry << @item[i.to_sym]
                _entry << _i_entry
            end
        end

        [{
            tag: 'subtitle',
            attrib: 'mod',
            data: @item[:adv_subtitle]
        }, {
            tag: 'text',
            attrib: 'type',
            data: @item[:adv_text]
        }].each do |i|
            if not i[:data].values.all? {|j| j == nil}
                i[:data].each_pair do |_k,_v|
                    if _v != nil
                        _i_entry = XML::Node.new(i[:tag])
                        XML::Attr.new(_i_entry, i[:attrib], _k.to_s)
                        _i_entry << _v
                        _entry << _i_entry
                    end
                end
            end
        end

        _icon_entry = XML::Node.new('icon')
        _icon_entry << @item[:icon]
        if @item[:icon_type] != nil
            XML::Attr.new(_icon_entry, 'type', @item[:icon_type])
        end
        _entry << _icon_entry
        @@items.root << _entry

        return _entry
    end

    # Helper method to manage adding the validated entry.
    # 
    # :param passed: Passed argument hash
    # :type passed: Hash
    # :returns: The entry object
    # :rtype: Alfred::Entry
    def _add(passed)
        passed = passed.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        self._assign_passed(passed)
        if (self._validate_item())
            return self
        end
    end
end


end

