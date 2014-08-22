(* GLOBAL PROPERTIES *)

property BUNDLER_VERSION : "devel"

--# Used for notifications, paths
property BUNDLER_ID : "com.hackademic.alfred-bundler-applescript"

--# Bundler paths
property _home : POSIX path of (path to "cusr" as text)
property BUNDLER_DIR : (_home) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
property DATA_DIR : BUNDLER_DIR & "/data"
property CACHE_DIR : (_home) & "Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION

--# Main Applescript library
property BUNDLER_AS_LIB : BUNDLER_DIR & "/bundler/AlfredBundler.scpt"

--# Root directory under which workflow-specific Python libraries are installed
property APPLESCRIPT_LIB_DIR : DATA_DIR & "/assets/applescript"

--# Wrappers module path
property WRAPPERS_DIR : BUNDLER_DIR & "/bundler/includes/wrappers/applescript"

--# Where helper scripts and metadata are stored
property HELPER_DIR : APPLESCRIPT_LIB_DIR & "/" & BUNDLER_ID

--# Directory for Bundler icons
property BUNDLER_ICONS_LIB : DATA_DIR & "/assets/icons"

--# Where color alternatives are cached
property COLOR_CACHE : DATA_DIR & "/color-cache"

(* GLOBAL VARIABLES *)

--# Where installer.sh can be downloaded from
global BASH_BUNDLET_URL
set BASH_BUNDLET_URL to my _format("https://raw.githubusercontent.com/shawnrice/alfred-bundler/{}/bundler/bundlets/alfred.bundler.sh", BUNDLER_VERSION)

--# Bundler log file
global BUNDLER_LOGFILE
set BUNDLER_LOGFILE to my _format((DATA_DIR & "/logs/bundler-{}.log"), BUNDLER_VERSION)

--# The actual bundler module will be imported into this variable
property _bundler : missing value


--get_icon("fontawesome", "ambulance", "000", true)
my load_utility("pashua", missing value, missing value)



