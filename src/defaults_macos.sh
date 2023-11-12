#!/bin/bash
#
# My personal macOS configuration
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

## INDEX
## ------------------------ LOCAL GLOBAL PREFERENCES -----------------------------------------------
## ----------------------- SYSTEM GLOBAL PREFERENCES -----------------------------------------------
## ---------------------- DESKTOP GENERAL PREFERENCES ----------------------------------------------
## ----------------------- MOUSE/TRACKPAD PREFERENCES ----------------------------------------------
## =================== $HOME/Library/Preferences/By Host =======================
## ---------------------------------- DOCK ---------------------------------------------------------
## --------------------------------- FINDER --------------------------------------------------------
## ------------------------ SYSTEM APPS PREFERENCES ------------------------------------------------
## --------------------------------- SAFARI --------------------------------------------------------
## ----------------------------- MACOS UPDATES -----------------------------------------------------
## -------------------------- OTHER APPS SETTINGS --------------------------------------------------
## ------------------------- HIDE THE ADMIN ACCOUNT ------------------------------------------------
## ------------------------ HOSTNAME & USER PICTURE ------------------------------------------------
## ------------------------------ NIGHT SHIFT ------------------------------------------------------
## ------------------------ ACTIVATE HIDDEN BINARIES -----------------------------------------------
## --------------------- DRDUH SECURITY & PRIVACY GUIDE --------------------------------------------
## --------------------------- TOOLS & UTILITIES ---------------------------------------------------

basic_settings_defaultsmacos() \
{
	bold "${B}–-->  Setting up Mac Custom Defaults..."

####################################################################################################
## ------------------------ LOCAL GLOBAL PREFERENCES -----------------------------------------------
####################################################################################################

	echo; option "---•-- LOCAL GLOBAL PREFERENCES --•------------------------------"
	echo

	subopt "Double click on window's title bar to: \"Maximize\"."
	defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"   ## "Minimize", "None"

	subopt "Set Anti Aliasing Threshold."
	defaults write NSGlobalDomain AppleAntiAliasingThreshold -int 4

	if [[ "$(uname -r)" == "2"* ]];     ## macOS Big Sur (20) or newer
	then
		subopt "macOS 11?: Apple Accent Color."
		defaults write NSGlobalDomain AppleAccentColor -int 4

		subopt "macOS 11?: Apple Aqua Color Variant."
		defaults write NSGlobalDomain AppleAquaColorVariant -int 1
	fi

	subopt "Disable MenuBar transparency."
	defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

	subopt "Disable mouse swipe navigation with scrolls."
	defaults write NSGlobalDomain AppleEnableMouseSwipeNavigateWithScrolls -bool false

	subopt "Enable swipe navigation with scrolls."
	defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true

	subopt "Enable subpixel font rendering on non-Apple LCDs."
	defaults write NSGlobalDomain AppleFontSmoothing -int 2

	subopt "Set custom Apple ICU Date Format Strings"
	defaults write NSGlobalDomain AppleICUDateFormatStrings -dict \
		1 -string "y/MM/dd" \
		2 -string "dd MMMM y" \
		3 -string "EEE, dd MMMM y" \
		4 -string "EEEE, dd MMMM y"

	subopt "Set custom Apple ICU Date Time Format Symbols." \
	"Note: Show AM/PM as \"am\" and \"pm\""
	defaults write NSGlobalDomain AppleICUDateTimeSymbols '{
			5 =     (
				am,
				pm
			);
		}'

	subopt "Set custom Apple ICU Date Time Format Strings."
	defaults write NSGlobalDomain AppleICUTimeFormatStrings -dict \
		1 -string "HH:mm:ss" \
		2 -string "hh:mm:ss a" \
		3 -string "hh:mm:ss a z" \
		4 -string "hh:mm:ss a zzzz"


	if [[ "$(uname -r)" == "2"* ]];     ## macOS Big Sur (20) or newer
	then
		subopt "macOS 11?: Set \"Blue\" as  Apple Highlight Color."
		defaults write NSGlobalDomain AppleHighlightColor -string \
			"0.698039 0.843137 1.000000 Blue"

		subopt "macOS 11?: Enable Apple ICU Force 12 Hour Time."
		defaults write NSGlobalDomain AppleICUForce12HourTime -bool true

		subopt "macOS 11?: Apple Interface Style."
		defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

		subopt "macOS 11 (Verified): Disallow wallpaper tinting in windows."
		defaults write NSGlobalDomain AppleReduceDesktopTinting -bool true
	fi

	subopt "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)."
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

	subopt "Set Languages and Region settings."
	defaults write NSGlobalDomain AppleLanguages -array "en-MX"
	defaults write NSGlobalDomain AppleLocale -string "en_MX"
	defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
	defaults write NSGlobalDomain AppleMetricUnits -bool true
	defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

	subopt "Miniaturize on the app icon in the Dock with double click."
	defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool true

	subopt "Disable press-and-hold for keys in favor of key repeat."
	defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

	subopt "Show all file extensions."
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true

	subopt "Always show scrollbars."
	defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

	subopt "Fix/Enable macOS Mojave Font Rendering Issue."
	defaults write NSGlobalDomain CGFontRenderingFontSmoothingDisabled -bool false

	subopt "Set a little fast key repeat."
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	defaults write NSGlobalDomain KeyRepeat -int 2

	subopt "Disable automatic capitalization"
	defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	subopt "Disable smart dashes"
	defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
	subopt "Disable automatic period substitution"
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
	subopt "Disable smart quotes"
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	subopt "Disable auto-correct"
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	subopt "Enable text-completion"
	defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool true

	subopt "Ask to keep changes when closing documents."
	defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true

	subopt "Disable automatic termination of inactive apps."
	defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

	subopt "Save to disk (not to iCloud) by default."
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

	subopt "Expand save panel by default."
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

	subopt "File (Last) List Mode For Open Mode"
	defaults write NSGlobalDomain NSNavPanelFileLastListModeForOpenModeKey -int 2
	defaults write NSGlobalDomain NSNavPanelFileListModeForOpenMode2 -int 2

	subopt "Set sidebar icon size to medium."
	defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

	subopt "Display ASCII control characters using caret notation in standard text views."
	## -Try e.g: `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
	defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

	subopt "Disable the over-the-top focus ring animation."
	defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false


	subopt "Remove Google S.E. as default Provider."
	if defaults read NSGlobalDomain NSPreferredWebServices 2> /dev/null ;
	then
		defaults delete NSGlobalDomain NSPreferredWebServices
	fi

	subopt "Remove Dictionary dumb predefined Replacements Items"
	if defaults read NSGlobalDomain NSUserDictionaryReplacementItems 2> /dev/null ;
	then
		defaults delete NSGlobalDomain NSUserDictionaryReplacementItems
	fi

	subopt "macOS 11?: Nav Panel File List Mode For Open Mode"
	defaults write NSGlobalDomain NavPanelFileListModeForOpenMode -int 2

	subopt "Expand print panel by default."
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

	subopt "Disable auto-correct (Global Prefs)."
	defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

	subopt "Add Developer context menu item for showing the Web Inspector in web views."
	defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

	subopt "Show Fast User Switching Menu as: \"Icon\"."
	defaults write NSGlobalDomain userMenuExtraStyle -int 2   ## 0:Full Name, 1:Username

	subopt "Always show the MenuBar."
	defaults write NSGlobalDomain _HIHideMenuBar -bool false
	echo


	subopt "Disable volume key feedback."
	defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 0

	subopt "Beep flash."
	defaults write NSGlobalDomain com.apple.sound.beep.flash -int 0


	if [ -f "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Audios/Ringtones/Bruh.m4r" ];
	then
		subopt "Beep sound set as Bruh.m4r."
		[ ! -e "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Audios/Ringtones/Bruh.m4r" ] \
		&& cp -v "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Audios/Ringtones/Bruh.m4r" \
		"/Library/Sounds/Bruh.m4r"

		defaults write NSGlobalDomain com.apple.sound.beep.sound -string \
		"/Library/Sounds/Bruh.m4r"
	else
		subopt "Beep sound set as Funk.aiff."
		defaults write NSGlobalDomain com.apple.sound.beep.sound -string "/System/Library/Sounds/Funk.aiff"
	fi

	subopt "Enable system sound."
	defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -bool true

	subopt "Set the spring loading delay for directories."
	defaults write NSGlobalDomain com.apple.springing.delay -float 0.5

	subopt "Enable spring loading for directories."
	defaults write NSGlobalDomain com.apple.springing.enabled -bool true










