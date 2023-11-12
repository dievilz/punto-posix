#!/bin/bash
#
# Git Configuration and Authentication Script
# Script for Git config maintainance and SSH/GPG generation for cloud Git services
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

############################################ GIT CONFIG ############################################

setup_config_git() \
{
	option "Configuring Git"

	[ ! -w "$HOME" ] && chmod 0755 "$HOME"

	subopt "Listing Git configuration files at \$XDG_CONFIG_HOME/git:"
	fd -g ".gitconfig" "$HOME" -HI --maxdepth 2 -E "Library" -E ".dotfiles" -E ".git" -E ".Trash"

	export GIT_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/git"
	localConfig=
	localConfig="$(fd -g ".gitconfig" "$HOME" -HI --maxdepth 2 \
		-E "Library" -E ".dotfiles" -E ".git" -E ".Trash" --max-results 1)"
	echo

	trdopt "Do you want to: 1) create a new .gitconfig file, 2) change current" \
	"one with another .gitconfig at \$XDG_CONFIG_HOME/git, or 3) skip this step?"
	trdopt "Choose one option: [${BO}'n'ew${NBO}|${BO}'c'hange${NBO}]"
	trdopt "[${BO}'skip'${NBO}|${BO}'none'${NBO}][press ${BO}Enter key${NBO}] to halt"
	trdoptq "" && read -r resp
	case "$resp" in
		"n"|"new")
			echo
			make_config_git
		;;
		"c"|"change")
			echo
			while IFS= read -r -d '' gdirConfigPath; do
				gdirConfigFile="$(basename -- "$gdirConfigPath")"
				gdirConfigFound+=("$gdirConfigFile")
			done < \
			<(find "${XDG_CONFIG_HOME:-$HOME/.config}/git" -maxdepth 1 -name "*.gitconfig" -print0)
			# <(find "${XDG_CONFIG_HOME:-$HOME/.config}/git" -maxdepth 1 -name "*.gitconfig" -type f -print0)

			frtopt "Type [Y] to proceed..."
			frtopt "or press [${BO}Enter key${NBO}] to halt"
			frtoptq "" && read -r resp
			case "$resp" in
				y|Y|yes|Yes)
					echo
					PS3='Choose the .gitconfig file to use: '
					select opt in "${gdirConfigFound[@]}"
					do
						if diff "$HOME/.gitconfig" "$GIT_CONFIG_HOME/$opt" > /dev/null 2>&1;
						then
							echo; success "$opt is already being used! Skipping..."
						else
							echo; success "Setting ${Y}$opt${G} as the main config"
							ln -fsv "${XDG_CONFIG_HOME:-$HOME/.config}/git/$opt" "$HOME/.gitconfig"
						fi
						unset PS3
						echo
						return
					done
				;;
				n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
					warn "Skipping this step!"
				;;
				*)
					error "Invalid choice! Aborting..."
					echo; return 1
				;;
			esac
		;;
		no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			[ -w "$HOME" ] && chmod 0551 "$HOME"
			echo; exit 126
		;;
	esac
	echo

	[ -w "$HOME" ] && chmod 0551 "$HOME"
}


