#! /bin/bash

# These are necessary apt binaries
function checkInstalled {
	if [ -z "$(which $1)" ]; then
		echo not installed: $1
	#	sudo apt -y install $2

	else
		echo "$1 is installed"
	fi
}

# These may already be installed somewhere else. Check with user.
function askInstall {
	echo "Install $1? y/n"
	read opt
	if [ "$opt" = "y" ]; then
		echo "installing $1"
		$2
	fi



}

checkInstalled evilginx2 evilginx2

askinstall "Gophish CLI (by gosecure on Github)" "git clone --recursive https://github.com/gosecure/gophish-cli"
askInstall "gophish" "wget https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip"
askInstall "MailHog (Version 1.0.1)" "wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_386"


# Setup files
unzip "gophish-*zip"

# make executable 
chmod +x gophish 2> /dev/null
chmod +x MailHog* 2> /dev/null

# change config in gophish. Can be customized here
printf '{                 
        "admin_server": {
                "listen_url": "0.0.0.0:3333",
                "use_tls": true,
                "cert_path": "gophish_admin.crt",
                "key_path": "gophish_admin.key",
                "trusted_origins": []
        },
        "phish_server": {
                "listen_url": "0.0.0.0:80",
                "use_tls": false,
                "cert_path": "example.crt",
                "key_path": "example.key"
        },
        "db_name": "sqlite3",
        "db_path": "gophish.db",
        "migrations_prefix": "db/db_",
        "contact_address": "",
        "logging": {
                "filename": "",
                "level": ""
        }
}' > gophish/config.json

printf "\nWill start gophish and mailhog now. Press enter to continue."
read x; clear


echo "Gophish credentials: "
./gophish 2>&1| grep 'Please login with the username' 