####################################################################################################
## ----------------------- SYSTEM GLOBAL PREFERENCES -----------------------------------------------
####################################################################################################

	echo
	echo; option "---•-- SYSTEM GLOBAL PREFERENCES --•-----------------------------"
	echo

	subopt "Enable the Fast User Switching Menu for multiple sessions."
	sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool true



	subopt "Enable firewall - Way #1."
	sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

	subopt "Disable guest account access to shared folders."
	sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool true



	subopt "Never Reveal IP address, hostname, OS version, and user when clicking" \
	"the clock in the login screen."
	if defaults read /Library/Preferences/com.apple.loginwindow AdminHostInfo 2> /dev/null ;
	then
	# s-udo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo -string "HostName"
	sudo defaults delete /Library/Preferences/com.apple.loginwindow AdminHostInfo
	fi

	subopt "Enable guest account login."
	sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool true

	subopt "Display login window as: Name and password."
	sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

	subopt "Show language menu in the top right corner of the login screen."
	sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true




	subopt "Enable HiDPI display modes (requires restart)."
	sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true




	subopt "Disable \"Restart automatically if the computer freezes\" - Won't work."
	sudo systemsetup -setrestartfreeze Off


	subopt "Do you want to enable/disable the Startup 'Chime'?"
	suboptq "Choose one option [${BO}'e'nable${NBO}|${BO}'d'isable${NBO}]" \
	"[press ${BO}Enter key${NBO} to halt]: "
	read -r resp
	case "$resp" \
	in
		e|E|enable|Enable|ENABLE)
			subopt "Enable good ol' Startup Chime."
			sudo nvram StartupMute=%00
			sudo nvram -d StartupMute
			sudo nvram -d SystemAudioVolume
		;;
		d|D|disable|Disable|DISABLE|"skip"|"none"|"")
			subopt "Disable good ol' Startup Chime."
			sudo nvram StartupMute=%01
			sudo nvram SystemAudioVolume=%80
		;;
		*)
			error "Invalid choice! Aborting..."
			exit 126
		;;
	esac
	unset resp


	subopt "Enforce System Hibernation."
	sudo pmset -a hibernatemode 25

	subopt "Disable Power Nap."
	sudo pmset -a powernap 0
	# sudo pmset -a standby 0
	# sudo pmset -a standbydelay 0
	# sudo pmset -a autopoweroff 0

	subopt "Disable local Time Machine backups."
	hash tmutil > /dev/null 2>&1 && sudo tmutil disablelocal



	# s-ubopt "Remove duplicates in the “Open With” menu." ## -Also see `lscleanup` alias
	# /-System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

	subopt "Create the locate database"
	sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist










####################################################################################################
## ---------------------- DESKTOP GENERAL PREFERENCES ----------------------------------------------
####################################################################################################

echo
echo; option "---•-- DESKTOP GENERAL PREFERENCES --•---------------------------"
echo

case "$(uname -r)" in
  1*)   ## macOS 19 or less
	trdopt "Make visible some Menu Extras in the MenuBar - Way #1."
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.appleuser" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.clock" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.textinput" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.airport" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.vpn" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.displays" -bool true

	trdopt "Make visible some Menu Extras in the MenuBar - Way #2."
	## All options: AirPort Displays Ink RemoteDesktop UniversalAccess WWAN Battery
	##              DwellControl IrDA "Script Menu" User iChat Bluetooth Eject
	##              PPP TextInput VPN Clock ExpressCard PPPoE TimeMachine Volume
	defaults write com.apple.systemuiserver menuExtras '(
		"/System/Library/CoreServices/Menu Extras/User.menu",
		"/System/Library/CoreServices/Menu Extras/Clock.menu",
		"/System/Library/CoreServices/Menu Extras/TextInput.menu",
		"/System/Library/CoreServices/Menu Extras/Battery.menu",
		"/System/Library/CoreServices/Menu Extras/AirPort.menu",
		"/System/Library/CoreServices/Menu Extras/Volume.menu",
		"/System/Library/CoreServices/Menu Extras/Bluetooth.menu",
		"/System/Library/CoreServices/Menu Extras/VPN.menu",
		"/System/Library/CoreServices/Menu Extras/Displays.menu",
	)'
  ;;
  2*)   ## macOS 20 or more
	trdopt "Make visible some Menu Extras in the MenuBar - Way #1."
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.appleuser" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.clock" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.textinput" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.airport" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.vpn" -bool true
	defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.displays" -bool true

	trdopt "Make visible some Menu Extras in the MenuBar - Way #2."
	## All options: AirPort Displays Ink RemoteDesktop UniversalAccess WWAN Battery
	##              DwellControl IrDA "Script Menu" User iChat Bluetooth Eject
	##              PPP TextInput VPN Clock ExpressCard PPPoE TimeMachine Volume
	defaults write com.apple.systemuiserver menuExtras '(
		"/System/Library/CoreServices/Menu Extras/User.menu",
		"/System/Library/CoreServices/Menu Extras/Clock.menu",
		"/System/Library/CoreServices/Menu Extras/TextInput.menu",
		"/System/Library/CoreServices/Menu Extras/Battery.menu",
		"/System/Library/CoreServices/Menu Extras/AirPort.menu",
		"/System/Library/CoreServices/Menu Extras/Volume.menu",
		"/System/Library/CoreServices/Menu Extras/Bluetooth.menu",
		"/System/Library/CoreServices/Menu Extras/VPN.menu",
		"/System/Library/CoreServices/Menu Extras/Displays.menu",
	)'
  ;;
  *)
	error "Invalid choice! Aborting..."
	echo; exit 126
  ;;
esac

subopt "Show Battery Percentage in Menu Bar Battery."
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
## d-efaults write com.apple.menuextra.battery '{ ShowPercent = YES; }'

subopt "Show day name and AM/PM with full time format on the Menu Bar Clock"
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM  h:mm:ss a"

subopt "Flash the time separators on the Menu Bar Clock"
defaults write com.apple.menuextra.clock FlashDateSeparators -bool true

subopt "Do not use the Analog Icon on the Menu Bar Clock"
defaults write com.apple.menuextra.clock IsAnalog -bool false

subopt "Set the screen to lock as soon as the screensaver starts."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# subopt "Set screensaver settings."
# defaults -currentHost write com.apple.screensaver moduleDict '{
#   displayName = "";
#   moduleName = "";
#   path = "/System/Library/Frameworks/ScreenSaver.framework/Resources/.saver";
#   type = 0;
# };'

subopt "Disable screensaver."
defaults -currentHost write com.apple.screensaver idleTime 0


killall SystemUIServer










####################################################################################################
## ----------------------- MOUSE/TRACKPAD PREFERENCES ----------------------------------------------
####################################################################################################

