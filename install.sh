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

function configureGophish {
	API=$(sqlite3 gophish.db "SELECT api_key FROM users")
	curl --insecure -X POST -H "Content-Type: application/json" -H "Authorization: $API" --data "$2" https://localhost:3333${1} -v
}
checkInstalled unzip evilginx2 evilginx2

askInstall "Gophish CLI (by gosecure on Github)" "git clone --recursive https://github.com/gosecure/gophish-cli"
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


echo "MailHog will be started and the portal will be binded to port 8025. Gophish Admin portal is running on port 3333 with the credentials: "
(./gophish 2>&1| grep 'Please login with the username') &

./MailHog_linux_386 2>/dev/null &

configureGophish '/api/smtp/' '{ "id" : 1, "name":"MailHog", "interface_type":"SMTP", "from_address":"setup@example.com", "host":"127.0.0.1:1025", "username":"", "password":"", "ignore_cert_errors":true, "modified_date": "2024-11-20T14:47:51.4131367-06:00" }'
