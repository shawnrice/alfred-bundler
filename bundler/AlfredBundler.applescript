(* GLOBAL PROPERTIES 

&& $? for bash status codes

*)
property BUNDLER_VERSION : "devel"
--# Bundler paths
property _home : POSIX path of (path to "cusr" as text)
property BUNDLER_DIR : (_home) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
property DATA_DIR : BUNDLER_DIR & "/data"
property CACHE_DIR : (_home) & "Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
--# Main Applescript Bundler
property AS_BUNDLER : BUNDLER_DIR & "/bundler/AlfredBundler.scpt"
--# Root directory under which workflow-specific applescript libraries are installed
property APPLESCRIPT_DIR : DATA_DIR & "/assets/applescript"
--# Root directory under which Bundler utilities are installed
property UTILITIES_DIR : DATA_DIR & "/assets/utility"
--# Directory for Bundler icons
property ICONS_DIR : DATA_DIR & "/assets/icons"
--# Where color alternatives are cached
property COLOR_CACHE : DATA_DIR & "/color-cache"

(* GLOBAL VARIABLES *)

--# Where installer.sh can be downloaded from
global BASH_BUNDLET_URL
set BASH_BUNDLET_URL to my formatter("https://raw.githubusercontent.com/shawnrice/alfred-bundler/{}/bundler/bundlets/alfred.bundler.sh", BUNDLER_VERSION)

--# Bundler log file
global BUNDLER_LOGFILE
set BUNDLER_LOGFILE to my formatter((DATA_DIR & "/logs/bundler-{}.log"), BUNDLER_VERSION)


