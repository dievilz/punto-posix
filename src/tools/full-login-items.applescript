#!/usr/bin/osascript
#
# Little script to set Login Items

# "¬" character tells osascript that the line continues
set login_item_list to {"Memory Clean 2","Magnet","Clipy","LyricsX","Karabiner-Elements","Statusfy","MacMediaKeyForwarder","CheatSheet","Soundflower","Dropbox"}


repeat with login_item in login_item_list
    tell application "System Events"
        make login item with properties {name: login_item, path: ("/Applications/" & login_item & ".app")}
    end tell
end repeat