make_config_git() \
{
	frtopt "Creating a new global .gitconfig file at .config/git..."

	echo; frtoptq "Enter your Git name: "
	read -r gitName

	echo; frtoptq "Enter your Git email\n(never use a private email, remember a public one): "
	read -r gitEmail

	if [ -f "$GIT_CONFIG_HOME/$gitName.gitconfig" ] \
	|| [ -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" ] \
	;then
		# if [[ "$(git config -f "$GIT_CONFIG_HOME/$gitName.gitconfig" --get-regexp user.email | cut -d ' ' -f 2)" == "$gitEmail" > /dev/null 2>&1 ]] \
		# || [[ "$(git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" --get-regexp user.email | cut -d ' ' -f 2)" == "$gitEmail" > /dev/null 2>&1 ]] \
		if grep -R "email = $gitEmail" "$GIT_CONFIG_HOME/$gitName.gitconfig" > /dev/null 2>&1 \
		|| grep -R "email = $gitEmail" "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" > /dev/null 2>&1 \
		;then
			warn "Looks like you already have a git config for the same Git user" \
			"and same email.\nPlease edit the former file, or delete/duplicate it" \
			"manually.\nSkipping this step..."
			return
		fi
	else
		touch "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig"
	fi

	[ -n "$gitName" ] && git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" user.name "$gitName"

	[ -n "$gitEmail" ] && git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" user.email "$gitEmail"

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" init.defaultBranch master

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.aliases "config --get-regexp alias"
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.st "status"
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.branches "branch -l"
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.remotes "remote -v"

	## Aliases
		## git reset $(git commit-tree HEAD^{tree} -m "A new start")
			squashAll='!f(){ git reset $(git commit-tree HEAD^{tree} -m "${1:-A new start}");};f'
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.squashAll "${squashAll}"

		## git --no-pager log --name-status --decorate | perl -pe 's/\e\[0-9;]*m//g' > "$HOME/Desktop/log.txt"
			exportLog='!f(){ git --no-pager log --name-status --decorate'
			exportLog="${exportLog} | perl -pe 's/\e\[0-9;]*m//g' >"
			defaultE='"${1:-$HOME/Desktop/log.txt}";};f'
			exportLog="${exportLog} ${defaultE}"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.exportLog "${exportLog}"

		## git --no-pager log --graph --abbrev-commit --decorate | perl -pe 's/\\e\\[0-9;]*m//g' > "${1:-$HOME/Desktop/loggraph.txt}"
			exportGraph='!f(){ git --no-pager log --graph --abbrev-commit --decorate'
			exportGraph="${exportGraph} | perl -pe 's/\e\[0-9;]*m//g' >"
			defaultG='"${1:-$HOME/Desktop/loggraph.txt}";};f'
			exportGraph="${exportGraph} ${defaultG}"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.exportGraph "${exportGraph}"

		## git log --graph --abbrev-commit --decorate --date=format:'%Y-%m-%d' --format=format:
			graphLog1="log --graph --abbrev-commit --decorate --date=format:'%Y-%m-%d' --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%cd%C(reset) %C(bold green)(%ar)%C(reset)%x09%C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
			graphLog3="log --graph --abbrev-commit --decorate --date=format:'%Y-%m-%d' --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%cd%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
			graphLog2="log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%x09%C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"
			graphLog4="log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.graph1 "${graphLog1}"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.graph3 "${graphLog3}"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.graph2 "${graphLog2}"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.graph4 "${graphLog4}"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.graph graph1

		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.com "commit "
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.comm "commit -m "
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.amend "commit --amend "
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.logv "log --stat"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.undo "reset HEAD~1"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.undoS "reset --soft HEAD~1"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.untrack "update-index --assume-unchanged "
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.pushAlltoAll "!git remote | xargs -L1 git push --all"
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.remadd '!f(){ git remote add $1 $2};f'
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.remaddGH '!f(){ git remote add $1 git@github.com:$2/$3.git;};f'
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" alias.remaddGL '!f(){ git remote add $1 git@gitlab.com:$2/$3.git;};f'
	##

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.ui always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.branch always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.diff always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.interactive always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.status always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.grep always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.pager true
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.decorate always
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.showbranch always

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.status.added green
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.status.changed yellow
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" color.status.untracked 166

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" commit.gpgsign false
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" commit.template ~/.config/git/gitmessage

	## Convert CRLF to LF, but not turning back into CRLF again
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" core.autocrlf input
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" core.editor "subl -n -w"
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" core.excludesFile ~/.config/git/ignore

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" core.pager "less"
	## Don't consider trailing space change as a cause for merge conflicts
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" core.whitespace trailing-space
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" core.sshCommand "ssh"


	if [ "$(uname -s)" = "Darwin" ];
	then
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" credential.helper osxkeychain
		git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" credential.helper /usr/local/share/gcm-core/git-credential-manager
	else
		case "$DISTRO" in
			"Arch")
				git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" credential.helper archlinux-keyring ;;
			"Manjaro")
				git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" credential.helper manjaro-keyring ;;
			*)
				echo
				error "$DISTRO not supported! Skipping setting a credential helper for Git" ;;
		esac
	fi

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" filter.lfs.process "git-lfs filter-process"
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" filter.lfs.required true
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" gpg.program gpg

	command -v delta > /dev/null 2>&1 && git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" interactive.diffFilter "delta --color-only"

	## Use abbrev SHAs whenever possible/relevant instead of full 40 chars
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" log.abbrevCommit true

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" pull.rebase true

	## When pushing, also push tags whose commits/whatever are now reachable upstream
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" push.followTags true

	## Sort tags as version numbers whenever applicable, so 1.10.2 is AFTER 1.2.0.
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" tag.sort version:refname

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" delta.line-numbers true
	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" delta.syntax-theme "Dracula"

	if [ "$(uname -s)" = "Darwin" ];
	then
		printf "%b" '\n\n# [diff]\n#\ttool = Kaleidoscope\n#\tcolorMoved = default\n# [difftool]\n#\tprompt = false\n[difftool "Kaleidoscope"]\n\tcmd = ksdiff --partial-changeset --relative-path \"$MERGED\" -- \"$LOCAL\" \"$REMOTE\"\n' >> "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig"
		printf "%b" '# [merge]\n#\ttool = Kaleidoscope\n# [mergetool]\n#\tprompt = false\n[mergetool "Kaleidoscope"]\n\tcmd = ksdiff --merge --output \"$MERGED\" --base \"$BASE\" -- \"$LOCAL\" --snapshot \"$REMOTE\" --snapshot\n\ttrustexitcode = true\n\n' >> "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig"
	fi

	git config -f "$GIT_CONFIG_HOME/$gitName-$gitEmail.gitconfig" credential."https://dev.azure.com".useHttpPath true

	success "Git config file successfully created! Symlinking it to \$HOME..."

	ln -fsv "${XDG_CONFIG_HOME:-$HOME/.config}/git/$gitName-$gitEmail.gitconfig" "$HOME/.gitconfig"
	echo

	chmod 700 "$HOME/.gitconfig"
	echo
}



