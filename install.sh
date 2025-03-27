#! /bin/bash
logfile="installer.log"

if [ $(id -u) -ne 0 ]; then 
        echo "Run as root."
        exit 1
fi

if [ ! -z "$(ls)" ]; then 
        echo 'Please run from an empty directory. either "rm -r *" or "cd" to an empty directory (careful with the rm one).'; 
fi

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
        curl --insecure -X POST -H \"Content-Type: application/json\" -H \"Authorization: $API\" --data \"$2\" https://localhost:3333${1} -v
}

function evilconfig {
        printf "Sending the following commands to evilginx2:\n$* \n"
        printf "$*" | evilginx2 > /dev/null
}

echo "Logs for all actions taken by this script are logged to ${logfile}"

# Add kali repos
runcmd "sh -c \"echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' > /etc/apt/sources.list.d/kali.list\""
runcmd "echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free' | sudo tee /etc/apt/sources.list.d/kali.list"
runcmd "wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add -"
runcmd "sudo apt update"


checkInstalled evilginx2 evilginx2
checkInstalled unzip unzip
checkInstalled sqlite3 sqlite3
checkInstalled ifconfig net-tools
checkInstalled git git

askInstall "Gophish CLI (by gosecure on Github)" "git clone --recursive https://github.com/gosecure/gophish-cli"
askInstall "gophish" "wget https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip"
askInstall "MailHog (Version 1.0.1)" "wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_386"

# Bug where if this repository is cloned. Unzip will have conflicting files and hang
rm README.md
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

runcmd "mkdir -p /usr/share/evilginx2/phishlets/"
runcmd "git clone https://github.com/An0nUD4Y/Evilginx2-Phishlets"
runcmd "mv Evilginx2-Phishlets/* /usr/share/evilginx2/phishlets/"

runcmd "./MailHog_linux_386" &
sleep 5
runcmd "./gophish" &
sleep 5

runcmd "mkdir -p /usr/share/evilginx2/phishlets/"
runcmd "git clone https://github.com/An0nUD4Y/Evilginx2-Phishlets"
runcmd "mv Evilginx2-Phishlets/* /usr/share/evilginx2/phishlets/"

echo "Configuring Evilginx2. What is the domain you have?"
read domain

ip=$(curl https://api.ipify.org 2> /dev/null)
gophishAPI=$(sqlite3 gophish.db "SELECT api_key FROM users")

# pipe commands into evilginx
evilconfig "config domain ${domain}
config ipv4 ${ip}
config gophish admin_url https://${ip}:3333
config gophish api_key ${gophishAPI}"

echo "Evilginx2 (should) be installed and and populated can be run from the terminal with 'evilginx2'"
echo "MailHog will be started and the portal will be binded to port 8025."
echo "GoPhish will be started and the portal will be binded to port 3333."
grep -i "Please login with the username" ${logfile} | tr -d '"' | awk '{print "Gophish has started with the initial username " $8" and password "$12}'
echo 'If you are using google cloud, allow ports 3333, 443 and 80 with the command: "gcloud compute firewall-rules create allow-ports-443-80-3333-53 --allow udp:53,tcp:53,tcp:443,tcp:80,tcp:3333 --network default --priority 1000 --direction INGRESS --target-tags allow-ports-443-80-333 --description "Allow traffic on ports 443, 80, and 3333"'
