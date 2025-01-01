IP="" # IP address of the phone

# Check if sshpass is installed
if command -v sshpass >/dev/null 2>&1; then
    USE_SSHPASS=true
    printf "\033[34m[SilentPwn]\033[0m Using sshpass for authentication...\n"
    printf "\033[34m[SilentPwn]\033[0m Enter password: "
    read -s password
    echo
else
    USE_SSHPASS=false
    printf "\033[34m[SilentPwn]\033[0m sshpass not found, using regular ssh...\n"
fi

printf "\033[34m[SilentPwn]\033[0m Cleaning up packages directory...\n"
rm packages/* # Clean up all packages
printf "\033[34m[SilentPwn]\033[0m Building package...\n"
make clean && make package

printf "\033[34m[SilentPwn]\033[0m Removing existing com.* files on the device...\n"
if [ "$USE_SSHPASS" = true ]; then
    sshpass -p "$password" ssh mobile@$IP 'rm ~/com.*'
else
    ssh mobile@$IP 'rm ~/com.*'
fi

printf "\033[34m[SilentPwn]\033[0m Uploading package to device...\n"
if [ "$USE_SSHPASS" = true ]; then
    sshpass -p "$password" scp packages/com.* mobile@$IP:~
else
    scp packages/com.* mobile@$IP:~
fi

printf "\033[34m[SilentPwn]\033[0m Upload complete.\n"
printf "\033[34m[SilentPwn]\033[0m Do you want to install the package? (y/n): "
read -r install_choice
if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then # install & respring
    if [ "$USE_SSHPASS" = false ]; then
        printf "\033[34m[SilentPwn]\033[0m Enter sudo password: "
        read -s password
        echo
    fi
    printf "\033[34m[SilentPwn]\033[0m Installing package...\n"
    if [ "$USE_SSHPASS" = true ]; then
        sshpass -p "$password" ssh mobile@$IP "echo '$password' | sudo -S dpkg -i com.*"
    else
        ssh mobile@$IP "echo '$password' | sudo -S dpkg -i com.*"
    fi
    printf "\033[34m[SilentPwn]\033[0m Installation complete.\n"
    printf "\033[34m[SilentPwn]\033[0m Respring device? (y/n): "
    read -r respring_choice
    if [ "$respring_choice" = "y" ] || [ "$respring_choice" = "Y" ]; then
        if [ "$USE_SSHPASS" = true ]; then
            sshpass -p "$password" ssh mobile@$IP "echo '$password' | sudo -S killall -9 SpringBoard"
        else
            ssh mobile@$IP "echo '$password' | sudo -S killall -9 SpringBoard"
        fi
        printf "\033[34m[SilentPwn]\033[0m Device resprung.\n"
    else
        printf "\033[34m[SilentPwn]\033[0m Device not resprung.\n"
    fi
else
    printf "\033[34m[SilentPwn]\033[0m Package not installed.\n"
fi