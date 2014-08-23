global B
set B to my _load_bundler()
property the_bundler : missing value

(* ///
MAIN API FUNCTIONS
/// *)

on load_utility(_name, _version, _json)
	if the_bundler is not equal to true then
		my _bootstrap()
	end if
	
	try
		set utility to B's load_utility(_name, _version, _json)
		return utility
	on error
		set B to my _load_bundler()
		try
			set utility to B's load_utility(_name, _version, _json)
			return utility
		on error
			set msg to "Error retrieving utility `" & _name & "`"
			B's _log("get_icon", "DEBUG", msg)
			error msg number num
		end try
	end try
end load_utility

on get_icon(_font, _name, _color, _alter)
	if the_bundler is not equal to true then
		my _bootstrap()
	end if
	
	try
		set icon to B's get_icon(_font, _name, _color, _alter)
		return icon
	on error
		set B to my _load_bundler()
		try
			set icon to B's get_icon(_font, _name, _color, _alter)
			return icon
		on error msg number num
			set msg to "Error retrieving icon `" & _font & "`'s `{}`"
			B's _log("get_icon", "DEBUG", B's _format(msg, _name))
			error msg number num
		end try
	end try
end get_icon


(* ///
SUB-API FUNCTIONS
/// *)

on _bootstrap()
	(*Check if bundler bash bundlet is installed and install it if not.

    	:returns: ``None``

    	*)
	--if the_bundler is not equal to missing value then
	--	return the_bundler
	--else
	set shell_bundlet to quoted form of (my _load_shell_bundlet())
	set shell_cmd to shell_bundlet & " utility CocoaDialog"
	set cmd to my _prepare_cmd(shell_cmd)
	do shell script cmd
	set the_bundler to true
	--end if
	
end _bootstrap


(* ///
HELPER FUNCTIONS
/// *)

on _load_bundler()
	set applescript_test_dir to my _pwd()
	set test_dir to my _dirname(applescript_test_dir)
	set bundler_dir to my _dirname(test_dir)
	set as_bundler to bundler_dir & "bundler/AlfredBundler.scpt"
	return load script as_bundler
end _load_bundler

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