echo
echo; option "---•-- MOUSE/TRACKPAD PREFERENCES --•----------------------------"
echo

subopt "Adjusting the tracking speed of the mouse."
defaults write NSGlobalDomain com.apple.mouse.scaling -int 3

subopt "Enable tap to click in the pointer device for user and login screen."
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

subopt "Adjusting the scrolling speed of the mouse wheel."
defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 0.75


subopt "Enable Force Touch."
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true

subopt "Adjusting the tracking speed of the trackpad."
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875

subopt "Enable tap to click in the Magic Trackpad for this user and login screen."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true



## =================== $HOME/Library/Preferences/By Host =======================
## =============================================================================

subopt "1. Enable ${BO}Look up & data detectors${RE} ${IT}Gesture${RE} ${C}by \"Force Click with one Finger\"."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerTapGesture -int 0

subopt "1. Enable ${BO}Secondary Click${RE} ${C}for trackpad."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true


subopt "2. Enable ${BO}Natural Scroll${RE} ${C}direction."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.scrollBehavior -int 2

subopt "2. Enable ${BO}Momentum${RE} ${C}to the Scroll Gesture."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.momentumScroll -bool true

subopt "2. Enable ${BO}Zoom In/Out${RE} ${IT}Pinch Gesture${RE} ${C}with two fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.pinchGesture -bool true

subopt "2. Enable ${BO}Smart Zoom${RE} ${IT}Gesture${RE} ${C}with double-tap with two fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerDoubleTapGesture -int 1

subopt "2. Enable ${BO}Rotate${RE} ${IT}Gesture${RE} ${C}with two fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.rotateGesture -bool true


subopt "3. Enable ${BO}Page Switching${RE} ${IT}Swipe Gesture${RE} ${C}with three/two fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 2

subopt "3. Enable ${BO}Full-screen Apps Switching${RE} ${IT}Swipe Gesture${RE} ${C}with four/three fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerHorizSwipeGesture -int 2

subopt "3. Enable ${BO}Notification Center${RE} ${IT}Swipe Gesture${RE} ${C}from right edge with two fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 3

subopt "3. Enable ${BO}Mission Control${RE} ${IT}Swipe Gesture${RE} ${C}with four fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerVertSwipeGesture -int 2

subopt "3. Enable ${BO}Exposé${RE} ${IT}Swipe Gesture${RE} ${C}with three fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -int 2

subopt "3. Enable ${BO}Launchpad${RE} ${IT}Pinch Gesture${RE} ${C}with four fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fiveFingerPinchSwipeGesture -int 2

subopt "3. Enable ${BO}Show Desktop${RE} ${IT}Swipe Gesture${RE} ${C}with four fingers."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerPinchSwipeGesture -int 2

## s-ubopt "??????????????????????????????????????????????????????????????????."
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerDragGesture -bool false










####################################################################################################
## ---------------------------------- DOCK ---------------------------------------------------------
####################################################################################################

echo
echo; option "---•-- DOCK --•--------------------------------------------------"
echo

subopt "Disable \"Automatically hide and show the Dock\"."
defaults write com.apple.dock autohide -bool false

subopt "Enable spring loading for all Dock items."
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

subopt "Magnify the Dock."
defaults write com.apple.dock magnification -bool true

subopt "Minimize windows into Dock apps icons."
defaults write com.apple.dock minimize-to-application -bool true

subopt "Highlight stack items on hovering in the Dock."
defaults write com.apple.dock mouse-over-hilite-stack -bool true

subopt "– Setting the Persistent Apps in the Dock."
## Here would go a very long dictionary of apps, so I ain't gonna put it.
# d-efaults write com.apple.dock persistent-apps -array -dict

subopt "Do not show recent applications in Dock."
defaults write com.apple.dock show-recents -bool false

subopt "Enabling the Expose gesture."
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

subopt "Setting the Dock size."
defaults write com.apple.dock tilesize -float 41


subopt "Enable automatically rearrange Spaces based on recent use."
defaults write com.apple.dock mru-spaces -bool true

subopt "Enable auto-switching desktops."
defaults write com.apple.dock workspaces-auto-swoosh -bool true

subopt "Configure Hot Corners."
	## Bottom left screen corner → Launchpad
	# d-efaults write com.apple.dock wvous-bl-corner -int 11
	# d-efaults write com.apple.dock wvous-bl-modifier -int 0

	## Bottom right screen corner → Mission Control
	defaults write com.apple.dock wvous-br-corner -int 2
	defaults write com.apple.dock wvous-br-modifier -int 0


killall Dock










####################################################################################################
## --------------------------------- FINDER --------------------------------------------------------
####################################################################################################

echo
echo; option "---•-- FINDER --•------------------------------------------------"
echo

subopt "Show the $HOME/Library folder."
chflags nohidden "$HOME"/Library

subopt "Show hidden files by default."
defaults write com.apple.finder AppleShowAllFiles -bool true

subopt "Show item info near icons on the desktop and in other icon views."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" "$HOME"/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showIconPreview true" "$HOME"/Library/Preferences/com.apple.finder.plist
# defaults write com.apple.finder "DesktopViewSettings" -dict-add "IconViewSettings" '{ showItemInfo = 1; }'
# defaults write com.apple.finder "DesktopViewSettings" -dict-add "IconViewSettings" '{ showIconPreview = 1; }'

/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" "$HOME"/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" "$HOME"/Library/Preferences/com.apple.finder.plist


subopt "Enable snap-to-grid for icons on the desktop and in other icon views."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" "$HOME"/Library/Preferences/com.apple.finder.plist
# defaults write com.apple.finder "DesktopViewSettings" -dict-add "IconViewSettings" '{ arrangeBy = grid; }'
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" "$HOME"/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" "$HOME"/Library/Preferences/com.apple.finder.plist

subopt "Calculate all sizes on list views."
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:ListViewSettings:calculateAllSizes true" "$HOME"/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:ListViewSettings:calculateAllSizes true" "$HOME"/Library/Preferences/com.apple.finder.plist

subopt "Enable window animations and Get Info animations."
defaults write com.apple.finder DisableAllAnimations -bool false

subopt "Arrange groups by name."
defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"

subopt "Disable warning when changing a file extension."
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

subopt "Do not warn when moving files out of iCloud."
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false

subopt "Expand the following File Info panes: 'General', 'Open with', and 'Sharing & Permissions'."
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	Comments -bool true \
	General -bool true \
	MetaData -bool true \
	Name -bool true \
	OpenWith -bool true \
	Privileges -bool true

subopt "Always Arrange/Group by none"
defaults write com.apple.finder FXPreferredGroupBy -string "None"

subopt "Always search in list view."
defaults write com.apple.finder FXPreferredSearchViewStyle -string "Nlsv"

subopt "Always open in list view."
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

subopt "Remove old trash items."
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

