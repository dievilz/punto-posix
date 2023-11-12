#!/bin/bash
#
# Packages Install Script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

################################# FRAMEWORKS ###################################

install_node() {
	option "Installing some good Node packages"
	info "Be sure you are installing these packages on the right NodeJS version you are going to use (if you are using NVM)"
	warn "If you want to change the version first, just skip this step"

	nodeDescript[0]='Installing AdonisJs CLI Scaffolding Helper';               nodePackages[0]=@adonisjs/cli;
	nodeDescript[1]='Installing Vue.js CLI Scaffolding Helper';                 nodePackages[1]=@vue/cli;
	nodeDescript[2]='Installing Vue.js CLI Old Scaffolding Helper';             nodePackages[2]=@vue/cli-init;
	nodeDescript[3]='Installing React Scaffolding Helper';                      nodePackages[3]=create-react-app;
	nodeDescript[4]='Installing ESlint, a JavaScript linter tool';              nodePackages[4]=eslint;
	nodeDescript[5]='Installing Gulp, a task manager and build system toolkit' nodePackages[5]=gulp;
	nodeDescript[6]='Installing ndb, a debugger enabled by Chrome DevTools';    nodePackages[6]=ndb;
	nodeDescript[7]='Installing vtop, a Node-enabled activity monitor';         nodePackages[7]=vtop;

	echo; read -r -p "${SOA} Which Package Manager you want to use? ['npm','yarn','skip']: ${RE}" pman
	case $pman in

		"n" | "npm")
			if command -v npm > /dev/null 2>&1;
			then
				for K in "${!nodeDescript[@]}"; do
					echo; trdopt "${nodeDescript[K]}"
					npm install -g "${nodePackages[K]}"
					# echo "npm install -g ${nodePackages[K]}"
				done

				echo; success "NPM packages successfully installed!"
			else
				error "NPM not found! Aborting..."
				echo; exit 126
			fi
		;;

		"y" | "yarn")
			if command -v yarn > /dev/null 2>&1;
			then
				for K in "${!nodeDescript[@]}"; do
					echo; trdopt "${nodeDescript[K]}"
					yarn global add "${nodePackages[K]}"
				done

				echo; success "Yarn packages successfully installed!"
			else
				error "Yarn not found! Aborting..."
				echo; exit 126
			fi
		;;
		"skip"|"none"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}

install_pip() {
	option "Installing Pipenv with Pip for a better Python dependencies management"
	info "Be sure you are installing these packages on the right Python version you plan to use (if you are using Pyenv)"
	warn "If you want to change the version first, just skip these step"

	echo; read -r -p "${SOA} Start install? [Y/n]: ${RE}" resp
	case $resp in
		y*|Y*|"")
			if command -v pip > /dev/null 2>&1;
			then
				echo; trdopt "Installing Pipenv, the recommended Package Manager for Python"
				pip install --user pipenv

				# echo; trdopt "Installing neovim, Vim Improved"
				# pip install --user neovim

				echo; trdopt "Installing powerline-status, a statusline plugin for Vim, ZSH, Tmux, and others."
				pip install --user powerline-status

				echo; success "Pip packages successfully installed!"
			else
				error "Pip not found! Aborting..."
				echo; exit 126
			fi
		;;
		n*|N*|"skip")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}

install_bundler() {
	option "Installing Bundler with RubyGem for a better Ruby dependencies management"
	info "Be sure you are installing these packages on the right Ruby version you plan to use (if you are using chruby)"
	warn "If you want to change the version first, just skip these step"

	echo; read -r -p "${SOA} Start install? [Y/n]: ${RE}" resp
	case $resp in
		y*|Y*|"")
			if command -v gem > /dev/null 2>&1;
			then
				echo
				gem install bundler
				gem install colorls
				gem install rails

				echo; success "RubyGem packages successfully installed!"
			else
				error "Gem not found! Aborting..."
				echo; exit 126
			fi
		;;
		n*|N*|"skip")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}


# ==============================================================================

usage_frameworks() {
echo
echo "Packages Install Script"
printf "Usage: ./%s <option> <arg> \n" "$(basename "$0")"
cat <<-'EOF'

Options:
    frameworks                 Install most common packages for Web Development
                               (NodeJS, Python & Ruby) using NPM/Yarn, Pip and Bundler
      --node                       Install packages from Node Package Manager or Yarn
      --pip                        Install packages from Pip
      --bundler                    Install packages from Bundler

    -h,--help             Show this menu

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_frameworks() {
	case $1 in
		"-h"|"--help")
			usage_frameworks
			exit 0
		;;
		"-a"|"--asdf")
			case $2 in
				"--node")
					echo; inst_node
				;;
				"--pip")
					echo; inst_pip
				;;
				"--bundler")
					echo; inst_bundler
				;;
				"" | "--all")
					echo; bold "– Setting up Frameworks' libraries..."

					inst_node
					inst_pip
					inst_bundler

					success "Frameworks' libraries successfully downloaded!"
					echo
				;;
				*)
					usage_frameworks
					return 127
				;;
			esac
		;;
		"-i"|"--independent-managers")
			case $2 in
				"--node")
					echo; install_node
				;;
				"--pip")
					echo; install_pip
				;;
				"--bundler")
					echo; install_bundler
				;;
				"" | "--all")
					echo; bold "– Setting up Frameworks' libraries..."

					install_node
					install_pip
					install_bundler

					success "Frameworks' libraries successfully downloaded!"
					echo
				;;
				*)
					usage_frameworks
					return 127
				;;
			esac
		;;
		*)
			usage_frameworks
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

main_frameworks "$@"; exit
