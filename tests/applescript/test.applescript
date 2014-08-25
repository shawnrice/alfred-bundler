on _home()
	return POSIX path of (path to home folder as text)
end _home

on _bundler()
	--One line version of loading the Alfred Bundler into a workflow script
	set bundler to (load script (my _pwd()) & "alfred.bundler.scpt")'s load_bundler()
	--Two line version (for clarity's sake)
	--set bundlet to load script (my _pwd()) & "alfred.bundler.scpt"
	--set bundler to bundlet's load_bundler()
end _bundler

my _bundler()'s icon("octicons", "book", "", "")
(*
my library_tests()
my utility_tests()
my icon_tests()
*)


(* TESTS *)

on library_tests()
	my library_valid_name() = true
	my library_valid_version() = true
	my library_invalid_name() = true
	return true
end library_tests

on utility_tests()
	my utility_valid_latest_version() = true
	my utility_valid_no_version() = true
	my utility_valid_old_version() = true
	my utility_invalid_name() = true
	return true
end utility_tests

on icon_tests()
	my icon_invalid_font() = true
	my icon_invalid_character() = true
	my icon_invalid_color() = true
	my icon_valid_color() = true
	my icon_altered_color() = true
	my icon_unaltered_color() = true
	my icon_invalid_system_icon() = true
	my icon_valid_system_icon() = true
	return true
end icon_tests


(* ICON TESTS *)

on icon_invalid_system_icon()
	set icon_path to my _bundler()'s icon("system", "WindowLicker", "", "")
	if icon_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/bundler/meta/icons/default.icns") then
		return true
	else
		error "Wrong path to invalid system icon: " & icon_path
	end if
end icon_invalid_system_icon

on icon_valid_system_icon()
	set icon_path to my _bundler()'s icon("system", "Accounts", "", "")
	if icon_path is equal to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Accounts.icns" then
		return true
	else
		error "Wrong path to valid system icon: " & icon_path
	end if
end icon_valid_system_icon

on icon_unaltered_color()
	set icon_path to my _bundler()'s icon("octicons", "markdown", "000", false)
	if icon_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/icons/octicons/000000/markdown.png") then
		return true
	else
		error "Wrong path to unaltered icon: " & icon_path
	end if
end icon_unaltered_color

on icon_altered_color()
	set icon_path to my _bundler()'s icon("octicons", "markdown", "000", true)
	if icon_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/icons/octicons/ffffff/markdown.png") then
		return true
	else
		error "Wrong path to altered icon: " & icon_path
	end if
end icon_altered_color

on icon_valid_color()
	set icon_path to my _bundler()'s icon("fontawesome", "adjust", "fff", "")
	if icon_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/icons/fontawesome/ffffff/adjust.png") then
		return true
	else
		error "Wrong path to valid icon: " & icon_path
	end if
end icon_valid_color

on icon_invalid_color()
	try
		my _bundler()'s icon("fontawesome", "adjust", "hubbahubba", "")
	on error msg number num
		--proper error
		if num = 1 then
			if msg contains "Hex color" then
				--proper error
				return true
			else
				error "Wrong error message: " & msg
			end if
		else
			error "Wrong error number: " & num & msg
		end if
	end try
end icon_invalid_color

on icon_invalid_character()
	try
		my _bundler()'s icon("fontawesome", "banditry!", "", "")
	on error msg number num
		--proper error
		if num = 1 then
			if msg contains "404" then
				--proper error
				return true
			else
				error "Wrong error message: " & msg
			end if
		else
			error "Wrong error number: " & num
		end if
	end try
end icon_invalid_character

on icon_invalid_font()
	try
		my _bundler()'s icon("spaff", "adjust", "", "")
	on error msg number num
		--proper error
		if num = 1 then
			if msg contains "404" then
				--proper error
				return true
			else
				error "Wrong error message: " & msg
			end if
		else
			error "Wrong error number: " & num
		end if
	end try
end icon_invalid_font


(* UTILITY TESTS *)

on utility_invalid_name()
	try
		my _bundler()'s utility("terminalnotifier", "", "")
	on error msg number num
		if num = 11 then
			if msg contains "command not found" then
				--proper error
				return true
			else
				error "Wrong error message: " & msg
			end if
		else
			error "Wrong error number: " & num
		end if
		
	end try
end utility_invalid_name

on utility_valid_old_version()
	set util_path to my _bundler()'s utility("pashua", "1.0", "")
	if util_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/utility/pashua/1.0/Pashua.app/Contents/MacOS/Pashua") then
		return true
	else
		error "Wrong path to valid utility: " & util_path
	end if
end utility_valid_old_version

on utility_valid_latest_version()
	set util_path to my _bundler()'s utility("pashua", "latest", "")
	if util_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/utility/pashua/latest/Pashua.app/Contents/MacOS/Pashua") then
		return true
	else
		error "Wrong path to valid utility: " & util_path
	end if
end utility_valid_latest_version

on utility_valid_no_version()
	set util_path to my _bundler()'s utility("pashua", "", "")
	if util_path is equal to (my _home() & "Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/utility/pashua/latest/Pashua.app/Contents/MacOS/Pashua") then
		return true
	else
		error "Wrong path to valid utility: " & util_path
	end if
end utility_valid_no_version


(* LIBRARY TESTS *)

on library_invalid_name()
	try
		my _bundler()'s library("hello", "", "")
	on error msg number num
		if num = 11 then
			if msg contains "command not found" then
				--proper error
				return true
			else
				error "Wrong error message: " & msg
			end if
		else
			error "Wrong error number: " & num
		end if
	end try
end library_invalid_name

on library_valid_version()
	set list_er to my _bundler()'s library("_list", "latest", "")
	if list_er's isAllOfClass({1, 2, 3}, integer) = true then
		return true
	else
		error "Library function did not act properly."
	end if
end library_valid_version


on library_valid_name()
	set url_er to my _bundler()'s library("_url", "", "")
	if url_er's urlEncode("hello world") = "hello%20world" then
		return true
	else
		error "Library function did not act properly."
	end if
end library_valid_name

--

on _pwd()
	set {ASTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
	set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string) & "/"
	set AppleScript's text item delimiters to ASTID
	return _path
end _pwd