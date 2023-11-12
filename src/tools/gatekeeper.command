#!/bin/bash
#
# Bash Menu Script Example

RED='\033[0;31m'
GRN='\033[0;32m'
# BLU='\033[0;34m'
RST='\033[0m'

echo ""
echo -e "GateKeeper Helper Brought to you by ${RED}NMac.to${RST}"
echo ""
echo -e "${RED}Options 1: Disable GateKeeper >> Good For Professional Users.${RST}"
echo ""
echo -e "${RED}Options 2: Enable GateKeeper >> Good For New Users.${RST}"
echo ""
echo -e "${RED}Options 3: Allow Single App To ByPass The GateKeeper means${RST}"
echo -e "${RED}If you don't want to completely disable GateKeeper then allow an${RST}"
echo -e "${RED}individual app to pass it >> Recommended For All Users.${RST}"
echo ""
echo -e "${RED}Options 4: Self-Sign An App means${RST}"
echo -e "${RED}If you don't want to disable SIP and your app is quite unexpectedly${RST}"
echo -e "${RED}under the recent macOS then try to Self-Sign your app using this option.${RST}"
echo ""

PS3='Please enter your choice: '
options=("Disable Your GateKeeper" "Enable Your GateKeeper" "Allow Single App To ByPass The GateKeeper" "Self-Sign An App" "Quit")

select opt in "${options[@]}"
do
	case $opt in
		"Disable Your GateKeeper")
			echo ""
			echo -e "${GRN}Disable GateKeeper selected${RST}"
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${RST}"
			echo ""
			sudo spctl --master-disable
			break
			;;
		"Enable Your GateKeeper")
			echo ""
			echo -e "${GRN}Enable GateKeeper selected${RST}"
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${RST}"
			echo ""
			sudo spctl --master-enable
			break
			;;
		"Allow Single App To ByPass The GateKeeper")
			echo ""
			echo -e "${GRN}Allow Single App To Bypass The GateKeeper selected${RST}"
			echo ""
			read -e -p "Drag & Drop The App Here Then Hit Return: " FILEPATH
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${RST}"
			echo ""
			sudo xattr -rd com.apple.quarantine "$FILEPATH"
			break
			;;
		"Self-Sign An App")
			echo ""
			echo -e "${GRN}Self-Sign An App selected${RST}"
			echo ""
			read -e -p "Drag & Drop The App Here Then Hit Return: " FILEPATH
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${RST}"
			echo ""
			sudo codesign -f -s - --deep "$FILEPATH"
			echo ""
			echo -e "${RED}If you see - replacing existing signature - that means you are DONE!${RST}"
			echo ""
			echo -e "${RED}Otherwise there is something wrong with the app or its path${RST}"
			echo ""
			break
			;;
		"Quit")
			exit 0
			;;
		*) echo "invalid option $REPLY";;
	esac
done