subopt "Set a custom configuration for the Finder Toolbar items."
case "$(uname -r)" in
	1*)   ## macOS 19 or less
		defaults write com.apple.finder "NSToolbar Configuration Browser" '{
			"TB Default Item Identifiers" =     (
				"com.apple.finder.BACK",
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.SWCH",
				"com.apple.finder.ARNG",
				"com.apple.finder.ACTN",
				"com.apple.finder.SHAR",
				"com.apple.finder.LABL",
				NSToolbarFlexibleSpaceItem,
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.SRCH"
			);
			"TB Display Mode" = 1;
			"TB Icon Size Mode" = 1;
			"TB Is Shown" = 1;
			"TB Item Identifiers" =     (
				"com.apple.finder.BACK",
				"com.apple.finder.PATH",
				NSToolbarFlexibleSpaceItem,
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.SWCH",
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.TRSH",
				"com.apple.finder.NFLD",
				"com.apple.finder.ACTN",
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.SRCH",
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.LABL",
				"com.apple.finder.ARNG",
				"com.apple.finder.CNCT",
				"com.apple.finder.SHAR",
				NSToolbarFlexibleSpaceItem
			);
			"TB Size Mode" = 1;
		}'
	;;
		## NSToolbarFlexibleSpaceItem solo hace un padding incremental hacia la
		## derecha (sólo empuja hacia la derecha si hay más espacio horizontal visible)...
		## ...Por lo que puedo usar está configuración, si quiero que todos los grupos
		## intermedios se paddeen hacía la derecha con el NSToolbarFlexibleSpaceItem,
		## puedes jugar ahora agregando los NSToolbarFlexibleSpaceItem que desees
		## para encontrar la config perfecta
	2*)   ## macOS 20 or more
		defaults write com.apple.finder "NSToolbar Configuration Browser" '{
			"TB Default Item Identifiers" =     (
				"com.apple.finder.BACK",
				"com.apple.finder.SWCH",
				NSToolbarSpaceItem,
				"com.apple.finder.ARNG",
				"com.apple.finder.SHAR",
				"com.apple.finder.LABL",
				"com.apple.finder.ACTN",
				NSToolbarSpaceItem,
				"com.apple.finder.SRCH"
			);
			"TB Display Mode" = 1;
			"TB Icon Size Mode" = 1;
			"TB Is Shown" = 1;
			"TB Item Identifiers" =     (
				"com.apple.finder.BACK",
				"com.apple.finder.SWCH",
				"com.apple.finder.TRSH",
				"com.apple.finder.NFLD",
				"com.apple.finder.ACTN",
				NSToolbarSpaceItem,
				NSToolbarSpaceItem,
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.LABL",
				"com.apple.finder.ARNG",
				"com.apple.finder.CNCT",
				"com.apple.finder.SHAR",
				NSToolbarSpaceItem,
				NSToolbarSpaceItem,
				NSToolbarFlexibleSpaceItem,
				"com.apple.finder.SRCH"
				NSToolbarSpaceItem,
				NSToolbarSpaceItem,
				NSToolbarFlexibleSpaceItem
			);
			"TB Size Mode" = 1;
		}'
	;;
esac

subopt "Set Home as the default location for new Finder windows."
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

subopt "Automatically open a new Finder window when a volume is mounted."
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

subopt "Allow text selection in Quick Look."
defaults write com.apple.finder QLEnableTextSelection -bool true

subopt "Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons."
defaults write com.apple.finder QuitMenuItem -bool true

subopt "Always open Recents in list view ."
defaults write com.apple.finder SearchRecentsSavedViewStyle -string "Nlsv"

subopt "Show certain volumes on Desktop."
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

subopt "Always show the path bar."
defaults write com.apple.finder ShowPathbar -bool true

subopt "Never show the preview pane."
defaults write com.apple.finder ShowPreviewPane -bool false

subopt "Always show the sidebar."
defaults write com.apple.finder ShowSidebar -bool true

subopt "Always show the status bar."
defaults write com.apple.finder ShowStatusBar -bool true

subopt "Always show the tab bar."
if [[ "$(uname -r)" == "19"* ]]; then     ## macOS Catalina only
	defaults write com.apple.finder NSWindowTabbingShoudShowTabBarKey-com.apple.finder.TBrowserWindow -bool true

elif [[ "$(uname -r)" != "19"* ]]; then   ## macOS Mojave or older
	defaults write com.apple.finder ShowTabView -bool true
fi

subopt "Set the Sidebar Zone Order."
defaults write com.apple.finder SidebarZoneOrder1 -array "favorites" "devices" "icloud_drive" "tags"

subopt "Do not warn before emptying the trash."
defaults write com.apple.finder WarnOnEmptyTrash -bool false

subopt "Display full POSIX path as Finder window title."
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

subopt "Keep folders on top when sorting by name."
defaults write com.apple.finder _FXSortFoldersFirst -bool true

subopt "Keep Desktop folders on top when sorting by name."
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true

subopt "Show certain volumes on Finder's Sidebar."
defaults write com.apple.sidebarlists systemitems -dict-add ShowHardDisks -bool true
defaults write com.apple.sidebarlists systemitems -dict-add ShowEjectables -bool true
defaults write com.apple.sidebarlists systemitems -dict-add ShowRemovable -bool true
defaults write com.apple.sidebarlists systemitems -dict-add ShowServers -bool true

killall Finder










####################################################################################################
## ------------------------ SYSTEM APPS PREFERENCES ------------------------------------------------
####################################################################################################

echo
echo; option "---•-- SYSTEM APPS PREFERENCES --•-------------------------------"
echo

subopt "Visualize CPU usage in the Activity Monitor Dock icon."
defaults write com.apple.ActivityMonitor IconType -int 5

subopt "Show the main window when launching Activity Monitor."
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

subopt "Show all processes in Activity Monitor."
defaults write com.apple.ActivityMonitor ShowCategory -int 0

subopt "Sort Activity Monitor results by CPU usage."
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

subopt "Sorting contacts by first name in Address Book."
defaults write com.apple.AddressBook ABNameSortingFormat -string "sortingFirstName sortingLastName"

subopt "Increase sound quality for Bluetooth headphones/headsets."
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

subopt "Disable the crash reporter."
defaults write com.apple.CrashReporter DialogType -string "none"

subopt "Enable Advanced Image options in Disk Utility."
defaults write com.apple.DiskUtility advanced-image-options -bool true

subopt "Enable the debug menu in Disk Utility."
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true

subopt "Avoid creating .DS_Store files on network or USB volumes."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

subopt "Disable disk image verification."
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

subopt "Automatically open a new Finder window when a volume is mounted."
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

subopt "Prevent Photos from opening automatically when devices are plugged in."
defaults write com.apple.ImageCapture disableHotPlug -bool true

subopt "Disable the 'Are you sure you want to open this application?' dialog."
defaults write com.apple.LaunchServices LSQuarantine -bool false

subopt "Enable AirDrop over Ethernet and on unsupported Macs running Lion."
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

subopt "Limit the display time for notifications banners."
defaults write com.apple.notiificationcenterui bannerTime -int 300

subopt "Automatically quit printer app once the print jobs complete."
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

subopt "Don't auto-play videos when opened with QuickTime Player."
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool false

subopt "Disable the window shadow when capturing an entire window screenshot"
defaults write com.apple.screencapture disable-shadow -bool true

subopt "Save screenshots to the desktop."
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

subopt "Don't show Siri in the MenuBar."
defaults write com.apple.Siri StatusMenuVisible -bool false

subopt "Enable Secure Keyboard Entry in Terminal.app."
defaults write com.apple.Terminal SecureKeyboardEntry -bool true

subopt "Disable the annoying line marks in Terminal.app."
defaults write com.apple.Terminal ShowLineMarks -int 0

subopt "Only use UTF-8 in Terminal.app."
defaults write com.apple.Terminal StringEncodings -array 4

subopt "Open and save files as UTF-8 in TextEdit."
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

subopt "Use plain text mode for new TextEdit documents."
defaults write com.apple.TextEdit RichText -int 0

subopt "Prevent Time Machine from prompting to use new hard drives as backup volume."
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true










####################################################################################################
## --------------------------------- SAFARI --------------------------------------------------------
####################################################################################################

echo
echo; option "---•-- SAFARI --•------------------------------------------------"
echo

