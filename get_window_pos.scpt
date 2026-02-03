tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
    log "Frontmost application: " & frontApp
    if frontApp contains "Safari" or frontApp contains "Chrome" or frontApp contains "Firefox" or frontApp contains "Edge" then
        tell process frontApp
            set windowPos to position of front window
            set windowSize to size of front window
            log "Window position: " & item 1 of windowPos & ", " & item 2 of windowPos
            log "Window size: " & item 1 of windowSize & ", " & item 2 of windowSize
        end tell
    end if
end tell