(* ///
USER API
/// *)

on load_utility(_name, _version, _json)
	--# partial support for "optional" args in Applescript
	if my _is_empty(_version) then
		set _version to "latest"
	end if
	if my _is_empty(_json) then
		set _json to false
	end if
	
	set utility to APPLESCRIPT_LIB_DIR & "/" & _name & "/" & _version
	if my _folder_exists(utility) = false then
		set bash_bundlet to (my _pwd()) & "bundlets/alfred.bundler.sh"
		if my _file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my _join({bash_bundlet_cmd, "utility", _name, _version, _json}, space)
			return "/bin/bash " & cmd
		end if
	end if
end load_utility


on get_icon(_font, _name, _color, _alter)
	--# partial support for "optional" args in Applescript
	if my _is_empty(_color) then
		set _color to "000000"
		if my _is_empty(_alter) then
			set _alter to true
		end if
	end if
	if my _is_empty(_alter) then
		set _alter to false
	end if
	
	set icon to BUNDLER_ICONS_LIB & "/" & _font & "/" & _color & "/" & _name
	if my _folder_exists(icon) = false then
		set bash_bundlet to (my _pwd()) & "bundlets/alfred.bundler.sh"
		if my _file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my _join({bash_bundlet_cmd, "icon", _font, _name, _color, _alter}, space)
			return "/bin/bash " & cmd
		end if
	else
		return "exists"
	end if
end get_icon










(* ///
MAIN ACTION HANDLERS 
/// *)

on _bootstrap()
	(*Check if bundler bash bundlet is installed and install it if not.

    	:returns: ``None``

    	*)
	
	if _bundler is not equal to missing value then
		return true
	else
		--# Create local directories if they don't exist
		repeat with dirpath in {HELPER_DIR, CACHE_DIR, COLOR_CACHE}
			if my _folder_exists(dirpath) = false then
				my _log("_bootstrap", "INFO", my _format("Creating directory `{}`", (dirpath as string)))
				my _check_dir(dirpath)
			else
				
			end if
		end repeat
		
		if my _file_exists(BUNDLER_AS_LIB) = false then
			--# Install bundler
			my _log("_bootstrap", "INFO", my _format("Installing Alfred Dependency Bundler version `{}`", BUNDLER_VERSION))
			set bundlet_path to CACHE_DIR & "/bundlet-temp.sh"
			set bash_code to my _format("source \"{}\"", bundlet_path)
			try
				my _download(BASH_BUNDLET_URL, bundlet_path)
			on error emsg number num
				set msg to "Error downloading `" & BASH_BUNDLET_URL & "` to `{}`"
				my _log("_bootstrap", "DEBUG", my _format(msg, bundlet_path))
				error emsg number num
			end try
			my _log("_bootstrap", "INFO", my _format("Executing script : `{}`", bash_code))
			return bash_code
		else
			
		end if
		
	end if
	
	
end _bootstrap

on _download(_url, _filepath)
	(*Download ``url`` to ``filepath``

    	:param url: URL to download
    	:type url: ``unicode`` or ``str``
    	:param filepath: Path to download URL to
    	:type filepath: ``unicode`` or ``str``
    	:returns: None

    	*)
	
	my _log("_download", "INFO", my _format("Opening URL `{}` ...", _url))
	--# Ensure full path to file exists
	my _check_file(_filepath)
	delay 0.1
	--# Get HTTP response headers
	set cmd to "curl -I " & _url
	try
		set headers to do shell script cmd
		set headers to my _split(headers, ASCII character 13)
		my _log("_download", "INFO", my _format("HTTP Response [{}] ...", item 1 of headers))
		--# Only download if HTTP response code 200 OK
		if item 1 of headers contains "200" then
			try
				--# Download bash bundlet from GitHub
				set cmd to "curl -v -o " & (quoted form of _filepath) & space & _url
				my _log("_download", "INFO", my _format("Downloading `{}` ...", _url))
				set response to do shell script cmd
				my _log("_download", "INFO", my _format("Saved `{}`", _filepath))
				return response
			on error msg number num
				set error_msg to "Applescript Error: <" & msg & "> Number: [" & num & "]"
				my _log("_download", "DEBUG", error_msg)
				error msg number num
			end try
		else
			error my _log("_download", "DEBUG", my _format("Error retrieving URL. Server returned {}", item 1 of headers))
		end if
	on error msg number num
		set error_msg to "Applescript Error: <" & msg & "> Number: [" & num & "]"
		my _log("_download", "DEBUG", error_msg)
		error msg number num
	end try
end _download

on _log(_handler, _level, _message)
	--# Ensure log file exists
	my _check_file(BUNDLER_LOGFILE)
	delay 0.1 -- delay to ensure IO action is completed
	--# Prepare time string format %Y-%m-%d %H:%M:%S
	set log_time to "[" & (my date_format()) & "]"
	set formatted_time to text items 1 thru -4 of (time string of (current date)) as string
	set error_time to "[" & formatted_time & "]"
	--# Prepare location message
	set _location to "[bundler.scpt:" & _handler & "]"
	--# Prepare level message
	set _level to "[" & _level & "]"
	--# Generate full error message for logging
	set log_msg to (ASCII character 10) & log_time & space & _location & space & _level & tab & _message
	my write_to_file(log_msg, BUNDLER_LOGFILE, true)
	--# Generate regular error message for returning to user
	set error_msg to error_time & space & _location & space & _level & tab & _message
	return error_msg
end _log

(* ///
SUB-ACTION HANDLERS
/// *)

on date_format() -- Old_date is text, not a date.
	set {year:y, month:m, day:d} to current date
	set date_num to (y * 10000 + m * 100 + d) as string
	set formatted_date to ((text 1 thru 4 of date_num) & "-" & (text 5 thru 6 of date_num) & "-" & (text 7 thru 8 of date_num))
	set formatted_time to text items 1 thru -4 of (time string of (current date)) as string
	return formatted_date & space & formatted_time
end date_format

(* ///
IO HELPER FUNCTIONS
/// *)

on write_to_file(this_data, target_file, append_data)
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
on _pwd()
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd

on _dirname(_file)
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of _file as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _dirname

on _check_dir(_folder)
	if not my _folder_exists(_folder) then
		do shell script "mkdir -p " & (quoted form of _folder)
	end if
	return _folder
end _check_dir

on _check_file(_path)
	if not my _file_exists(_path) then
		set _dir to _dirname(_path)
		my _check_dir(_dir)
		delay 0.1
		do shell script "touch " & (quoted form of _path)
	end if
end _check_file

--#  handler to check if a folder exists
on _folder_exists(_folder)
	if my _path_exists(_folder) then
		tell application "System Events"
			return (class of (disk item _folder) is folder)
		end tell
	end if
	return false
end _folder_exists

--# handler to check if a file exists
on _file_exists(_file)
	if my _path_exists(_file) then
		tell application "System Events"
			return (class of (disk item _file) is file)
		end tell
	end if
	return false
end _file_exists

--#  handler to check if a path exists
on _path_exists(_path)
	if _path is missing value or my _is_empty(_path) then return false
	
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
end _path_exists

(* ///
TEXT HELPER FUNCTIONS
/// *)

on _split(str, delimiter)
	local delimiter, str, ASTID
	set ASTID to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to delimiter
		set str to text items of str
		set AppleScript's text item delimiters to ASTID
		return str --> list
	on error msg number num
		set AppleScript's text item delimiters to ASTID
		error "Can't explode: " & msg number num
	end try
end _split

--# format string á la Python
on _format(str, arg)
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
end _format

--# removes white space surrounding a string
on _trim(str)
	if class of str is not text or class of str is not string or str is missing value then return str
	if str is "" then return str
	repeat while str begins with " "
		try
			set str to items 2 thru -1 of str as text
		on error msg
			return ""
		end try
	end repeat
	repeat while str ends with " "
		try
			set str to items 1 thru -2 of str as text
		on error
			return ""
		end try
	end repeat
	return str
end _trim

on _join(pieces, delim)
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
end _join

(* ///
LOWER LEVEL HELPER FUNCTIONS
/// *)

--# checks if a value is empty
on _is_empty(str)
	if str is missing value then return true
	return length of (my _trim(str)) is 0
end _is_empty