subopt "Show Safari’s bookmarks bar by default."
defaults write com.apple.Safari ShowFavoritesBar -bool true

subopt "Prevent Safari from opening ‘safe’ files automatically after downloading."
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

subopt "Set Safari’s home page to 'about:blank' for faster loading."
defaults write com.apple.Safari HomePage -string "about:blank"

subopt "Update extensions automatically."
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

subopt "Enable Do Not Track."
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

subopt "Show the full URL in the address bar (note: this still hides the scheme)."
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

subopt "Privacy: don’t send search queries to Apple."
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false

subopt "Warn about fraudulent websites."
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

subopt "Disable auto-correct."
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

subopt "Enable continuous spellchecking."
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

subopt "Press Tab to highlight each item on a web page."
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

subopt "Block pop-up windows."
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

subopt "Set up for development."
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

subopt "Customise Safari toolbar item."
defaults write com.apple.safari "NSToolbar Configuration BrowserToolbarIdentifier-v2" '{
	"TB Default Item Identifiers" =     (
		BackForwardToolbarIdentifier,
		SidebarToolbarIdentifier,
		NSToolbarFlexibleSpaceItem,
		InputFieldsToolbarIdentifier,
		NSToolbarFlexibleSpaceItem,
		ShareToolbarIdentifier,
		TabPickerToolbarIdentifier
	);
	"TB Display Mode" = 2;
	"TB Icon Size Mode" = 1;
	"TB Is Shown" = 1;
	"TB Item Identifiers" =     (
		NSToolbarFlexibleSpaceItem,
		InputFieldsToolbarIdentifier,
		NSToolbarFlexibleSpaceItem,
		ShareToolbarIdentifier
	);
	"TB Size Mode" = 1;
}'










####################################################################################################
## ----------------------------- MACOS UPDATES -----------------------------------------------------
####################################################################################################

echo
echo; option "---•-- UPDATES --•-----------------------------------------------"
echo

subopt "Enable Debug Menu in the Mac App Store."
defaults write com.apple.appstore ShowDebugMenu -bool true

subopt "Enable the automatic update check."
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

subopt "Download newly available updates in background."
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

subopt "Install System data files & security updates."
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

subopt "Automatically download apps purchased on other Macs."
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

subopt "Turn on app auto-update."
defaults write com.apple.commerce AutoUpdate -bool true

subopt "Disallow the App Store to reboot machine on macOS updates."
defaults write com.apple.commerce AutoUpdateRestartRequired -bool false










####################################################################################################
## -------------------------- OTHER APPS SETTINGS --------------------------------------------------
####################################################################################################

echo
echo; option "---•-- OTHER APPS --•--------------------------------------------"
echo

subopt "Load iTerm2 configuration from a predictable location."
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME"/.config/iterm2
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

subopt "Disable Google Chrome's Two Finger Back-Forward navigation.."
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.dev AppleEnableSwipeNavigateWithScrolls -bool false

subopt "Disable Google Chrome's Two Finger Back-Forward navigation"
defaults write org.gpgtools.common UseKeychain NO








####################################################################################################
## ------------------------- HIDE THE ADMIN ACCOUNT ------------------------------------------------
####################################################################################################

echo
echo; option "---•-- HIDE THE ADMIN ACCOUNT --•---------------------------------"
echo

subopt "Do you want to hide the admin account?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
case "$resp" in
	y|Y|yes|Yes)
		echo
		info "Remember that hiding the admin account only works with normal" \
		"and guests users using Finder."
		echo
		trdoptq "Please enter the username of the admin account: "
		read -r acUsername
		unset acUsername
		echo
		trdoptq "Please enter again the username of the admin account, just " \
		"to be sure: "
		read -r acUsername
		echo
		if [ -d /Users/"${acUsername}" ];
		then
			trdopt "Hiding the account of the admin..."
			sudo dscl . -create /Users/"${acUsername}" isHidden 1

			trdopt "Hiding the Home Directory of the admin..."
			sudo chflags hidden /Users/"${acUsername}"

			trdopt "Removing the Public Folder/Share Point of the admin..."
			sudo dscl . -delete "/SharePoints/"$(dscl . -read /Users/"${acUsername}" RealName \
			| awk -F "RealName: " '{print $2}')"'s Public Folder"

			unset acUsername
			warn "Probably the last command didn't work, so go to SysPrefs.app" \
			"> Sharing, select File Sharing and remove the folder from there..."
		else
			error "Invalid username! This username doesn't exist or doesn't" \
			"have \$HOME folder! Skipping..."
			echo
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp


## printf "%b" "${B}Type the username of the admin account to be demoted: ${RE}"
# read -r demotedAdminName
# s-udo dscl . -delete /Groups/admin GroupMembership "${demotedAdminName}"
# s-udo dscl . -delete /Groups/admin GroupMembers "$(dscl . -read /Users/"${demotedAdminName}" GeneratedUID | awk '{print $2}')"
# unset demotedAdminName

# dsscl . -change /Users/<myShortName> RealName <myShortName> <myNewShortName>
# s-udo dscl . -list "/SharePoints"

# dscl . -create
# dscl . -read
# dscl . -change
# dscl . -delete
# dscl . -list
# dscl . -search









####################################################################################################
## ------------------------ HOSTNAME & USER PICTURE ------------------------------------------------
####################################################################################################

echo
echo; option "---•-- [COMPUTER,HOST,LOCALHOST,REAL] NAME & USER PICTURE --•-------------------------------"
echo

subopt "Do you want to change the Computer Name for this Mac?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
case "$resp" in
	y|Y|yes|Yes)
		echo
		info "The Computer Name is the \"user-friendly\" one that will" \
		"appear in your iCloud's Devices List and in the \"Find My\" app."
		echo
		trdoptq "Enter the new Computer Name for this account: "
		read -r computerName
		unset computerName
		echo
		trdoptq "Please enter again the Computer Name, just to be sure: "
		read -r computerName
		echo
		if [ -n "$computerName" ];
		then
			sudo scutil --set ComputerName "$computerName" && \
			success "Computer Name successfully set!"
			unset computerName
		else
			warn "Undetected input! Skipping..."
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp
echo

subopt "Do you want to change the Hostname for this Mac?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
case "$resp" in
	y|Y|yes|Yes)
		echo
		info "The \"Hostname\" is the one assigned as visible from the terminal," \
		"used by local and remote network connections, like SSH or Remote Login."
		echo
		trdoptq "Enter the new Hostname for this account: "
		read -r hostName
		unset hostName
		echo
		trdoptq "Please enter again the Hostname, just to be sure: "
		read -r hostName
		echo
		if [ -n "$hostName" ];
		then
			sudo scutil --set HostName "$hostName" && \
			success "HostName successfully set!"
			unset hostName
		else
			warn "Undetected input! Skipping..."
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp
echo

subopt "Do you want to change the Local Hostname for this Mac?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
case "$resp" in
	y|Y|yes|Yes)
		echo
		info "The Local Hostname is the identifier used by Bonjour and file-" \
		"sharing services like AirDrop."
		echo
		trdoptq "Enter the new Local Hostname for this account:"
		read -r localHostname
		unset localHostname
		echo
		trdoptq "Please enter again the Local Hostname, just to be sure:"
		read -r localHostname
		echo
		if [ -n "$localHostname" ];
		then
			sudo scutil --set LocalHostName "$localHostname" && \
			success "Local HostName successfully set!"
			unset localHostname
		else
			warn "Undetected input! Skipping..."
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp
echo

