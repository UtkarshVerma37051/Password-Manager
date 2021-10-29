#!/bin/bash
#This is the script of the password manager project.
source ~/Scripting/bash/password\ manager\ project/functions.sh
IFS=$'\n'
choice=0
clear
main_menu
until [[ $choice -eq 4  ]]
do
	read   choice
	while [[ -z "$choice" ]]
	do
		echo -en "\t\t\t\t\t\t\t   "
		read choice
	done
	case $choice in
		1) sign_up ; clear ;  main_menu;;									
		2) log_in ; clear ; main_menu;;
		3) forgot_password; clear ; main_menu;;
		4) echo -e "\n\t\t\t\t\t\t\t   Exiting....";
		     break;;
		*) echo -e "\n\t\t\t\t\t\t\t   Invalid choice";
			echo -en "\n\t\t\t\t\t\t\t   Enter your choice : ";;
		esac
		unset choice
done
