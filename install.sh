#! /bin/bash
logfile="installer.log"

function runcmd {
	echo "running command: \"$*\""
	printf "\n\n\n=========================================\n" >> ${logfile}
	echo "Output for command: $*" >> ${logfile}
	$* >> ${logfile} 2>&1	
}

# These are necessary apt binaries
function checkInstalled {
	if [ -z "$(which $1)" ]; then
		echo not installed: $1
		runcmd "sudo apt -y install $2"
	else
		echo "$1 is installed"
	fi
}

# These may already be installed somewhere else. Check with user.
function askInstall {
	echo "Install $1? y/n"
	read opt
	if [ "$opt" = "y" ]; then
		echo "installing..."
		runcmd "$2"
	fi
}

# for API requests to Gophish
function configureGophish {
	API=$(sqlite3 gophish.db "SELECT api_key FROM users")
	cmd="curl --insecure -X POST -H \"Content-Type: application/json\" -H \"Authorization: $API\" --data \"$2\" https://localhost:3333${1} -v"
	runcmd "$cmd"
}

echo "Logs for all actions taken by this script are logged to ${logfile}"

# Add kali repos

runcmd "echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free' | sudo tee /etc/apt/sources.list.d/kali.list"
runcmd "wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add -"
runcmd "sudo apt update"


checkInstalled evilginx2 evilginx2
checkInstalled unzip unzip
checkInstalled sqlite3 sqlite3
checkInstalled ifconfig net-tools

askInstall "Gophish CLI (by gosecure on Github)" "git clone --recursive https://github.com/gosecure/gophish-cli"
askInstall "gophish" "wget https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip"
askInstall "MailHog (Version 1.0.1)" "wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_386"


# Setup files
runcmd "unzip gophish-*zip"
# make executable 
runcmd "chmod +x gophish"
runcmd "chmod +x MailHog*"

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
}' > config.json


runcmd "./MailHog_linux_386" &
sleep 5
runcmd "./gophish" &
sleep 5
echo "MailHog will be started and the portal will be binded to port 8025."
grep -i "Please login with the username" ${logfile} | tr -d '"' | awk '{print "Gophish has started with the initial username " $8" and password "$12}'

configureGophish '/api/smtp/' '{ "id" : 1, "name":"MailHog", "interface_type":"SMTP", "from_address":"setup@example.com", "host":"127.0.0.1:1025", "username":"", "password":"", "ignore_cert_errors":true, "modified_date": "2024-11-20T14:47:51.4131367-06:00" }'