subopt "Do you want to change the Real Name for this User?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
case "$resp" in
	y|Y|yes|Yes)
		echo
		info "The Real Name is the name of the owner of this account."
		echo
		trdoptq "Enter the new Real Name for this account:"
		read -r realName
		unset realName
		echo
		trdoptq "Please enter again the new Real Name, just to be sure:"
		read -r realName
		echo
		if [ -n "$realName" ];
		then
			sudo dscl . -change /Users/"${accountUsername}" RealName \
			"$(dscl . -read /Users/"${accountUsername}" RealName | awk -F "RealName: " '{print $2}')" "$realName" \
			&& success "Real Name successfully set!"
			unset realName
		else
			warn "Undetected input! Skipping..."
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp
echo

subopt "Do you want to change the NetBIOSName for this Mac?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
case "$resp" in
	y|Y|yes|Yes)
		# echo
		# info "Remember that the NetBIOSName is the one that will appear" \
		# "in ."
		echo
		trdoptq "Enter the new NetBIOSName for the system:"
		read -r netBiosName
		unset netBiosName
		echo
		trdoptq "Please enter again the NetBIOSName, just to be sure:"
		read -r netBiosName
		echo
		if [ -n "$netBiosName" ];
		then
			sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$netBiosName" \
			&& success "NetBIOS Name successfully set!"
			unset netBiosName
		else
			warn "Undetected input! Skipping..."
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp
echo

subopt "Get an User Picture and set it as the Account Picture"
suboptq "Choose one option [${BO}'u'rl${NBO}|${BO}'g'ravatar${NBO}|${BO}'l'ocal" \
"${NBO}][press ${BO}Enter key${NBO} to halt]: "
read -r resp
case "$resp" in
	u|U)
		echo
		{
			trdoptq "Enter the URL for the user picture:"
			read -r pfpURL
			unset pfpURL
			echo
			trdoptq "Please enter again the URL, just to be sure:"
			read -r pfpURL
			echo
			curl -o "$HOME"/Pictures/pfp.jpg "$pfpURL"
			dscl . -delete $HOME Picture
			dscl . -delete $HOME JPEGPhoto
			sudo dscl . -create $HOME Picture "$HOME"/Pictures/pfp.jpg
			unset pfpURL
		}
	;;
	g|G)
		echo
		{
			IFS=' ' read -r -a RECORD_NAME <<< $(dscl . -read $HOME RecordName)
			EMAIL="${RECORD_NAME[2]}"
			curl -o "$HOME"/Pictures/pfp.jpg \
			http://www.gravatar.com/avatar/$(md5 -q -s $EMAIL).jpg?s=600
			dscl . -delete $HOME Picture
			dscl . -delete $HOME JPEGPhoto
			sudo dscl . -create $HOME Picture "$HOME"/Pictures/pfp.jpg
		}
	;;
	l|L)
		echo
		trdoptq "Enter the full path for the profile picture:"
		read -r pfpPath
		echo
		trdoptq "Please enter again the full path, just to be sure:"
		read -r pfpPath
		echo
		if [ -e "$pfpPath" ]; then
			{
				dscl . -delete $HOME Picture
				dscl . -delete $HOME JPEGPhoto
				sudo dscl . -create $HOME Picture "$pfpPath"
			}
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp










####################################################################################################
## ------------------------------ NIGHT SHIFT ------------------------------------------------------
####################################################################################################

echo
echo; option "---•-- NIGHT SHIFT --•-------------------------------------------"
echo

subopt "Do you want to activate Night Shift with some awesome parameters?"
suboptq "Choose one option [${BO}'Y'es${NBO}|${BO}'n'o${NBO}][press ${BO}Enter " \
"key${NBO} to halt]: "
read -r resp
echo
case "$resp" in
	y|Y|yes|Yes)
		trdopt "Activating Night Shift."
		echo

		CORE_BRIGHTNESS="/var/root/Library/Preferences/com.apple.CoreBrightness.plist"

		ENABLE='{
			CBBlueLightReductionCCTTargetRaw = "3412.320";
			CBBlueReductionStatus =     {
				AutoBlueReductionEnabled = 1;
				BlueLightReductionAlgoOverride = 0;
				BlueLightReductionDisableScheduleAlertCounter = 3;
				BlueLightReductionSchedule = {
					DayStartHour = 8;
					DayStartMinute = 0;
					NightStartHour = 21;
					NightStartMinute = 0;
				};
				BlueReductionAvailable = 1;
				BlueReductionEnabled = 1;
				BlueReductionMode = 2;
				BlueReductionSunScheduleAllowed = 1;
				Version = 1;
			};
		}'

		if [ -d /Users/"${accountUsername}" ]; then
			sudo defaults write $CORE_BRIGHTNESS "CBUser-0" "$ENABLE"
			sudo defaults write $CORE_BRIGHTNESS "CBUser-$(dscl . -read /Users/"${accountUsername}" GeneratedUID | sed 's/GeneratedUID: //')" "$ENABLE"
		else
			error "Invalid username! This username doesn't exist or doesn't" \
			"have \$HOME folder! Skipping..."
			echo
		fi
	;;
	n|N|no|No|"skip"|"none"|"")
		warn "Skipping this step!"
	;;
	*)
		error "Invalid choice! Aborting..."
		exit 126
	;;
esac
unset resp
echo

################################################################################
##########------------------------------------------------------------##########
################################################################################

echo
echo; option "---•-- ACTIVATE HIDDEN BINARIES --•------------------------------"
echo

subopt "Changing the Bourne shell (sh) link to use the Debian-Almquist Shell (dash)"
sudo ln -fsv /bin/dash /var/select/sh
echo

subopt 'Enabling WiFi CLI utility by symlinking hidden $(airport) binary...'
sudo ln -fsv "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" /usr/local/bin/airport


} # <---------------------------------------------------------------------------


















####################################################################################################

