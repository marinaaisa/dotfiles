-- Open Mail app if it's closed
tell application "Mail"
    activate
end tell
-- Open Mail preferences
tell application "System Events"
    tell process "Mail"
        set frontmost to true
        delay 1

        -- Open Mail preferences
        keystroke "," using command down
        delay 2 -- Increase the delay to ensure the preferences window is fully loaded

        -- Navigate to the "Viewing" tab
        click button "Viewing" of toolbar 1 of window 1
        delay 1

        -- Set List Preview to "None"
        try
            click pop up button "List preview:" of group 1 of group 1 of window "Viewing"
            delay 0.5 -- Add a slight delay to allow the menu to appear
            click menu item "None" of menu 1 of pop up button "List preview:" of group 1 of group 1 of window "Viewing"
        on error errMsg
            display dialog "Error: " & errMsg
        end try
    end tell
end tell