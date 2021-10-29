#!/bin/bash
#This is the script of the password manager project.
function input_password()
{
pwd=""
while [ 1 ]
do
	read -p "$print" -s -n 1 pass
	if [[ $pass == $'\0' ]]
	then
		break
	elif [[  $pass == $'\177' ]]
	then
		len=${#pwd}
		if [[ $len -ne 0 ]]
		then
			pwd=${pwd%?}
			print=$'\b \b'
		else
			print=$'\0'
		fi
	else
		print="*"
		pwd=$pwd$pass
	fi
done
echo "$pwd"
}
function set_password()
{
	while [ 1 ]
	do
		echo  -en "\t\t\t\t\t\t\tEnter the password  : " 
		pass1=$( input_password )
		echo -en "\n\t\t\t\t\t\t\tReconfirm password  : "
		pass2=$(input_password)
		if [[ $pass1 == $pass2 ]]
		then
			echo -en "\n\t\t\t\t\t\t\tDo you wish to have a security question (Y\N) "
			read -n 1 sec
			if [[ $sec != "Y" ]]
			then
				touch $1
				echo -e "$1\n$pass1\nNULL\nNULL">$1
			else
				echo -en "\n\t\t\t\t\t\t\tEnter the question :"
				read ques
				echo -en "\t\t\t\t\t\t\tEnter Answer :"
				read ans
				touch $1
				echo -e "$1\n$pass1\n$ques\n$ans">$1
			fi
			echo -e "\n\t\t\t\t\t\t\tProfile Created."
			echo -en "\t\t\t\t\t\t\tPress any key to exit. "
			read -n 1 exit_stop
			break;
		else
			echo -e "\n\t\t\t\t\t\t\tPassword Doesn't Match."
		fi
	done
}
IFS="\n"
function sign_up()
{
	clear
	echo  -en "\n\n\t\t\t\t\t\t\tEnter user name : \n\t\t\t\t\t\t\t"
	while [ 1 ]
	do
	read  var
	temp='^'$var'$'
	if [[ $(ls -1 | egrep $temp | wc -l ) -eq 1 ]]
	then 
		clear
		echo -e "\t\t\t\t\t\t\tUsername Exists."
		echo -en "\t\t\t\t\t\t\tPlease enter a new username :\n\t\t\t\t\t\t\t"
	else
		set_password $var;
		break;
	fi
	done
}
	choice=0;
	until [[ $choice -eq 4  ]]
	do
		clear
		echo -e "\t\t\t\t\t\t\tWelcome to password mananager\n"
		echo -e "\t\t\t\t\t\t\t1. Sign Up           :"
		echo -e "\t\t\t\t\t\t\t2. Log  in           :"
		echo -e "\t\t\t\t\t\t\t3. Forgot Password   :"
		echo -e "\t\t\t\t\t\t\t4. Exit              : "
		echo -en "\t\t\t\t\t\t\t   Enter your choice : \n\t\t\t\t\t\t\t"
		read -n 1 choice
		
		case $choice in
			1) sign_up ;;
			2) log_in ;;
			3) forgot_pwd;;
			4) echo -e "\n\t\t\t\t\t\t\tExiting....";
			     break;;
			*) echo "Invalid choice";;
			esac
	done