post_install_defaultsmacos() \
{
####################################################################################################
## ---------------------- DRDUH SECURITY & PRIVACY GUIDE -------------------------------------------
####################################################################################################

echo
echo; option "---•-- DRDUH SECURITY & PRIVACY GUIDE --•------------------------"
echo

##### <------------------ This section can be commented for debugging purposes
## ============================== FIREWALL =====================================
subopt "============== Application layer firewall ================="
trdopt "Enable Firewall - Way #2."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
## Firewall is enabled. (State = 1)

trdopt "Enable Firewall's Logging Mode."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
## Turning on log mode

trdopt "Enable Firewall's Stealth Mode."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
## When stealth mode is enabled, your computer does not respond to ICMP ping
## requests, and does not answer to connection attempts from a closed TCP or UDP
## port. This makes it more difficult for attackers to find your computer.

trdopt "Disable allow signed built-in applications automatically."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off

trdopt "Disable allow signed downloaded applications automatically."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off


sudo pkill -HUP socketfilterfw   ## <---------------- End of debugging section
echo


subopt "============ Kernel-level Packet filtering ================"
trdopt "Enable a custom Packet filtering configuration for the Firewall."
sudo pfctl -e -f /etc/pf/pf.rules
echo

trdopt "Query Merit RADb for the list of networks in use by an autonomous system, like Facebook."
[ ! -e /tmp/netlist.txt ] && whois -h whois.radb.net '!gAS32934' > /tmp/netlist.txt

info "When this defaults process finishes, go to /tmp/netlist.txt, copy the" \
"content and paste it at the end of the command: ${DM}sudo pfctl -t blocklist" \
"-T add ${IT}<content_of_/tmp/netlist.txt>${NIT}${NDM}, and run it to block them."
echo



## ================================= DNS =======================================
subopt "===================== Hosts file =========================="
## Use the hosts file to block known malware, advertising or otherwise unwanted
## domains. Append a list of hosts with the tee command and confirm only
## non-routable addresses or comments were added:

if ! sudo grep -Fqx "# Title: StevenBlack/hosts" /etc/hosts;
then
	trdopt "Download @StevenBlack's custom hosts file to block known malware."
	printf "\n\n" | sudo tee -a /etc/hosts 1> /dev/null
	curl -fsSL --output /tmp/hosts https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
	sudo tee -a /etc/hosts < /tmp/hosts > /dev/null
	echo
fi

trdopt "Confirm only non-routable addresses or comments were added (103296):"
wc -l /etc/hosts
## 103296
echo

trdopt "If everything went alright, there should be no following output:"
grep -Eve "^#|^255.255.255.255|^127.|^0.|^::1|^ff..::|^fe80::" /etc/hosts | sort | uniq | grep -Ee "[1,2]|::"
## [No output]
echo



# ##### <------------------ This section can be commented for debugging purposes
# subopt "=================== Dnscrypt-proxy ========================"
# if pgrep dnscrypt-proxy 1> /dev/null;
# then
# 	trdopt "Setting up Dnscrypt-proxy configurations."

# 	# sudo brew services restart dnscrypt-proxy
# 	echo

# 	trdopt "Make sure DNSCrypt is running:"
# 	sudo lsof +c 15 -Pni UDP:5355
# 	## COMMAND          PID   USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
# 	## dnscrypt-proxy 15244 nobody    7u  IPv4 0x1337f85ff9f8beef      0t0  UDP 127.0.0.1:5355
# 	## dnscrypt-proxy 15244 nobody   10u  IPv6 0x1337f85ff9f8beef      0t0  UDP [::1]:5355
# 	## dnscrypt-proxy 15244 nobody   12u  IPv4 0x1337f85ff9f8beef      0t0  UDP 127.0.0.1:5355
# 	## dnscrypt-proxy 15244 nobody   14u  IPv6 0x1337f85ff9f8beef      0t0  UDP [::1]:5355
# 	echo

# 	trdopt "Confirm outgoing DNS traffic is encrypted via dnscrypt-proxy."
# 	sudo tcpdump -qtni en0
# 	## IP 10.8.8.8.59636 > 107.181.168.52: UDP, length 512
# 	## IP 107.181.168.52 > 10.8.8.8.59636: UDP, length 368

# 	dig +short -x 128.180.155.106.49321
# 	## d0wn-us-ns4
# fi
# echo



# subopt "====================== Dnsmasq ============================"
# if pgrep dnsmasq 1> /dev/null;
# then
# 	trdopt "Setting up Dnsmasq configurations."
# 	## To set Dnsmasq as your local DNS server, open System Preferences > Network
# 	## and select the active interface, then the DNS tab, select + and add
# 	## 127.0.0.1, or use:
# 	trdopt "Set Dnsmasq as your local DNS server."
# 	networksetup -setdnsservers "Wi-Fi" 127.0.0.1
# 	echo

# 	trdopt "Make sure Dnsmasq is correctly configured."
# 	frtopt "Request A & AAAA records should appear:"
# 	scutil --dns | head
# 	## DNS configuration
# 	##
# 	## resolver #1
# 	##   search domain[0] : whatever
# 	##   nameserver[0] : 127.0.0.1
# 	##   flags    : Request A records, Request AAAA records
# 	##   reach    : 0x00030002 (Reachable,Local Address,Directly Reachable Address)

# 	echo
# 	frtopt "127.0.0.1 should be printed:"
# 	networksetup -getdnsservers "Wi-Fi"
# 	## 127.0.01
# 	echo

# 	## Test DNSSEC validation succeeds for signed zones - the reply should have
# 	## NOERROR status and contain the 'ad' flag:
# 	trdopt "Test DNSSEC validations."

# 	if dig +dnssec icann.org | grep -Eo "status: NOERROR"; then
# 		success "DNSSEC validation succeded for signed zones!..."
# 	else
# 		error "DNSSEC signed zones validation Test failed!"
# 	fi
# 	echo

# 	## Test DNSSEC validation fails for zones that are improperly signed -
# 	## the reply should have SERVFAIL status:
# 	if dig +dnssec icann.org | grep -Eo "status: SERVFAIL"; then
# 		success "DNSSEC validation failed for improperly signed zones!..."
# 	else
# 		error "DNSSEC improperly signed zones validation Test failed!"
# 	fi
# fi
# echo   ## <------------------------------------------ End of debugging section



## ============================= CAPTIVE PORTAL ================================
subopt "========= Disabling Captive portal configurations ========="
info "When macOS connects to new networks, it checks for Internet connectivity" \
"and may launch a Captive Portal assistant utility application."
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false
echo


# ##### <------------------ This section can be commented for debugging purposes
# ## ================================== WEB ======================================
# subopt "======================= Privoxy ==========================="
# if pgrep privoxy 1> /dev/null;
# then
# 	trdopt "Setting up Privoxy as a local proxy to filter Web browsing traffic."

# 	trdopt "Set the system HTTP proxy for your active network interface 127.0.0.1" \
# 	"and 8118."
# 	## (This can be done through System Preferences > Network > Advanced > Proxies):
# 	networksetup -setwebproxy "Wi-Fi" 127.0.0.1 8118

# 	trdopt "(Optional) Set the system HTTPS proxy, which still allows for" \
# 	"domain name filtering."
# 	networksetup -setsecurewebproxy "Wi-Fi" 127.0.0.1 8118

# 	trdopt "Confirm the proxy is set."
# 	scutil --proxy
# 	## <dictionary> {
# 	##   ExceptionsList : <array> {
# 	##     0 : *.local
# 	##     1 : 169.254/16
# 	##   }
# 	##   FTPPassive : 1
# 	##   HTTPEnable : 1
# 	##   HTTPPort : 8118
# 	##   HTTPProxy : 127.0.0.1
# 	##   HTTPSEnable : 1
# 	##   HTTPSPort : 8118
# 	##   HTTPSProxy : 127.0.0.1
# 	## }
# 	echo

# 	frtopt "HTTP/1.1 200 OK should be printed:"
# 	ALL_PROXY=127.0.0.1:8118 curl -I http://p.p/
# 	## HTTP/1.1 200 OK
# 	## Content-Length: 2401
# 	## Content-Type: text/html
# 	## Cache-Control: no-cache
# 	echo

# 	trdopt "Restart Privoxy and verify traffic is blocked or redirected:"
# 	# sudo brew services restart privoxy
# 	echo

# 	ALL_PROXY=127.0.0.1:8118 curl ads.foo.com/ -IL
# 	## HTTP/1.1 403 Request blocked by Privoxy
# 	## Content-Type: image/gif
# 	## Content-Length: 64
# 	## Cache-Control: no-cache
# 	echo

# 	ALL_PROXY=127.0.0.1:8118 curl imgur.com/ -IL
# 	## HTTP/1.1 302 Local Redirect from Privoxy
# 	## Location: https://imgur.com/
# 	## Content-Length: 0

# 	## HTTP/1.1 200 OK
# 	## Content-Type: text/html; charset=utf-8
# fi
# echo   ## <------------------------------------------ End of debugging section



## ========================= GATEKEEPER & XPROTECT =============================

if command -v truncate > /dev/null 2>&1;
then
	subopt "Disable Quarantine storing information about downloaded files."

	sudo truncate -s 0 "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
	sudo chflags schg "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
	echo
fi



## ========================= METADATA & ARTIFACTS ==============================

subopt "Setting up Metadata and Artifacts restrictions."

## Quicklook thumbnail data can be cleared using the qlmanage -r cache command,
## but this writes to the file resetreason in the Quicklook directories, and
## states that the Quicklook cache was manually cleared. Disable the thumbnail
## cache with qlmanage -r disablecache
## It can also be manually cleared by getting the directory names with getconf
## DARWIN_USER_CACHE_DIR and sudo getconf DARWIN_USER_CACHE_DIR, then removing them:
trdopt "Clearing manually QuickLook cache (It may leak encrypted data)."
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/exclusive"
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/index.sqlite"
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/index.sqlite-shm"
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/index.sqlite-wal"
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/resetreason"
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/thumbnails.data"
echo

## Similarly, for the root user:
trdopt "Clearing manually root QuickLook cache (It may leak encrypted data)."
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/thumbnails.fraghandler"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/exclusive"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/index.sqlite"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/index.sqlite-shm"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/index.sqlite-wal"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/resetreason"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/thumbnails.data"
sudo rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.QuickLook.thumbnailcache/thumbnails.fraghandler"
echo

trdopt "Disable QuickLook thumbnail cache (It may leak encrypted data)."
qlmanage -r cache
rm -rfv "$TMPDIR/../C/com.apple.QuickLook.thumbnailcache"
chmod -R 000 "$TMPDIR/../C/com.apple.QuickLook.thumbnailcache"
chflags -R uchg "$TMPDIR/../C/com.apple.QuickLook.thumbnailcache"
echo

## QuickLook application support metadata can be cleared and locked with the
## following commands:
trdopt "Remove QuickLook application support metadata and lock the file."
rm -rfv "$HOME/Library/Application Support/Quick Look/*"
chmod -R 000 "$HOME/Library/Application Support/Quick Look"
chflags -R uchg "$HOME/Library/Application Support/Quick Look"
echo


## macOS may collect sensitive information about what you type, even if user
## dictionary and suggestions are off. To remove them, and prevent them from
## being created again, use the following commands:
trdopt "Remove any sensitive data collected by preventing the Library files to\n" \
"be created again and lock the files."
rm -rfv "$HOME/Library/LanguageModeling/*" "$HOME/Library/Spelling/*" "$HOME/Library/Suggestions/*"
chmod -R 000 "$HOME"/Library/LanguageModeling "$HOME"/Library/Spelling "$HOME"/Library/Suggestions
chflags -R uchg "$HOME"/Library/LanguageModeling "$HOME"/Library/Spelling "$HOME"/Library/Suggestions
echo


## The Siri analytics database, which is created even if the Siri launch agent
## disabled, can be cleared and locked with the following commands:
trdopt "Remove Siri analytics database and lock the file."
rm -rfv "$HOME"/Library/Assistant/SiriAnalytics.db
chmod -R 000 "$HOME"/Library/Assistant/SiriAnalytics.db
chflags -R uchg "$HOME"/Library/Assistant/SiriAnalytics.db


## Recent iTunes search data may be cleared with the following command:
trdopt "Remove Recent iTunes search data and lock the file."
defaults delete "$HOME"/Library/Preferences/com.apple.iTunes.plist recentSearches
echo



## ================================ WI-FI ======================================
subopt "Setting up Wi-Fi configurations."
trdopt "Spoof the MAC address to mitigate passive fingerprinting."
sudo ifconfig en0 ether $(openssl rand -hex 6 | sed 's%\(..\)%\1:%g; s%.$%%')
echo



# ##### <------------------ This section can be commented for debugging purposes
# ## ================================= SSH =======================================
# ## For outgoing SSH connections, use hardware or password-protected keys, set up
# ## remote hosts and consider hashing them for added privacy.
# ## You can also use ssh to create an encrypted tunnel to send traffic through,
# ## similar to a VPN.

# if pgrep privoxy 1> /dev/null;
# then
# 	subopt "Setting up SSH configurations."

# 	trdopt "Use Privoxy running on a remote host port 8118."
# 	# ssh -C -L 5555:127.0.0.1:8118 you@remote-host.tld
# 	sudo networksetup -setwebproxy "Wi-Fi" 127.0.0.1 5555
# 	sudo networksetup -setsecurewebproxy "Wi-Fi" 127.0.0.1 5555

# 	## By default, macOS does not have sshd or Remote Login enabled.
# 	trdopt "Enable sshd and allow incoming ssh connections."
# 	sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist

# 	trdopt "Confirm whether sshd is running,"
# 	sudo lsof -Pni TCP:22
# 	echo
# fi   ## <-------------------------------------------- End of debugging section



## ============================ MISCELLANOUS ===================================
subopt "Setting up Miscellanous configurations."

if command -v duti > /dev/null 2>&1;
then
	trdopt "Set several recommended file handlers to manage."

	# duti -sv com.apple.Safari afp
	# duti -sv com.apple.Safari ftp
	# duti -sv com.apple.Safari nfs
	# duti -sv com.apple.Safari smb
	# duti -sv com.apple.TextEdit public.unix-executable
	echo
fi


trdopt "Disable Bonjour multicast advertisements."
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

if sudo grep -Fqx "Defaults	env_keep += \"HOME MAIL\"" /etc/sudoers;
then
	trdopt "Avoid a potentially easy way for malware or a local attacker to" \
	"escalate privileges to root."

	if command -v gsed > /dev/null 2>&1;
	then
		sudo gsed -i '23 s/^/# /' /etc/sudoers
	else
		sudo /usr/bin/sed -i '' '23 s/^/# /' /etc/sudoers
	fi
	echo "export HOME=/Users/admtr" | sudo tee -a /var/root/.bashrc
fi

if [ "$(uname -r)" -lt 12 ];
then
	if ! sudo grep -Fqx "Defaults	tty-tickets" /etc/sudoers;
	then
		trdopt "Restrict the sudo session to the Terminal window/tab that" \
		"started it. (macOS 11 or prior)"

		printf "%b" "\nDefaults	tty-tickets" | sudo tee -a /etc/sudoers
		echo
	fi
fi   ## <-------------------------------------------- End of debugging section

echo
}

