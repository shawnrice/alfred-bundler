--# Current Alfred-Bundler version
property BUNDLER_VERSION : "devel"
--# Path to user's home directory
property _home : POSIX path of (path to "cusr" as text)
--# Path to Alfred-Bundler's root directory
property BUNDLER_DIR : (_home) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION

(* MAIN API FUNCTION *)

on load_bundler()
	(* Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).
	
	:returns: ``script object``
	
	*)
	--# Check if Alfred-Bundler is installed
	if (my _folder_exists(BUNDLER_DIR)) is not equal to true then
		--# install it if not
		my _bootstrap()
	end if
	--# Path to `AlfredBundler.scpt` in Alfed-Bundler directory
	set as_bundler to (BUNDLER_DIR & "/bundler/AlfredBundler.scpt")
	--# Return script object
	return load script as_bundler
end load_bundler

(* AUTO-DOWNLOAD BUNDLER *)

on _bootstrap()
	(* Check if bundler bash bundlet is installed and install it if not.

    	:returns: ``None``
		
    	*)
	set shell_bundlet to quoted form of ((my _pwd()) & "alfred.bundler.sh")
	set shell_cmd to shell_bundlet & " utility CocoaDialog"
	set cmd to my _prepare_cmd(shell_cmd)
	do shell script cmd
	return true
end _bootstrap

(* HELPER HANDLERS *)

on _pwd()
	(* Get path to "present working directory", i.e. the workflow's root directory.

    	:returns: ``string`` (POSIX path)
		
    	*)
	--# Save default AS delimiters, and set delimiters to "/"
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	--# Get POSIX path of script's directory
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	--# Reset AS delimiters to original values
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd

on _prepare_cmd(_cmd)
	(* Ensure shell `_cmd` is working from the property directory.
	For testing purposes, it also sets the `AB_BRANCH` environmental variable.
	
	:param _cmd: Shell command to be run in `do shell script`
    	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
    	:returns: ``string``
		
    	*)
	--# Ensure `pwd` is properly quoted for shell command
	set pwd to quoted form of (my _pwd())
	--# Declare environmental variable
	--#TODO: remove for final release
	set testing_var to "export AB_BRANCH=devel; "
	--# return shell script where `pwd` is properly set
	return testing_var & "cd " & pwd & "; bash " & _cmd
end _prepare_cmd

on _folder_exists(_folder)
	(* Return ``true`` if `_folder` exists, else ``false``
	
	:param _folder: Full path to directory
    	:type _folder: ``string`` (POSIX path)
    	:returns: ``Boolean``
		
    	*)
	if my _path_exists(_folder) then
		tell application "System Events"
			return (class of (disk item _folder) is folder)
		end tell
	end if
	return false
end _folder_exists

on _path_exists(_path)
	(* Return ``true`` if `_path` exists, else ``false``
	
	:param _path: Any POSIX path (file or folder)
    	:type _path: ``string`` (POSIX path)
    	:returns: ``Boolean``
		
    	*)
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

on _is_empty(_obj)
	(* Return ``true`` if `_obj ` is empty, else ``false``
	
	:param _obj: Any Applescript type
    	:type _obj: (optional)
    	:returns: ``Boolean``
		
    	*)
	--# Is `_obj ` a ``Boolean``?
	if {true, false} contains _obj then return false
	--# Is `_obj ` a ``missing value``?
	if _obj is missing value then return true
	--# Is `_obj ` a empty string?
	return length of (my _trim(_obj)) is 0
end _is_empty

on _trim(_str)
	(* Remove white space from beginning and end of `_str`
	
	:param _str: A text string
    	:type _str: ``string``
    	:returns: trimmed string
		
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
end _trim