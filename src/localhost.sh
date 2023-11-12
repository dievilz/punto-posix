#!/bin/bash
#
# Localhost Setup Script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

setup_httpd_config() {
	option "Setting up Apache Config File for AMP stack development"

	case "$(uname -s)" in
		"Darwin")
			[ ! -e /etc/apache2/httpd.conf ] && \
			sudo cp -rfv "$DOTFILES"/root/etc/apache2/httpd.conf "/etc/apache2/httpd.conf" 2>/dev/null
		;;
		"Linux")
			echo ""
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_httpd_vhosts() {
	option "Setting up Apache Virtual Host .test"

	case "$(uname -s)" in
		"Darwin")
			[ ! -e /etc/apache2/extra/httpd-vhosts.conf ] && \
			sudo cp -rfv "$DOTFILES"/root/etc/apache2/httpd-vhosts.conf "/etc/apache2/extra/httpd-vhosts.conf" 2>/dev/null
		;;
		"Linux")
			echo ""
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_httpd_dnsmasq() {
	option "Setting up Dnsmasq for web wildcards as .test"

	case "$(uname -s)" in
		"Darwin")
			[ ! -d /usr/local/etc/dnsmasq.d ] && \
			sudo mkdir -pv /usr/local/etc/dnsmasq.d
			## 1. Si deja de funcionar, checa Console.app y mkdir este directorio de arriba

			[ ! -e /usr/local/etc/dnsmasq.conf ] && \
			printf '%b' "address=/.test/127.0.0.1\nlisten-address=127.0.0.1\n" >> /usr/local/etc/dnsmasq.conf
			## 2. Si deja de funcionar, quita lo de listen--address y verifica si así
			## ya funciona, si no, vuelve a correr sudo brew services restart dnsmasq,
			## así fue como a mi me funcionó

			[ ! -d /etc/resolver ] && \
			sudo mkdir -pv /etc/resolver

			[ ! -e /etc/resolver/test ] && \
			echo "nameserver 127.0.0.1" >> /etc/resolver/test
		;;
		"Linux")
			echo ""
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_httpd_ssl() {
	option "Setting up Apache Secure Socket Layer (SSL)"

	case "$(uname -s)" in
		"Darwin")
			[ ! -e /etc/apache2/extra/httpd-ssl.conf ] && \
			sudo cp -rfv "$DOTFILES"/root/etc/apache2/httpd-ssl.conf "/etc/apache2/extra/httpd-ssl.conf" 2>/dev/null

			suboptq "Ready to activate SSL or want to skip? [Y/n]: "
			read -r resp
			case $resp in
				y*|Y*|"")
					cd /etc/apache2 || return

					[ ! -d /etc/apache2/ssl ] && \
					sudo mkdir -pv /etc/apache2/ssl

					[ ! -e /etc/apache2/server.key ] && \
					echo; subopt "Generating the two host keys:" && \
					sudo openssl genrsa -out /etc/apache2/server.key 2048

					[ ! -e /etc/apache2/ssl/localhost.key ] && \
					sudo openssl genrsa -out /etc/apache2/ssl/localhost.key 2048

					[ ! -e /etc/apache2/ssl/localhost.key.rsa ] && \
					sudo openssl rsa -in /etc/apache2/ssl/localhost.key -out /etc/apache2/ssl/localhost.key.rsa

					[ ! -e /etc/apache2/ssl/localhost.conf ] && \
					echo; subopt "Creating the SSL Localhost configuration file" && \
					sudo cp -rfv "$DOTFILES"/root/etc/apache2/ssl-localhost.conf "/etc/apache2/ssl/localhost.conf" 2>/dev/null

					[ ! -e /etc/apache2/server.csr ] && \
					echo; subopt "Generating the required Certificate Requests" && \
					sudo openssl req -new -key /etc/apache2/server.key -subj "/C=/ST=/L=/O=/CN=/emailAddress=/" -out /etc/apache2/server.csr

					[ ! -e /etc/apache2/ssl/localhost.csr ] && \
					sudo openssl req -new -key /etc/apache2/ssl/localhost.key.rsa -subj "/C=/ST=/L=/O=/CN=localhost/" -out /etc/apache2/ssl/localhost.csr -config /etc/apache2/ssl/localhost.conf

					[ ! -e /etc/apache2/server.crt ] && \
					echo; subopt "Using the Certificate Requests to sign the SSL Certificates" && \
					sudo openssl x509 -req -days 365 -in /etc/apache2/server.csr -signkey /etc/apache2/server.key -out /etc/apache2/server.crt

					[ ! -e /etc/apache2/ssl/localhost.crt ] && \
					sudo openssl x509 -req -extensions v3_req -days 365 -in /etc/apache2/ssl/localhost.csr -signkey /etc/apache2/ssl/localhost.key.rsa -out /etc/apache2/ssl/localhost.crt -extfile /etc/apache2/ssl/localhost.conf

					echo; subopt "Adding the SSL Certificate to Keychain Access."
					sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /etc/apache2/ssl/localhost.crt

					echo; success "Now modify httpd.conf, and httpd-vhosts.conf according to: https://gist.github.com/nrollr/4daba07c67adcb30693e"
					success "After that, SSL on Localhost should be configured successfully!"

					# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt
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
		;;
		"Linux")
			echo ""
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_php() {
	option "Setting up PHP..."
	subopt "Copying phpMyAdmin preferences"

	case "$(uname -s)" in
		"Darwin")
			[ ! -e /usr/local/etc/phpmyadmin.config.inc.php ] && \
			sudo cp -rfv "$DOTFILES"/root/etc/apache2/phpmyadmin.config.inc.php "/usr/local/etc/phpmyadmin.config.inc.php" 2>/dev/null
		;;
		"Linux")
			echo ""
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

