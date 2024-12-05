#! /bin/bash
function checkInstalled {
        if [ -z "$(which $1)" ]; then
                echo not installed: $1
        #       sudo apt -y install $2

        else
                echo "$1 is installed"
        fi
}

function askInstall {
        echo "Install $1? y/n"
        read opt
        if [ "$opt" = "y" ]; then
                echo "installing $1"
                $2
        fi



}

checkInstalled mailgun golang-github-mailgun-minheap-dev
checkInstalled evilginx2 evilginx2

askInstall "gophish" "git clone https://github.com/gophish/gophish.git"
