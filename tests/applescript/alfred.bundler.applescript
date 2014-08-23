property BUNDLER_VERSION : "devel"
property _home : POSIX path of (path to "cusr" as text)
property BUNDLER_DIR : (_home) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION

(* MAIN API FUNCTION *)
my _bundler_exists()

on load_bundler()
	if (my _folder_exists(BUNDLER_DIR)) is not equal to true then
		my _bootstrap()
	end if
	set applescript_test_dir to (my _pwd())
	set test_dir to (my _dirname(applescript_test_dir))
	set BUNDLER_DIR to (my _dirname(test_dir))
	set as_bundler to (BUNDLER_DIR & "bundler/AlfredBundler.scpt")
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
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd

on _prepare_cmd(_cmd)
	set pwd to quoted form of (my _pwd())
	set testing_var to "export AB_BRANCH=devel; "
	--#TODO: remove for final release
	return testing_var & "cd " & pwd & "; bash " & _cmd
end _prepare_cmd

on _dirname(_file)
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -3 of _file as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _dirname

on _folder_exists(_folder)
	if my _path_exists(_folder) then
		tell application "System Events"
			return (class of (disk item _folder) is folder)
		end tell
	end if
	return false
end _folder_exists

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

on _is_empty(str)
	if {true, false} contains str then return false
	if str is missing value then return true
	return length of (my _trim(str)) is 0
end _is_empty

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