##################################### SSH ######################################

setup_ssh_git() \
{
	option "Configuring SSH"

	SSH_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/ssh"

	subopt "Listing existing SSH Keys in your machine"
	ls -Al "${SSH_HOME}"; echo   # ls -Al para que no aparezcan los '.' y '..'

	subopt "Do you want to create a new SSH key or use an existing one for a SCM Hosting Provider?"
	subopt "Choose one option [${BO}'n'ew${NBO}|${BO}'e'xisting${NBO}]"
	subopt "or [${BO}'skip'${NBO}|${BO}'none'${NBO}][press ${BO}Enter key${NBO}] to halt"
	suboptq "" && read -r resp
	case "$resp" in
		"n"|"new")
			echo; create_ssh_git
		;;
		"e"|"existing")
			echo; copying_ssh_git
		;;
		no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}

create_ssh_git() \
{
	trdopt "Creating new SSH key..."
	frtoptq "Enter any comment to augment entropy when creating the key: "
	read -r sshComment
	frtoptq "Enter the name for the new SSH key: "
	read -r sshKey

	pushd "$SSH_HOME"
	if [ -n $sshKey ];
	then
		ssh-keygen -t ed25519 -a 200 -C "$sshComment" -f "$sshKey"
	else
		return
	fi
	echo

	if eval $(ssh-agent -s);
	then
		if [ ! -d "$(dirname "$SSH_HOME/config")" ];
		then
			# STRING="Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile $SSH_HOME/$sshKey"

			# if ! grep -Fqx "${STRING}" "$SSH_HOME/config"; then
			# 	printf "%b" "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile $SSH_HOME/$sshKey" >> "$SSH_HOME/config"
			# fi
			true
		fi
		echo

		copying_ssh
	fi
	popd
}

