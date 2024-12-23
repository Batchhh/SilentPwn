IP="" # IP address of the phone
printf "\033[34m[SilentPwn]\033[0m Cleaning up packages directory...\n"
rm packages/* # Clean up all packages
printf "\033[34m[SilentPwn]\033[0m Building package...\n"
make clean && make package
printf "\033[34m[SilentPwn]\033[0m Removing existing com.* files on the device...\n"
ssh mobile@$IP 'rm ~/com.*' # Delete existing com.* files on the device
printf "\033[34m[SilentPwn]\033[0m Uploading package to device...\n"
scp packages/com.* mobile@$IP:~ # Upload package
printf "\033[34m[SilentPwn]\033[0m Upload complete.\n"
printf "\033[34m[SilentPwn]\033[0m Do you want to install the package? (y/n): "
read -r install_choice
if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
    printf "\033[34m[SilentPwn]\033[0m Enter sudo password: "
    read -s password
    printf "\n\033[34m[SilentPwn]\033[0m Installing package...\n"
    ssh mobile@$IP "echo '$password' | sudo -S dpkg -i com.*"
    printf "\033[34m[SilentPwn]\033[0m Installation complete.\n"
    printf "\033[34m[SilentPwn]\033[0m Respring device? (y/n): "
    read -r respring_choice
    if [ "$respring_choice" = "y" ] || [ "$respring_choice" = "Y" ]; then
        ssh mobile@$IP "echo '$password' | sudo -S killall -9 SpringBoard"
        printf "\033[34m[SilentPwn]\033[0m Device resprung.\n"
    else
        printf "\033[34m[SilentPwn]\033[0m Device not resprung.\n"
    fi
else
    printf "\033[34m[SilentPwn]\033[0m Package not installed.\n"
fi