(* ///
USER API
/// *)

on utility(_name, _version, _json)
	--# partial support for "optional" args in Applescript
	if my is_empty(_version) then
		set _version to "latest"
	end if
	if my is_empty(_json) then
		set _json to ""
	end if
	--# path to specific utility
	set utility to my joiner({UTILITIES_DIR, _name, _version}, "/")
	if my folder_exists(utility) = false then
		--# if utility isn't already installed
		my logger("utility", "INFO", my formatter("Utility at `{}` not found...", utility))
		set bash_bundlet to (my dirname(AS_BUNDLER)) & "bundlets/alfred.bundler.sh"
		if my file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my joiner({bash_bundlet_cmd, "utility", _name, _version, _json}, space)
			set cmd to my prepare_cmd(cmd)
			my logger("utility", "INFO", my formatter("Running shell command: `{}`...", cmd))
			set full_path to (do shell script cmd)
			return full_path
		else
			set error_msg to my logger("utility", "DEBUG", my formatter("Internal bash bundlet `{}` does not exist.", bash_bundlet))
			error error_msg number 1
			--##TODO: need a stable error number schema
		end if
	else
		--# if utility is already installed
		my logger("utility", "INFO", my formatter("Utility at `{}` found...", utility))
		--# read utilities invoke file
		set invoke_file to utility & "/invoke"
		if my file_exists(invoke_file) = true then
			set invoke_path to my _read_file(invoke_file)
			--# combine utility path with invoke path
			set full_path to utility & "/" & invoke_path
			return full_path
		else
			set error_msg to my logger("utility", "DEBUG", my formatter("Internal invoke file `{}` does not exist.", invoke_file))
			error error_msg number 1
			--##TODO: need a stable error number schema
		end if
	end if
end utility


on icon(_font, _name, _color, _alter)
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
	set icon to my joiner({ICONS_DIR, _font, _color, _name}, "/")
	if my folder_exists(icon) = false then
		--# if icon isn't already installed
		my logger("icon", "INFO", my formatter("Icon at `{}` not found...", icon))
		set bash_bundlet to (my dirname(AS_BUNDLER)) & "bundlets/alfred.bundler.sh"
		if my file_exists(bash_bundlet) = true then
			set bash_bundlet_cmd to quoted form of bash_bundlet
			set cmd to my joiner({bash_bundlet_cmd, "icon", _font, _name, _color, _alter}, space)
			set cmd to my prepare_cmd(cmd)
			my logger("icon", "INFO", my formatter("Running shell command: `{}`...", cmd))
			set full_path to (do shell script cmd)
		else
			set error_msg to my logger("icon", "DEBUG", my formatter("Internal bash bundlet `{}` does not exist.", bash_bundlet))
			error error_msg number 1
			--##TODO: need a stable error number schema
		end if
	else
		--# if icon is already installed
		my logger("icon", "INFO", my formatter("Icon at `{}` found...", icon))
		return icon
	end if
end icon



(* ///
LOGGING HANDLER
/// *)

on logger(_handler, _level, _message)
	--# Ensure log file exists, with
	--# checking for scope of global var
	try
		my check_file(BUNDLER_LOGFILE)
	on error
		set BUNDLER_LOGFILE to my formatter((DATA_DIR & "/logs/bundler-{}.log"), BUNDLER_VERSION)
		my check_file(BUNDLER_LOGFILE)
	end try
	delay 0.1 -- delay to ensure IO action is completed
	--# Prepare time string format %Y-%m-%d %H:%M:%S
	set log_time to "[" & (my date_formatter()) & "]"
	set formatterted_time to text items 1 thru -4 of (time string of (current date)) as string
	set error_time to "[" & formatterted_time & "]"
	--# Prepare location message
	set _location to "[bundler.scpt:" & _handler & "]"
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
	set {year:y, month:m, day:d} to current date
	set date_num to (y * 10000 + m * 100 + d) as string
	set formatterted_date to ((text 1 thru 4 of date_num) & "-" & (text 5 thru 6 of date_num) & "-" & (text 7 thru 8 of date_num))
	set formatterted_time to text items 1 thru -4 of (time string of (current date)) as string
	return formatterted_date & space & formatterted_time
end date_formatter

on _read_file(target_file)
	open for access POSIX file target_file
	set _contents to (read target_file)
	close access target_file
	return _contents
end _read_file

on prepare_cmd(cmd)
	set pwd to quoted form of (my pwd())
	return "cd " & pwd & "; bash " & cmd
end prepare_cmd


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
on pwd()
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end pwd

on dirname(_file)
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of _file as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end dirname

on check_dir(_folder)
	if not my folder_exists(_folder) then
		do shell script "mkdir -p " & (quoted form of _folder)
	end if
	return _folder
end check_dir

on check_file(_path)
	if not my file_exists(_path) then
		set _dir to dirname(_path)
		my check_dir(_dir)
		delay 0.1
		do shell script "touch " & (quoted form of _path)
	end if
end check_file

--#  handler to check if a folder exists
on folder_exists(_folder)
	if my path_exists(_folder) then
		tell application "System Events"
			return (class of (disk item _folder) is folder)
		end tell
	end if
	return false
end folder_exists

--# handler to check if a file exists
on file_exists(_file)
	if my path_exists(_file) then
		tell application "System Events"
			return (class of (disk item _file) is file)
		end tell
	end if
	return false
end file_exists

--#  handler to check if a path exists
on path_exists(_path)
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

on split(str, delimiter)
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
end split

--# format string á la Python
on formatter(str, arg)
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
on trim(str)
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
end trim

on joiner(pieces, delim)
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
on is_empty(str)
	if {true, false} contains str then return false
	if str is missing value then return true
	return length of (my trim(str)) is 0
end is_empty

--TESTING!!
on test()
	set as_pwd to POSIX path of (path to me) as string
	set pwd to quoted form of my dirname(as_pwd)
	set cmd to quoted form of "/Users/smargheim/Documents/DEVELOPMENT/GitHub/alfred-bundler/bundler/bundlets/TEST.sh"
	set sh_pwd to do shell script "cd " & pwd & "; bash " & cmd
	return "Applescript PWD: " & as_pwd & return & "Shell PWD: " & sh_pwd
end test