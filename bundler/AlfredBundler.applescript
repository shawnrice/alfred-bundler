(* ///
GLOBAL PROPERTIES/VARIABLES
/// *)

--# Current Alfred-Bundler version
property BUNDLER_VERSION : "devel"

--# Path to Alfred-Bundler's root directory
global BUNDLER_DIR
set BUNDLER_DIR to (POSIX path of (path to home folder as text)) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
--# Path to Alfred-Bundler's data directory
global DATA_DIR
set DATA_DIR to BUNDLER_DIR & "/data"
--# Path to Alfred-Bundler's cache directory
global CACHE_DIR
set CACHE_DIR to (POSIX path of (path to home folder as text)) & "Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
--# Path to main Applescript Bundler
global AS_BUNDLER
set AS_BUNDLER to BUNDLER_DIR & "/bundler/AlfredBundler.scpt"
--# Path to applescript libraries directory
global APPLESCRIPT_DIR
set APPLESCRIPT_DIR to DATA_DIR & "/assets/applescript"
--# Path to utilities directory
global UTILITIES_DIR
set UTILITIES_DIR to DATA_DIR & "/assets/utility"
--# Path to icons directory
global ICONS_DIR
set ICONS_DIR to DATA_DIR & "/assets/icons"
--# Path to color alternatives cache
global COLOR_CACHE
set COLOR_CACHE to DATA_DIR & "/color-cache"
--# URL to download `installer.sh`
global BASH_BUNDLET_URL
set BASH_BUNDLET_URL to my formatter("https://raw.githubusercontent.com/shawnrice/alfred-bundler/{}/bundler/bundlets/alfred.bundler.sh", BUNDLER_VERSION)
--# Path to bundler log file
global BUNDLER_LOGFILE
set BUNDLER_LOGFILE to my formatter((DATA_DIR & "/logs/bundler-{}.log"), BUNDLER_VERSION)


(* ///
USER API
/// *)

on library(_name, _version, _json_path)
	(*  Get path to specified AppleScript library, installing it first if necessary.

	Use this method to access AppleScript libraries with functions for common commands.

	This function will return script object of the appropriate library
	(installing it first if necessary), which grants you access to all the
	functions within that library.

	You can easily add your own utilities by means of JSON configuration
	files specified with the ``json_path`` argument. Please see
	`the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_
	for details of the JSON file format.

	:param _name: Name of the utility/asset to install
	:type _name: ``string``
	:param _version: (optional) Desired version of the utility/asset.
	:type _version: ``string``
	:param _json_path: (optional) Path to bundler configuration file
	:type _json_path: ``string`` (POSIX path)
	:returns: Path to utility
	:rtype: ``script object``

	*)
	--# partial support for "optional" args in Applescript
	if my is_empty(_version) then
		set _version to "latest"
	end if
	if my is_empty(_json_path) then
		set _json to ""
	end if
	--# path to specific utility
	set _library to my joiner({APPLESCRIPT_DIR, _name, _version}, "/")
	if my folder_exists(_library) = false then
		--# if utility isn't already installed
		my logger("library", "78", "INFO", my formatter("Library at `{}` not found...", _library))
		set bash_bundlet to (my dirname(AS_BUNDLER)) & "bundlets/alfred.bundler.sh"
		if my file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my joiner({bash_bundlet_cmd, "applescript", _name, _version, _json_path}, space)
			set cmd to my prepare_cmd(cmd)
			my logger("library", "84", "INFO", my formatter("Running shell command: `{}`...", cmd))
			set full_path to (do shell script cmd)
			return load script full_path
		else
			set error_msg to my logger("library", "88", "ERROR", my formatter("Internal bash bundlet `{}` does not exist.", bash_bundlet))
			error error_msg number 1
		end if
	else
		--# if utility is already installed
		my logger("library", "93", "INFO", my formatter("Library at `{}` found...", _library))
		--# read utilities invoke file
		set invoke_file to _library & "/invoke"
		if my file_exists(invoke_file) = true then
			set invoke_path to my read_file(invoke_file)
			--# combine utility path with invoke path
			set full_path to _library & "/" & invoke_path
			return load script full_path
		else
			set error_msg to my logger("library", "103", "ERROR", my formatter("Internal invoke file `{}` does not exist.", invoke_file))
			error error_msg number 1
		end if
	end if
end library


on utility(_name, _version, _json_path)
	(*  Get path to specified utility or asset, installing it first if necessary.

	Use this method to access common command line utilities, such as
	`cocaoDialog <http://mstratman.github.io/cocoadialog/>`_ or
	`Terminal-Notifier <https://github.com/alloy/terminal-notifier>`_.

	This function will return the path to the appropriate executable
	(installing it first if necessary), which you can then utilise via
	:command:`do shell script`.

	You can easily add your own utilities by means of JSON configuration
	files specified with the ``json_path`` argument. Please see
	`the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_ 
	for details of the JSON file format.

	:param _name: Name of the utility/asset to install
	:type _name: ``string``
	:param _version: (optional) Desired version of the utility/asset.
	:type _version: ``string``
	:param _json_path: (optional) Path to bundler configuration file
	:type _json_path: ``string`` (POSIX path)
	:returns: Path to utility
	:rtype: ``string`` (POSIX path)

	*)
	--# partial support for "optional" args in Applescript
	if my is_empty(_version) then
		set _version to "latest"
	end if
	if my is_empty(_json_path) then
		set _json to ""
	end if
	--# path to specific utility
	set _utility to my joiner({UTILITIES_DIR, _name, _version}, "/")
	if my folder_exists(_utility) = false then
		--# if utility isn't already installed
		my logger("utility", "146", "INFO", my formatter("Utility at `{}` not found...", _utility))
		set bash_bundlet to (my dirname(AS_BUNDLER)) & "bundlets/alfred.bundler.sh"
		if my file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my joiner({bash_bundlet_cmd, "utility", _name, _version, _json_path}, space)
			set cmd to my prepare_cmd(cmd)
			my logger("utility", "152", "INFO", my formatter("Running shell command: `{}`...", cmd))
			set full_path to (do shell script cmd)
			return full_path
		else
			set error_msg to my logger("utility", "156", "ERROR", my formatter("Internal bash bundlet `{}` does not exist.", bash_bundlet))
			error error_msg number 1
			--##TODO: need a stable error number schema
		end if
	else
		--# if utility is already installed
		my logger("utility", "162", "INFO", my formatter("Utility at `{}` found...", _utility))
		--# read utilities invoke file
		set invoke_file to _utility & "/invoke"
		if my file_exists(invoke_file) = true then
			set invoke_path to my read_file(invoke_file)
			--# combine utility path with invoke path
			set full_path to _utility & "/" & invoke_path
			return full_path
		else
			set error_msg to my logger("utility", "171", "ERROR", my formatter("Internal invoke file `{}` does not exist.", invoke_file))
			error error_msg number 1
			--##TODO: need a stable error number schema
		end if
	end if
end utility


on icon(_font, _name, _color, _alter)
	(*  Get path to specified icon, downloading it first if necessary.

	``_font``, ``_icon`` and ``_color`` are normalised to lowercase. In
	addition, ``_color`` is expanded to 6 characters if only 3 are passed.

	:param _font: name of the font
	:type _font: ``string``
	:param _icon: name of the font character
	:type _icon: ``string``
	:param _color: (optional) CSS colour in format "xxxxxx" (no preceding #)
	:type _color: ``string``
	:param _alter: (optional) Automatically adjust icon colour to light/dark theme background
	:type _alter: ``Boolean``
	:returns: path to icon file
	:rtype: ``string``

	See http://icons.deanishe.net to view available icons.

	*)
	--# partial support for "optional" args in Applescript
	if my is_empty(_color) then
		set _color to "000000"
		if my is_empty(_alter) then
			set _alter to true
		end if
	end if
	if my is_empty(_alter) then
		set _alter to false
	end if
	--# path to specific icon
	set _icon to my joiner({ICONS_DIR, _font, _color, _name}, "/")
	if my folder_exists(_icon) = false then
		--# if icon isn't already installed
		my logger("icon", "213", "INFO", my formatter("Icon at `{}` not found...", _icon))
		set bash_bundlet to (my dirname(AS_BUNDLER)) & "bundlets/alfred.bundler.sh"
		if my file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my joiner({bash_bundlet_cmd, "icon", _font, _name, _color, _alter}, space)
			set cmd to my prepare_cmd(cmd)
			my logger("icon", "219", "INFO", my formatter("Running shell command: `{}`...", cmd))
			set full_path to (do shell script cmd)
		else
			set error_msg to my logger("icon", "222", "ERROR", my formatter("Internal bash bundlet `{}` does not exist.", bash_bundlet))
			error error_msg number 1
		end if
	else
		--# if icon is already installed
		my logger("icon", "INFO", my formatter("Icon at `{}` found...", _icon))
		return _icon
	end if
end icon



(* ///
LOGGING HANDLER
/// *)

on logger(_handler, line_num, _level, _message)
	(* Log information in the standard Alfred-Bundler log file.
	This AppleScript logger will save the `_message` with appropriate information
	in this format:
		'[%(asctime)s] [%(filename)s:%(lineno)s] '
		'[%(levelname)s] %(message)s',
		datefmt='%Y-%m-%d %H:%M:%S'
	It will then return the information in this format:
		'[%(asctime)s] [%(filename)s:%(lineno)s] '
		'[%(levelname)s] %(message)s',
		datefmt='%H:%M:%S'

	:param: _handler: name of the function where the script it running
	:type _handler: ``string``
	:param: line_num: number of the line of action for logging
	:type line_num: ``string``
	:param _level: type of logging information (INFO or DEBUG)
	:type _level: ``string``
	:param _message: message to be logged
	:type _message: ``string``
	:returns: a properly formatted log message
	:rtype: ``string``

	*)
	--# Ensure log file exists, with checking for scope of global var
	try
		my check_file(BUNDLER_LOGFILE)
	on error
		set BUNDLER_LOGFILE to my formatter((DATA_DIR & "/logs/bundler-{}.log"), BUNDLER_VERSION)
		my check_file(BUNDLER_LOGFILE)
	end try
	--# delay to ensure IO action is completed
	delay 0.1
	--# Prepare time string format %Y-%m-%d %H:%M:%S
	set log_time to "[" & (my date_formatter()) & "]"
	set formatterted_time to text items 1 thru -4 of (time string of (current date)) as string
	set error_time to "[" & formatterted_time & "]"
	--# Prepare location message
	set _location to "[bundler.scpt:" & _handler & ":" & line_num & "]"
	--# Prepare level message
	set _level to "[" & _level & "]"
	--# Generate full error message for logging
	set log_msg to (my joiner({log_time, _location, _level, _message}, space)) & (ASCII character 10)
	my write_to_file(log_msg, BUNDLER_LOGFILE, true)
	--# Generate regular error message for returning to user
	set error_msg to error_time & space & _location & space & _level & space & _message
	return error_msg
end logger

(* ///
SUB-ACTION HANDLERS
/// *)

on date_formatter()
	(* Format current date and time into %Y-%m-%d %H:%M:%S string format.
	
	:returns: Formatted date-time stamp
	:rtype: ``string``
		
	*)
	set {year:y, month:m, day:d} to current date
	set date_num to (y * 10000 + m * 100 + d) as string
	set formatterted_date to ((text 1 thru 4 of date_num) & "-" & (text 5 thru 6 of date_num) & "-" & (text 7 thru 8 of date_num))
	set formatterted_time to text items 1 thru -4 of (time string of (current date)) as string
	return formatterted_date & space & formatterted_time
end date_formatter

on read_file(target_file)
	(* Read data from `target_file`.
	
	:param target_file: Full path to the file to be written to
	:type target_file: ``string`` (POSIX path)
	:returns: Data contained in `target_file`
	:rtype: ``string``
		
	*)
	open for access POSIX file target_file
	set _contents to (read target_file)
	close access target_file
	return _contents
end read_file

on prepare_cmd(cmd)
	(* Ensure shell `_cmd` is working from the proper directory.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:returns: ``string``

	*)
	set pwd to quoted form of (my pwd())
	return "cd " & pwd & "; bash " & cmd
end prepare_cmd


(* ///
IO HELPER FUNCTIONS
/// *)

on write_to_file(this_data, target_file, append_data)
	(* Write or append `this_data` to `target_file`.
	
	:param this_data: The text to be written to the file
	:type this_data: ``string``
	:param target_file: Full path to the file to be written to
	:type target_file: ``string`` (POSIX path)
	:param append_data: Overwrite or append text to file?
	:type append_data: ``Boolean``
	:returns: Was the write successful?
	:rtype: ``Boolean``
		
	*)
	try
		set the target_file to the target_file as string
		set the open_target_file to open for access POSIX file target_file with write permission
		if append_data is false then set eof of the open_target_file to 0
		write this_data to the open_target_file starting at eof
		close access the open_target_file
		return true
	on error
		try
			close access file target_file
		end try
		return false
	end try
end write_to_file

--# 
on pwd()
	(* Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	*)
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end pwd

on dirname(_file)
	(* Get name of directory containing `_file`.
	
	:param _file: Full path to existing file
	:type _file: ``string`` (POSIX path)
	:returns: Full path to `_file`'s parent directory
	:rtype: ``string`` (POSIX path)
		
	*)
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of _file as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end dirname

on check_dir(_folder)
	(* Check if `_folder` exists, and if not create it and any sub-directories.

	:returns: POSIX path to `_folder`
	:rtype: ``string`` (POSIX path)

	*)
	if not my folder_exists(_folder) then
		do shell script "mkdir -p " & (quoted form of _folder)
	end if
	return _folder
end check_dir

on check_file(_path)
	(* Check if `_path` exists, and if not create it and its directory tree.

	:returns: POSIX path to `_path`
	:rtype: ``string`` (POSIX path)

	*)
	if not my file_exists(_path) then
		set _dir to dirname(_path)
		my check_dir(_dir)
		delay 0.1
		do shell script "touch " & (quoted form of _path)
	end if
end check_file

--#  handler to check if a folder exists
on folder_exists(_folder)
	(* Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	*)
	if my path_exists(_folder) then
		tell application "System Events"
			return (class of (disk item _folder) is folder)
		end tell
	end if
	return false
end folder_exists

--# handler to check if a file exists
on file_exists(_file)
	(* Return ``true`` if `_file` exists, else ``false``

	:param _file: Full path to file
	:type _file: ``string`` (POSIX path)
	:returns: ``Boolean``

	*)
	if my path_exists(_file) then
		tell application "System Events"
			return (class of (disk item _file) is file)
		end tell
	end if
	return false
end file_exists

--#  handler to check if a path exists
on path_exists(_path)
	(* Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	*)
	if _path is missing value or my is_empty(_path) then return false
	
	try
		if class of _path is alias then return true
		if _path contains ":" then
			alias _path
			return true
		else if _path contains "/" then
			POSIX file _path as alias
			return true
		else
			return false
		end if
	on error msg
		return false
	end try
end path_exists

(* ///
TEXT HELPER FUNCTIONS
/// *)

on split(str, delim)
	(* Split a string into a list

	:param str: A text string
	:type str: ``string``
	:param delim: Where to split `str` into pieces
	:type delim: ``string``
	:returns: the split list
	:rtype: ``list``

	*)
	local delim, str, ASTID
	set ASTID to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to delim
		set str to text items of str
		set AppleScript's text item delimiters to ASTID
		return str --> list
	on error msg number num
		set AppleScript's text item delimiters to ASTID
		error "Can't explode: " & msg number num
	end try
end split

--# format string á la Python
on formatter(str, arg)
	(* Replace `{}` in `str` with `arg`

	:param str: A text string with one instance of `{}`
	:type str: ``string``
	:param arg: The text to replace `{}`
	:type arg: ``string``
	:returns: trimmed string
	:rtype: ``string``

	*)
	local ASTID, str, arg, lst
	set ASTID to AppleScript's text item delimiters
	try
		considering case
			set AppleScript's text item delimiters to "{}"
			set lst to every text item of str
			set AppleScript's text item delimiters to arg
			set str to lst as string
		end considering
		set AppleScript's text item delimiters to ASTID
		return str
	on error msg number num
		set AppleScript's text item delimiters to ASTID
		error "Can't replaceString: " & msg number num
	end try
end formatter

--# removes white space surrounding a string
on trim(_str)
	(* Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string
	:rtype: ``string``

	*)
	if class of _str is not text or class of _str is not string or _str is missing value then return _str
	if _str is "" then return _str
	repeat while _str begins with " "
		try
			set _str to items 2 thru -1 of _str as text
		on error msg
			return ""
		end try
	end repeat
	repeat while _str ends with " "
		try
			set _str to items 1 thru -2 of _str as text
		on error
			return ""
		end try
	end repeat
	return _str
end trim

on joiner(pieces, delim)
	(* Join list of `pieces` into a string delimted by `delim`.

	:param pieces: A list of objects
	:type pieces: ``list``
	:param delim: The text item by which to join the list items
	:type delim: ``string``
	:returns: trimmed string
	:rtype: ``string``

	*)
	local delim, pieces, ASTID
	set ASTID to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to delim
		set pieces to "" & pieces
		set AppleScript's text item delimiters to ASTID
		return pieces --> text
	on error emsg number eNum
		set AppleScript's text item delimiters to ASTID
		error "Can't implode: " & emsg number eNum
	end try
end joiner

(* ///
LOWER LEVEL HELPER FUNCTIONS
/// *)

--# checks if a value is empty
on is_empty(_obj)
	(* Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:rtype: ``Boolean``
		
	*)
	if {true, false} contains _obj then return false
	if _obj is missing value then return true
	return length of (my trim(_obj)) is 0
end is_empty