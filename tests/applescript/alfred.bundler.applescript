--# Current Alfred-Bundler version
property BUNDLER_VERSION : "devel"
--# Path to Alfred-Bundler's root directory
on get_bundler_dir()
	return (POSIX path of (path to home folder as text)) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
end get_bundler_dir
--# Path to Alfred-Bundler's cache directory
on get_cache_dir()
	return (POSIX path of (path to home folder as text)) & "Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION
end get_cache_dir

(* MAIN API FUNCTION *)



on load_bundler()
	(* Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).

	:returns: the script object of `AlfredBundler.scpt`
	:rtype: ``script object``

	*)
	set BUNDLER_DIR to my get_bundler_dir()
	--# Check if Alfred-Bundler is installed
	if (my _folder_exists(BUNDLER_DIR)) is not equal to true then
		--# install it if not
		my _bootstrap()
	end if
	delay 0.1
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
	--# Ask to install the Bundler
	set BUNDLER_DIR to my get_bundler_dir()
	set CACHE_DIR to my get_cache_dir()
	try
		my _install_confirmation()
	on error
		--# Cannot continue to install the bundler, so stop
		return false
	end try
	--# Download the bundler
	set URLs to {"https://github.com/shawnrice/alfred-bundler/archive/" & BUNDLER_VERSION & ".zip", "https://bitbucket.org/shawnrice/alfred-bundler/get/" & BUNDLER_VERSION & ".zip"}
	--# Save Alfred-Bundler zipfile to this location temporarily
	set _zipfile to (quoted form of CACHE_DIR) & "/installer/bundler.zip"
	repeat with _url in URLs
		set _status to (do shell script "curl -fsSL --create-dirs --connect-timeout 5 " & _url & " -o " & _zipfile & " && echo $?")
		if _status is equal to "0" then exit repeat
	end repeat
	--# Could not download the file
	if _status is not equal to "0" then error "Could not download bundler install file" number 21
	--# Ensure directory tree already exists for bundler to be moved into it
	my _check_dir(BUNDLER_DIR)
	--# Unzip the bundler and move it to its data directory
	set _cmd to "cd " & (quoted form of CACHE_DIR) & "; cd installer; unzip -qo bundler.zip; mv ./*/bundler " & (quoted form of BUNDLER_DIR)
	do shell script _cmd
	--# Wait until bundler is fully unzipped and written to disk before finishing
	set as_bundler to (BUNDLER_DIR & "/bundler/AlfredBundler.scpt")
	repeat while not (my _path_exists(as_bundler))
		delay 0.2
	end repeat
	tell application "Finder" to delete (POSIX file CACHE_DIR as alias)
	return
end _bootstrap

--# Function to get confirmation to install the bundler
on _install_confirmation()
	(* Ask user for permission to install Alfred-Bundler. 
	Allow user to go to website for more information, or even to cancel download.

	:returns: ``True`` or raises Error

	*)
	--# Get path to workflow's `info.plist` file
	set _plist to my _pwd() & "info.plist"
	--# Get name of workflow's from `info.plist` file
	set _cmd to "/usr/libexec/PlistBuddy -c 'Print :name' '" & _plist & "'"
	set _name to do shell script _cmd
	--# Get workflow's icon, or default to system icon
	set _icon to my _pwd() & "icon.png"
	set _icon to my _check_icon(_icon)
	--# Prepare explanation text for dialog box
	set _text to _name & " needs to install additional components, which will be placed in the Alfred storage directory and will not interfere with your system.

You may be asked to allow some components to run, depending on your security settings.

You can decline this installation, but " & _name & " may not work without them. There will be a slight delay after accepting."
	
	set _response to button returned of (display dialog _text buttons {"More Info", "Cancel", "Proceed"} default button 3 with title "Setup " & _name with icon POSIX file _icon)
	--# If permission granted, continue download
	if _response is equal to "Proceed" then return true
	--# If more info requested, open webpage and error
	if _response is equal to "More Info" then
		tell application "System Events"
			open location "https://github.com/shawnrice/alfred-bundler/wiki/What-is-the-Alfred-Bundler"
		end tell
		error "User looked sought more information" number 23
	end if
	--# If permission denied, stop and error
	if _response is equal to "Cancel" then error "User canceled bundler installation" number 23
end _install_confirmation


(* HELPER HANDLERS *)

on _pwd()
	(* Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

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
	:rtype: ``string``
		
	*)
	--# Ensure `pwd` is properly quoted for shell command
	set pwd to quoted form of (my _pwd())
	--# Declare environmental variable
	--#TODO: remove for final release
	set testing_var to "export AB_BRANCH=devel; "
	--# return shell script where `pwd` is properly set
	return testing_var & "cd " & pwd & "; bash " & _cmd
end _prepare_cmd

on _check_icon(_icon)
	(* Check if `_icon` exists, and if not revert to system download icon.

	:returns: POSIX path to `_icon`
	:rtype: ``string`` (POSIX path)

	*)
	try
		POSIX file _icon as alias
		return _icon
	on error
		return "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDownloadsFolder.icns"
	end try
end _check_icon

on _check_dir(_folder)
	(* Check if `_folder` exists, and if not create it, including any sub-directories.

	:returns: POSIX path to `_folder`
	:rtype: ``string`` (POSIX path)

	*)
	if not my _folder_exists(_folder) then
		do shell script "mkdir -p " & (quoted form of _folder)
	end if
	return _folder
end _check_dir


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