remove_sql() {
	if [ ! "$(ps aux | grep [m]ysql)" ] || [ ! "$(ps -ax | grep [m]ysql)" ]; then

		sqlPkg=$(type -P mysql)

		if [ -n "$sqlPkg" ]; then
			error "Homebrew MySQL/MariaDB not found! Aborting..."
			echo; exit 126
		fi

		option "Removing any Homebrew MySQL/MariaDB install..."
		info "Remember doing a backup of your DBs in case you need it."
		suboptq "Ready to uninstall? [Y/n]: "
		read -r resp
		case "$resp" in
			y*|Y*|"")
				case "$(uname -s)" in
					"Darwin")
						echo; remove_macos_sql
						unset sqlPkg
					;;
					"Linux")
						echo ""
						unset sqlPkg
					;;
					*)
						error "$(uname -s) not supported! Skipping..."
						echo; exit 126
					;;
				esac
			;;
			n*|N*|"skip")
				warn "Skipping this step!"
			;;
			*)
				error "Invalid choice! Aborting..."
				echo; exit 126
			;;
		esac
	else
		error "You need to have MySQL/MariaDB not running to uninstall it! Aborting..."
		echo; exit 126
	fi
	echo
}

remove_macos_sql() {
	if [ -n "$sqlPkg" ]; then
		# Deprecated: brew remove "$sqlPkg"
		brew services stop "$sqlPkg"
		sudo brew services stop "$sqlPkg"

		brew uninstall --force "$sqlPkg" || {
			error "Brew uninstall of $sqlPkg failed!"
			warn "Proceeding to remove "$sqlPkg" manually..."
		}

		[ -d /usr/local/Cellar/"$sqlPkg" ] && sudo rm -rfv /usr/local/Cellar/"$sqlPkg"

		if [ -r "$HOME/Library/LaunchAgents/homebrew.mxcl.$sqlPkg.plist" ] \
		|| [ -h "$HOME/Library/LaunchAgents/homebrew.mxcl.$sqlPkg.plist" ];
		then
			sudo rm -v "$HOME/Library/LaunchAgents/homebrew.mxcl.$sqlPkg.plist"
			launchctl unload -w "$HOME/Library/LaunchAgents/homebrew.mxcl.$sqlPkg.plist"
		fi

		if [ -r "/Library/LaunchDaemons/homebrew.mxcl.$sqlPkg.plist" ] \
		|| [ -h "/Library/LaunchDaemons/homebrew.mxcl.$sqlPkg.plist" ];
		then
			sudo rm -v /Library/LaunchDaemons/homebrew.mxcl."$sqlPkg".plist
			launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl."$sqlPkg".plist
		fi
	fi

	if [ -r /usr/local/etc/my.cnf ] || [ -h /usr/local/etc/my.cnf ]; then
		sudo rm -fv /usr/local/etc/my.cnf
	fi

	if [ -r /usr/local/etc/my.default.cnf ] || [ -h /usr/local/etc/my.default.cnf ]; then
		sudo rm -fv /usr/local/etc/my.default.cnf
	fi

	if find /usr/local/etc/init.d -maxdepth 1 -name 'mysql*' -print0; then
		sudo rm -rfv /usr/local/etc/init.d/mysql*
	else
		error "None MySQL file in /usr/local/etc/init.d/ was found!"
	fi

	if find /usr/local/etc/logrotate.d -maxdepth 1 -name 'mysql*' -print0; then
		sudo rm -rfv /usr/local/etc/logrotate.d/mysql*
	else
		error "None MySQL file in /usr/local/etc/logrotate.d/ was found!"
	fi

	[ -d /usr/local/mysql ] && sudo rm -v /usr/local/mysql

	[ -d /usr/local/mysql* ] && sudo rm -rfv /usr/local/mysql*

	[ -d /usr/local/var/mysql ] && sudo rm -rfv /usr/local/var/mysql

	[ -d /usr/local/var/run/mysql ] && sudo rm -rfv /usr/local/var/run/mysql

	if [ -r /tmp/mysql.sock ] || [ -h /tmp/mysql.sock ]; then
		sudo rm -fv /tmp/mysql.sock
	fi

	sudo rm -rfv /Library/StartupItems/MySQLCOM
	sudo rm -rfv /Library/PreferencePanes/My*
	## Remove the line MYSQLCOM=-YES- in /etc/hostconfig
	if grep -Fqx "MYSQLCOM=-YES-" /etc/hostconfig; then
		sudo sed 's/MYSQLCOM=-YES-//' /etc/hostconfig
	fi
	rm -rfv "$HOME"/Library/PreferencePanes/My*
	sudo rm -rfv /Library/Receipts/mysql*
	sudo rm -rfv /Library/Receipts/MySQL*
	sudo rm -rfv /private/var/db/receipts/*mysql*
	echo

	suboptq "Do you want to run brew cleanup? [Y/n]: "
	read -r resp
	case $resp in
		y*|Y*|"")
			echo
			brew cleanup
		;;
		n*|N*|"skip")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
}

setup_sql() {
	if [ ! $(ps aux | grep [m]ysql) ] || [ ! $(ps -ax | grep [m]ysql) ]; then

		case "$(ps -p $$ | egrep -m 1 -o '\b\w{0,6}sh|koi')" in
			"zsh")
				sqlPkg=$(whence -p mysql)
			;;
			*) sqlPkg=$(type -P mysql) ;;
		esac

		if [ -z "$sqlPkg" ]; then
			error "MySQL/MariaDB not found! Aborting..."
			echo; exit 126
		fi

		option "Setting up MySQL/MariaDB"
			info "This operation is a little bit tricky on macOS and Brew, first you need to make the file"
			info "/tmp/mysql.sock. Then, you need to reinstall MySQL to use it with your user account instead"
			info "of root. To do so, you need to remove the previously installed MySQL/MariaDB"
			info "UPDATE: after doing this, I've just restarted the Mac and everything works now!"
			info "After that, when you reinstall it for your user account, you need to remove the"
			info "previously made /tmp/mysql.sock and create another to do the secure install."
			info "Finally, after that, you need to log in on mysql to unset the root password with"
			info "this: \"SET PASSWORD FOR 'root'@'localhost' = '';\" if you want to do so..."
			info "With all this, MySQL should finally be working well, good luck!"
			echo
			info "P.S. To use MySQL as your account, you just need to run 'mysql.server start'. But if you"
			info "want to run it as root, though you shouldn't, just run it as 'sudo mysql.server start'"

		case "$(uname -s)" in
			"Darwin")
				echo; setup_macos_sql
				unset sqlPkg
			;;
			"Linux")
				echo ""
				unset sqlPkg
			;;
			*)
				error "$(uname -s) not supported! Skipping..."
				echo; exit 126
			;;
		esac
	else
		error "You need to have MySQL/MariaDB not running to uninstall it! Aborting..."
		echo; exit 126
	fi
	echo
}

setup_macos_sql() {
	[ ! -d /usr/local/var/run/mysql ] && \
	sudo mkdir /usr/local/var/run/mysql && echo

	[ ! -r /usr/local/var/run/mysql/mysql.sock ] && \
	sudo touch /usr/local/var/run/mysql/mysql.sock && echo

	[ ! -r /tmp/mysql.sock || ! -h /tmp/mysql.sock ] && \
	sudo ln -fsv /usr/local/var/run/mysql/mysql.sock /tmp/mysql.sock && echo

	suboptq "Ready to do the MySQL database install to run as $(whoami)? [Y/n]: "
	read -r resp
	case "$resp" in
		y*|Y*|"")
			echo
			if [ "$(ps aux | grep [h]ttpd)" ]; then
				[ -d /usr/local/var/mysql ] && \
				sudo rm -rfv /usr/local/var/mysql && \
				sudo mkdir -pv /usr/local/var/mysql && \
				chown -R $(whoami) /usr/local/var/mysql && echo

				# mariadbPath="$(find /usr/local/Cellar/mariadb -type d -depth 1)"
				# cd "$mariadbPath/scripts"
				## Deprecated: mysql_install_db --verbose
				mysqld -initialize --verbose \
					--user="$(id -un)" --basedir="$(brew --prefix $sqlPkg)" \
					--datadir=/usr/local/var/mysql --tmpdir=/tmp \
				|| {
					error "MySQL failed to install! Aborting..."
					echo; exit 126
				}
				success "MySQL has been successfully installed!"
				echo

				sudo brew services start mariadb
				echo
			else
				error "You need to have running Apache to do this installation! Aborting..."
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

	suboptq "Ready to do the MySQL secure install? [Y/n]: "
	read -r resp
	echo
	case "$resp" in
		y*|Y*|"")
			if [ "$(ps aux | grep [h]ttpd)" ]; then

				if [ -r /tmp/mysql.sock ] || [ -h /tmp/mysql.sock ]; then
					sudo rm -fv /tmp/mysql.sock
					sudo ln -fsv /usr/local/var/run/mysql/mysql.sock /tmp/mysql.sock && echo
				fi

				mysql.server start

				if [ "$(ps aux | grep [m]ysql)" ]; then
					mariadbPath="$(find /usr/local/Cellar/mariadb -type d -depth 1)"
					cd "$mariadbPath/bin" && sudo mysql_secure_installation \
					&& success "MySQL has been successfully installed!"
				else
					error "You need to have running MySQL/MariaDB to do this installation! Aborting..."
					echo; exit 126
				fi
			else
				error "You need to have running Apache to do this installation! Aborting..."
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
}


# ==============================================================================

usage_localhost() {
echo
echo "Localhost Setup Script"
printf "Usage: ./%s <option> <arg> \n" "$(basename "$0")"
cat <<-'EOF'

Options:
    apache           Setup an Apache Server for AMP Stack, this command runs the following:
      --config           Copy Apache conf file with custom configs
      --vhosts           Copy vhost-conf file to designate Virtual Hosts
      --dnsmasq          Copy dnsmasq conf file to activate Virtual Hosts
      --ssl              Copy ssl-conf file to activate SSL on Localhost
    php              Setup PHP and phpMyAdmin
    sql              Install MySQL/MariaDB default databases and run them as the User and do the Secure Install
      --reinstall        Reinstall completely Homebrew MySQL/MariaDB and associated files and folders
      --uninstall        Uninstall completely Homebrew MySQL/MariaDB and associated files and folders

Without any command, all aspects will be setup (in the above order)

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_localhost() {
	case $1 in
		"-h" | "--help")
			usage_localhost
			exit 0
		;;
		"apache")

			case $2 in
				"--config")
					echo; setup_httpd_config
				;;
				"--vhosts")
					echo; setup_httpd_vhosts
				;;
				"--dnsmasq")
					echo; setup_httpd_dnsmasq
				;;
				"--ssl")
					echo; setup_httpd_ssl
				;;
				"")
					echo
					enter_sudo_mode

					setup_httpd_config
					setup_httpd_vhosts
					setup_httpd_dnsmasq
					setup_httpd_ssl

					success "Apache Server configuration completed!" ;echo
				;;
				*)
					usage_localhost
					return 127
				;;
			esac
		;;
		"php")
			echo; setup_php
		;;
		"sql")
			case $2 in
				"--reinstall")
					enter_sudo_mode

					remove_sql
					setup_sql
				;;
				"--uninstall")
					enter_sudo_mode
					remove_sql
				;;
				"")
					enter_sudo_mode
					setup_sql
				;;
				*)
					usage_localhost
					return 127
				;;
			esac
		;;
		"")
			echo; bold "${B}–--> Setting up an AMP Stack Localhost Environment..."

			enter_sudo_mode

			setup_httpd_config
			setup_httpd_vhosts
			setup_httpd_dnsmasq
			setup_httpd_ssl
			setup_php

			enter_sudo_mode
			setup_sql

			success "Localhost configuration completed!" ;echo
		;;
		*)
			usage_localhost
			return 127
		;;
	esac
}

## Exporting DOTFILES path and source helper functions so the script can work
DOTFILES="$(realpath "$0" | grep -Eo '^.*?dotfiles')" ## -o: only matching

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi

main_localhost "$@"; exit