####################################################################################################










####################################################################################################
## --------------------------- TOOLS & UTILITIES ---------------------------------------------------
####################################################################################################

# echo
# echo; option "---•-- TOOLS & UTILITIES --•-------------------------------------"
# echo

####################################################################################################

sanity_defaultsmacos() \
{
	local accountUsername
	accountUsername=$(id -un)

	isMacos

	enter_sudo_mode

	osascript -e 'tell application "System Preferences" to quit'
}

# ==============================================================================

usage_defaultsmacos() \
{
	echo
	echo "@dievilz' macOS Defaults Script"
	echo "Main script for macOS Defaults configurations."
	echo
	printf "SYNOPSIS: ./%s [-b][-h][-p] \n" "$(basename "$0")"
	cat <<-'EOF'

	OPTIONS:
	    -b,--basic          Set up main defaults configurations.
	    -p,--post-install   Set up post-install system configurations
	                        (including @DrDuh Privacy Guide)

	    -h,--help           Show this menu

	All options are mutually exclusive.

	For full documentation, see: https://github.com/dievilz/punto.sh#readme

	EOF
}

main_defaultsmacos() \
{
	case "$1" in
		"-h"|"--help")
			usage_defaultsmacos
			exit 0
		;;
		"-b"|"--basic")
			sanity_defaultsmacos
			basic_settings_defaultsmacos
		;;
		"-p"|"--post-install")
			sanity_defaultsmacos
			post_install_defaultsmacos
		;;
		*)
			error "Unknown option! Use -h/--help"
			return 127
		;;
	esac

	bold "Done. Note that some of these changes require a full restart to take effect."
	echo
}

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi

main_defaultsmacos "$@"; exit