copying_ssh_git() \
{
	frtoptq "Enter the filename of the SSH key [i.e. id_ed25519_<username>_<site>]: "
	read -r sshKey
	echo


	case "$(uname -s)" in
		"Darwin")
			ssh-add -K "$SSH_HOME/$sshKey" || {
				error "The SSH key couldn't get added!"
			}

			pbcopy < "$SSH_HOME/$sshKey.pub"
		;;
		"GNU"|"Linux"|"FreeBSD")
			ssh-add "$SSH_HOME/$sshKey" || {
				error "The SSH key couldn't get added!"
			}

			true # cat "$SSH_HOME/$sshKey.pub"
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac

	success "Your new SSH Key is in your Clipboard, add it to your SCM Hosting" \
	"Provider account. When you finish, come back and, i.e. type ${DM}'ssh -T <user>@<url>'${NBO}"
}



##################################### GPG ######################################

setup_gpg_git() \
{
	option "Configuring GPG"

	if [ -n "$GNUPGHOME" ]; then
		subopt "Listing existing GPG Keys in your machine"

		gpg --list-secret-keys --keyid-format LONG
	else
		error "There is no GPG directory! Aborting..."
		echo; exit 1
	fi

	subopt "Do you want to create a new GPG key or use an existing one for your" \
	"SCM Hosting Provider?"
	subopt "Choose one option [${BO}'n'ew${NBO}|${BO}'e'xisting${NBO}]"
	subopt "or [${BO}'skip'${NBO}|${BO}'none'${NBO}][press ${BO}Enter key${NBO}] to halt"
	suboptq "" && read -r resp
	case "$resp" in
		no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		"n"|"new")
			echo
			trdopt "Generating GPG key. Accept the following default options by pressing Enter key"
			echo; gpg --full-generate-key

			armor_gpg_git
		;;
		"e"|"existing")
			echo
			trdoptq "Enter the path of the GPG key you want to import: "
			read -r gpgkey
			gpg --import "$gpgkey" && echo

			armor_gpg_git
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}

armor_gpg_git() \
{
	frtopt "Identify the 16 digit GPG key ID you'd like to use"
	frtopt " i.e: ${Y}'sec   rsaxxxx/${R}<KEY ID>${Y} 20xx-xx-xx'"
	frtopt "Copy it below, ${W}and don't type Ctrl+C for copying the ID"
	frtoptq " " && read -r gpgkey

	git config --global user.signingkey "$gpgkey"

	echo; subopt "Exporting the GPG key"
	echo; gpg --armor --export "$gpgkey"

	echo
	success "Copy your GPG key, beginning with"
	success "--BEGIN PGP--    to    --END PGP--"
	success "and add it to your SCM Hosting Provider account."
}



# ==============================================================================

usage_git() \
{
	echo
	echo "Git Config & Authentication Script"
	printf "SYNOPSIS: ./%s [-c][-g][-h][-s] \n" "$(basename "$0")"
	cat <<-'EOF'

	OPTIONS:
	    -c,--config   Setup Git global configurations
	    -s,--ssh      Setup SSH key to connect to a SCM Hosting Provider
	    -g,--gpg      Setup GPG key to sign commits and tags

	    -h,--help     Show this menu

	Without any arguments, all aspects will be setup (in the above order)

	For full documentation, see: https://github.com/dievilz/punto.sh#readme

	EOF
}

main_git() \
{
	case "$1" in
		"-h"|"--help")
			usage_git
			exit 0
		;;
		"-c"|"--config")
			echo; setup_config_git
		;;
		"-s"|"--ssh")
			echo; setup_ssh_git
		;;
		"-g"|"--gpg")
			echo; setup_gpg_git
		;;
		"")
			echo; bold "${B}–-> Setting up Git, SSH & GPG..."

			echo
			setup_config_git
			setup_ssh_git
			setup_gpg_git

			success "Git, SSH & GPG successfully configured!"; echo
		;;
		*)
			usage_git
			return 127
		;;
	esac
}

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi

main_git "$@"; exit
