property BUNDLER_VERSION : "devel"
property _home : POSIX path of (path to "cusr" as text)
property BUNDLER_DIR : (_home) & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-" & BUNDLER_VERSION

(* MAIN API FUNCTION *)

on load_bundler()
	if (my _bundler_exists()) is not equal to true then
		my _bootstrap()
	end if
	set applescript_test_dir to my _pwd()
	set test_dir to my _dirname(applescript_test_dir)
	set BUNDLER_DIR to my _dirname(test_dir)
	set as_bundler to BUNDLER_DIR & "bundler/AlfredBundler.scpt"
	return load script as_bundler
end load_bundler

(* AUTO-DOWNLOAD BUNDLER *)

on _bootstrap()
	(*Check if bundler bash bundlet is installed and install it if not.

    	:returns: ``None``
    	*)
	set shell_bundlet to quoted form of (my _load_shell_bundlet())
	set shell_cmd to shell_bundlet & " utility CocoaDialog"
	set cmd to my _prepare_cmd(shell_cmd)
	do shell script cmd
	set the_bundler to true
end _bootstrap

(* HELPER HANDLERS *)

on _bundler_exists()
	try
		set _exists to B's _folder_exists(BUNDLER_DIR)
	on error
		set B to my _load_bundler()
		set _exists to B's _folder_exists(BUNDLER_DIR)
	end try
	return _exists
end _bundler_exists

on _load_shell_bundlet()
	set bundlet to (my _pwd()) & "alfred.bundler.sh"
end _load_shell_bundlet

on _prepare_cmd(cmd)
	set pwd to quoted form of (my _pwd())
	set testing_var to "export AB_BRANCH=devel; "
	return testing_var & "cd " & pwd & "; bash " & cmd
end _prepare_cmd

on _pwd()
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd

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