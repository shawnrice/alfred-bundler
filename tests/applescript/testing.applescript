set bundler to load script (my _pwd()) & "alfred.bundler.scpt"


bundler's get_icon("octicons", "markdown", "000", true)
bundler's load_utility("pashua", "", "")

on _pwd()
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd