#!/usr/bin/bash

source ./common

declare -A properties
global_commands=()
global_commands[0]='--help'
global_commands[1]='--un-init-dir'
global_commands[2]='--un-init-software'
global_commands[3]='--init-flatpak'
global_commands[4]='--open-systemd-ntp'
global_commands[5]='run'
global_commands[6]='--user'

init_properties $@
printProperties properties

init_software() {
    apt update

    # install
    apt install -f vim gcc cmake make wget curl latte-dock plasma-discover-backend-flatpak vlc flatpak -y
    apt install zsh zsh-common zsh-autosuggestions zsh-syntax-highlighting -y
    apt install qt5-style-kvantum qt5-style-kvantum-themes qt5-style-kvantum-l10n -y

    # remove
    apt remove kmahjongg kmines kpat ksudoku -y
}

init_dir() {
    echo "Init Dir"

    mkdir -p /opt/local/kde-style
    chown $1:$1 -R /opt/local
    chmod 755 -R /opt
    echo "[O] mkdir /opt"
    echo "[O] mkdir /opt/local"
    echo "[O] mkdir /opt/local/kde-style"

    mkdir /home/$1/Projects
    chown $1:$1 -R /home/$1/Projects
    chmod 755 -R /home/$1/Projects
    echo "[O] mkdir /home/$1/Projects"
}

init_flatpak() {
    #flatpak
    wget https://mirror.sjtu.edu.cn/flathub/flathub.gpg
    flatpak remote-add flathub https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
    flatpak remote-modify --gpg-import=./flathub.gpg flathub
    flatpak update
    echo "run --> flatpak remote-modify --gpg-import=./flathub.gpg flathub"
}

open_systemd_ntp() {
    apt install systemd-timesyncd -y
    timedatectl set-ntp 1
}

init() {
    isExistKey properties '--un-init-dir'
    if [[ $? == '1' ]];then
        init_dir
    fi

    isExistKey properties '--un-init-software'
    if [[ $? == '1' ]];then
        init_software
    fi

    isExistKey properties '--init-flatpak'
    if [[ $? == '0' ]];then
        init_flatpak
    fi

    isExistKey properties '--open-systemd-ntp'
    if [[ $? == '0' ]];then
        open_systemd_ntp
    fi
}

# -------------------------------
main() {
    echo $_PARTING_LINE

    echo "main code"

    isExistKey properties '--help'
    if [[ $? == '0' ]];then
        echo ${global_commands[@]}
        goto code_end
    fi

    # 任务执行
    isExistKey properties 'run'
    if [[ $? == '0' ]];then

        # 判断必备参数User
        isExistKey properties '--user'
        if [[ $? == '1' ]];then
            echo "没有: --user value 键值"
            exit 1
        fi

        # 主任务函数
        init $@

        goto code_end
    fi

    echo "no command pleace input --help!"

    code_end:
    echo $_PARTING_LINE
    exit 0
}
main $@
