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

on run argv
	-- Handle command-line arguments when app is launched with args
	if (count of argv) > 0 then
		try
			-- Get the script path from the app bundle's Resources
			set scriptAlias to (path to resource "nvim_url.sh")
			set scriptPath to POSIX path of scriptAlias

			-- Ensure the script is executable
			try
				do shell script "/bin/chmod +x " & quoted form of scriptPath
			end try

			-- Build the command with all arguments
			set cmdArgs to ""
			repeat with arg in argv
				set cmdArgs to cmdArgs & " " & quoted form of arg
			end repeat

			-- Pass all arguments to the bash script
			do shell script "/bin/bash -lc " & quoted form of (quoted form of scriptPath & cmdArgs & " >/dev/null 2>&1 &")

		on error errMsg
			display alert "Error processing arguments: " & errMsg
		end try
	end if
end run

on open theFiles
	-- Handle "Open With..." from Finder or 
  -- when files are passed via `open` cmd line
	try
		-- Get the script path from the app bundle's Resources
		set scriptAlias to (path to resource "nvim_url.sh")
		set scriptPath to POSIX path of scriptAlias

		-- Ensure the script is executable
		try
			do shell script "/bin/chmod +x " & quoted form of scriptPath
		end try

		-- Try to get command-line arguments from the process
		set extraArgs to ""
		try
			-- Get our own process ID and command line
			set myPid to do shell script "echo $$"
			
			-- Get the applet process command line (look for the applet binary, not the shell)
			set cmdLine to do shell script "ps -p " & myPid & " -o command= 2>/dev/null || ps aux | grep -i 'Contents/MacOS/applet' | grep -v grep | head -1 | sed 's/^.*Contents\\/MacOS\\/applet/\\/Contents\\/MacOS\\/applet/' || echo ''"
			
			-- If that didn't work, try to find the applet process by name
			if cmdLine is "" or cmdLine does not contain "applet" then
				set cmdLine to do shell script "ps aux | grep -i 'Contents/MacOS/applet' | grep -v grep | head -1 | awk '{for(i=11;i<=NF;i++) printf \"%s \", $i; print \"\"}' || echo ''"
			end if
			
			-- Extract arguments that come after the applet path
			-- The format is: /path/to/applet [args...]
			-- We want to extract everything after "applet "
			if cmdLine contains "applet " then
				set oldDelims to AppleScript's text item delimiters
				set AppleScript's text item delimiters to "applet "
				set cmdParts to text items of cmdLine
				if (count of cmdParts) > 1 then
					set argsString to item 2 of cmdParts
					-- Clean up the args string
					set argsString to do shell script "echo " & quoted form of argsString & " | xargs"
					if argsString is not "" then
						set extraArgs to " " & argsString
					end if
				end if
				set AppleScript's text item delimiters to oldDelims
			end if
		end try

		-- Process each file
		repeat with aFile in theFiles
			set filePath to POSIX path of aFile
			-- Pass file path and any extra arguments to the bash script
			do shell script "/bin/bash -lc " & quoted form of (quoted form of scriptPath & " " & quoted form of filePath & extraArgs & " >/dev/null 2>&1 &")
		end repeat

	on error errMsg
		display alert "Error opening file: " & errMsg
	end try
end open

