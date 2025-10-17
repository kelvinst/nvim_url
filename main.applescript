on open location schemeUrl
	-- Save original delimiters
	set oldDelims to AppleScript's text item delimiters

	try
		-- Validate and extract the file path from the URL
		-- Split the URL on "nvim://file/" to separate protocol from path
		set AppleScript's text item delimiters to {"nvim://file/"}

		-- Check if we have at least 2 parts (before and after the delimiter)
		if (count of text items of schemeUrl) < 2 then error "Invalid URL format"

		-- Extract everything after "nvim://file/" (this is our file path with line number)
		-- For "nvim://file/path/to/file.txt:42", this gives us "path/to/file.txt:42"
		set filePath to item 2 of the text items of schemeUrl

		-- Get the script path from the app bundle's Resources
		set scriptAlias to (path to resource "nvim_url.sh")
		set scriptPath to POSIX path of scriptAlias

		-- Ensure the script is executable
		try
			do shell script "/bin/chmod +x " & quoted form of scriptPath
		end try

		-- Pass file path to the bash script
		do shell script "/bin/bash -lc " & quoted form of (quoted form of scriptPath & " " & quoted form of filePath & " >/dev/null 2>&1 &")

	on error errMsg
		display alert "Error processing URL: " & errMsg
	end try

	-- Restore original delimiters
	set AppleScript's text item delimiters to oldDelims
end open location

on open theFiles
	-- Handle "Open With..." from Finder
	try
		-- Get the script path from the app bundle's Resources
		set scriptAlias to (path to resource "nvim_url.sh")
		set scriptPath to POSIX path of scriptAlias

		-- Ensure the script is executable
		try
			do shell script "/bin/chmod +x " & quoted form of scriptPath
		end try

		-- Process each file
		repeat with aFile in theFiles
			set filePath to POSIX path of aFile
			-- Pass file path to the bash script
			do shell script "/bin/bash -lc " & quoted form of (quoted form of scriptPath & " " & quoted form of filePath & " >/dev/null 2>&1 &")
		end repeat

	on error errMsg
		display alert "Error opening file: " & errMsg
	end try
end open

