global bundler
--One line version of loading the Alfred Bundler into a workflow script
set bundler to (load script (my _pwd()) & "alfred.bundler.scpt")'s load_bundler()
--Two line version (for clarity's sake)
--set bundlet to load script (my _pwd()) & "alfred.bundler.scpt"
--set bundler to bundlet's load_bundler()


(* TESTS *)

on library_tests()
	set url_er to bundler's library("_url", "", "")
	url_er's urlEncode("hello world")
end library_tests

on utility_tests()
	--load utility with no other info
	bundler's load_utility("pashua", "", "")
end utility_tests

on icon_tests()
	bundler's icon("octicons", "markdown", "000", true)
end icon_tests
--

on _pwd()
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd