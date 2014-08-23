global B
set B to my _load_bundler()

(* ///
MAIN API FUNCTIONS
/// *)

on load_utility(_name, _version, _json)
	return B's load_utility(_name, _version, _json)
end load_utility

on get_icon(_font, _name, _color, _alter)
	return B's get_icon(_font, _name, _color, _alter)
end get_icon


(* ///
SUB-API FUNCTIONS
/// *)

on _bootstrap()
	(*Check if bundler bash bundlet is installed and install it if not.

    	:returns: ``None``

    	*)
	
	if the_bundler is not equal to missing value then
		return true
	else
		--# Create local directories if they don't exist
		repeat with dirpath in {B's HELPER_DIR, B's CACHE_DIR, B's COLOR_CACHE}
			if B's _folder_exists(dirpath) = false then
				B's _log("_bootstrap", "INFO", B's _format("Creating directory `{}`", (dirpath as string)))
				B's _check_dir(dirpath)
			else
				
			end if
		end repeat
		
		if B's _file_exists(B's BUNDLER_AS_LIB) = false then
			--# Install bundler
			B's _log("_bootstrap", "INFO", B's _format("Installing Alfred Dependency Bundler version `{}`", B's BUNDLER_VERSION))
			set bundlet_path to B's CACHE_DIR & "/bundlet-temp.sh"
			set bash_code to B's _format("source \"{}\"", bundlet_path)
			try
				my _download(B's BASH_BUNDLET_URL, bundlet_path)
			on error emsg number num
				set msg to "Error downloading `" & B's BASH_BUNDLET_URL & "` to `{}`"
				B's _log("_bootstrap", "DEBUG", B's _format(msg, bundlet_path))
				error emsg number num
			end try
			B's _log("_bootstrap", "INFO", B's _format("Executing script : `{}`", bash_code))
			return bash_code
		else
			--log and return error
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
	B's _log("_download", "INFO", B's _format("Opening URL `{}` ...", _url))
	--# Ensure full path to file exists
	B's _check_file(_filepath)
	delay 0.1
	--# Get HTTP response headers
	set cmd to "curl -I " & _url
	try
		set headers to do shell script cmd
		set headers to B's _split(headers, ASCII character 13)
		B's _log("_download", "INFO", B's _format("HTTP Response [{}] ...", item 1 of headers))
		--# Only download if HTTP response code 200 OK
		if item 1 of headers contains "200" then
			try
				--# Download bash bundlet from GitHub
				set cmd to "curl -v -o " & (quoted form of _filepath) & space & _url
				B's _log("_download", "INFO", B's _format("Downloading `{}` ...", _url))
				set response to do shell script cmd
				B's _log("_download", "INFO", B's _format("Saved `{}`", _filepath))
				return response
			on error msg number num
				set error_msg to "Applescript Error: <" & msg & "> Number: [" & num & "]"
				B's _log("_download", "DEBUG", error_msg)
				error msg number num
			end try
		else
			error B's _log("_download", "DEBUG", B's _format("Error retrieving URL. Server returned {}", item 1 of headers))
		end if
	on error msg number num
		set error_msg to "Applescript Error: <" & msg & "> Number: [" & num & "]"
		B's _log("_download", "DEBUG", error_msg)
		error msg number num
	end try
end _download


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
