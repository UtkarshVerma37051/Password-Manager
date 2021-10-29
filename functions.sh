function main_menu()																		# Main UI at starting
{
	echo -e "\t\t\t\t\t\t\tWelcome to password mananager\n"
	echo -e "\t\t\t\t\t\t\t1. Sign Up           :"
	echo -e "\t\t\t\t\t\t\t2. Log  in           :"
	echo -e "\t\t\t\t\t\t\t3. Forgot Password   :"
	echo -e "\t\t\t\t\t\t\t4. Exit              : "
	echo -en "\t\t\t\t\t\t\t   Enter your choice : "
}

#*********************************************************Sign Up***********************************************************************
function sign_up()
{
	clear
	echo  -en "\n\n\t\t\t\t\t\t\tEnter user name    (E to exit) : \n\t\t\t\t\t\t\t"
	while [ 1 ]
	do
		read  var
		while [[ -z "$var" ]]
		do
			echo -en "\t\t\t\t\t\t\t"
			read var
		done
		if [[  $var ==  "E" ]]
		then
			break
		fi
		temp='^'$var.ppu'$'
		if [[ $(ls -1 | egrep $temp | wc -l ) -eq 1 ]]													# Checking if user already exists or not.
		then 
			echo -e "\n\t\t\t\t\t\t\tUsername Exists."
			echo -en "\t\t\t\t\t\t\tPlease enter a new username : "
		else
			set_password $var;																		# If user doesn't exists, creating a password for user
			break;
		fi
	done
}

function set_password()																	#Function to set the password for a user-id.
{
	while [ 1 ]
	do
		echo  -en "\n\t\t\t\t\t\t\tEnter the password (E to exit): " 
		pass1=$( input_password )															# Returning the password enterd through input_password function
		if [[ $pass1 == "E" ]]
		then
			return
		fi
		echo -en "\n\n\t\t\t\t\t\t\tReconfirm password (E to exit): "
		pass2=$(input_password)
		if [[ $pass2 == "E" ]]
		then
			return
		fi
		if [[ $pass1 == $pass2 ]]																# Validating the entered password
		then
			echo -en "\n\n\t\t\t\t\t\t\tDo you wish to have a security question (Y\N) : "			# Inserting a security question (optional)
			read  sec
			while [[ -z "$sec" ]]
				do
					echo -en "\t\t\t\t\t\t\t"
					read sec
				done
			usr=$1
			#pwd=${usr:0:${#usr}/2}$pass1${usr:${#usr}/2}									#Adding half charcaters of username at start and end of passsword
			#encoded=$(./encrypt.o $pwd $pass1)
			encoded=$(awk -f encrypt.awk "$pass1" "$1")
			if [[ $sec != "Y" ]]
			then
				touch "$1.ppu"
				echo -e "$1\n$encoded\nNULL\nNULL">"$1.ppu"								# If 'N' then entring NULL at place of Question and answer in file
			else
				echo -en "\n\t\t\t\t\t\t\tEnter the question :"
				read ques
				while [[ -z "$ques" ]]
				do
					echo -en "\t\t\t\t\t\t\t"
					read ques
				done
				echo -en "\n\t\t\t\t\t\t\tEnter Answer :"
				read ans
				while [[ -z "$ans" ]]
				do
					echo -en "\t\t\t\t\t\t\t"
					read ans
				done
				touch $1.ppu
				enc_ans=$(awk -f encrypt.awk "$ans" "$1")
				echo -e "$1\n$encoded\n$ques\n$enc_ans">"$1.ppu"									# If 'Y' then storing it in the file
			fi
			echo -e "\n\n\t\t\t\t\t\t\tProfile Created."
			echo -en "\t\t\t\t\t\t\tPress any key to exit. "									# Expecting a key to be pressed to exit from the sign_up section.
			read
			break;
		else
			echo -e "\n\t\t\t\t\t\t\tPassword Doesn't Match."
		fi
	done
}

function input_password()
{
pwd=""
while [ 1 ]
do
	read -p "$print" -s -n 1 pass																#taking character one by one
	if [[ $pass == $'\0' ]]																		
	then
		if [[ $pwd == "" ]]
		then
			continue
		else
			break
		fi
	elif [[  $pass == $'\177' ]]																# For Backspace
	then
		if [[ ${#pwd} -ne 0 ]]																#If password is null it should not delete the earlier characters
		then
			pwd=${pwd%?}																	#deleting last characters
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

#********************************************************Forgot Password***********************************************************
function forgot_password()
{
	clear
	while [[ 1 ]]
	do
		IFS=$'\n'
		echo -en "\n\t\t\t\t\t\t\tEnter user name (E to exit) : "
		read usrnm
		while [[ -z "$usrnm" ]]																#Reading till valid input is entered
		do
			echo -en "\t\t\t\t\t\t\t"
			read usrnm
		done
		if [[ $usrnm == "E" ]]																#Exit case
		then
			return 0
		fi
		if [[  $(ls | egrep "^$usrnm.ppu$") == "" ]]											#If invalid username is entered
		then
			echo -en "\n\t\t\t\t\t\t\tWrong Username."
			echo
		else
			question=$(cat "$usrnm.ppu" | head -3 | tail -1)									#Extracting the question from the file
			if [[  $question == "NULL" ]]														#Checking if question present or not
			then
				echo -e "\n\t\t\t\t\t\t\tNo question is set for this account.";
				echo -en "\n\t\t\t\t\t\t\tPress any key to exit.";
				read
				clear
			else
				encoded_answer=$(cat "$usrnm.ppu" | head -4 | tail -1)									#Extracting the answer
				answer=$(bash decryption.sh "$encoded_answer" "$usrnm")
				echo -e "\n\t\t\t\t\t\t\tQuestion : $question"
				while [[ 1 ]]
				do
					echo -en "\n\t\t\t\t\t\t\tAnswer   : "
					read ans
					while [[ -z "$ans" ]]														#Reading till valid answer is entered
					do
						echo -en "\t\t\t\t\t\t\t"
						read ans
					done
					if [[ $ans == "E" ]]
					then
						return
					fi
					if [[ $ans == $answer ]]													#If entered answer is correct, then ask for new password
					then
						while [[ 1 ]]
						do
							echo  -en "\n\t\t\t\t\t\t\tEnter the password  : " 
							pass1=$( input_password )
							if [[ $pass1 == "E" ]]
							then
								return
							fi
							echo -en "\n\t\t\t\t\t\t\tReconfirm password  : "
							pass2=$(input_password)
							if [[ $pass2 == "E" ]]
							then
								return
							fi
							if [[ $pass1 == $pass2 ]]
							then
								encoded=$(awk -f encrypt.awk "$pass1" "$usrnm")
								sed '2s/.*/'$encoded'/1' "$usrnm.ppu" > temp
								cat temp > "$usrnm.ppu"
								rm temp 
								echo -en "\n\n\t\t\t\t\t\t\tPassword Changed.\n\t\t\t\t\t\t\tPress any key to exit."
								read
								return
							else																
								echo -en "\n\n\t\t\t\t\t\t\tPassword not matched!\n"		#If re-entered password doesn't matches, prompt password not matched
							fi
						done
						break
					else
						echo -e "\n\t\t\t\t\t\t\tWrong Answer!"								#If answer is incorrect, then prompt answer not matched
					fi
				done
			fi
		fi
	done
}

#********************************************************Log In*****************************************************
function log_in()
{
	clear
	echo -e "\n"
	while [[ 1 ]]
	do
		printf "%56s %-20s" " " "Enter Username (E to exit) : "
		read usr
		while [[ -z "$usr" ]]																	#Reading till valid choice is entered
		do
			echo -en "\t\t\t\t\t\t\t"
			read usr
		done
		if [[ $usr == "E" ]]
		then
			return 
		fi
		if [[  $(ls | egrep "^$usr.ppu$") == "" ]]												#If invalid username is entered
		then
			printf "%56s %-20s\n\n" " " "User Not Found"
		else
			while [[ 1 ]]
			do
				printf "\n%56s %-20s" " " "Enter Password (E to exit) : "
				inp_pass=$(input_password)
				if [[ $inp_pass == "E" ]]
				then
					return
				fi
				enc_pass=$(head -n2 "$usr.ppu" | tail -n1)
				act_pass=$(bash decryption.sh "$enc_pass" "$usr")
				if [[ $inp_pass == $act_pass ]]
				then
					flag=0
					while [[ 1 ]]
					do
						if [[ $flag == 0 ]]
						then
							clear
							echo -e "\n"
							printf "%56s%-26s%s\n" " " "1. View entry"        ":"
							printf "%56s%-26s%s\n" " " "2. Add an entry"        ":"
							printf "%56s%-26s%s\n" " " "3. Remove an entry" ":"
							printf "%56s%-26s%s\n" " " "4. Change an entry" ":"
							printf "%56s%-26s%s\n" " " "5. Change master password" ":"
							printf "%56s%-26s%s\n" " " "6. Delete Profile"       ":"
							printf "%56s%-26s%s\n" " " "7. Exit"                         ":"
						fi
						flag=0;
						printf "%56s%-20s%s " " " "   Enter your choice"  ":"	
						read choice
						while [[ -z "$choice" ]]
						do
							echo -en "\t\t\t\t\t\t\t   "
							read choice
						done
						case $choice in
							1) 	View_Entry "$usr"; clear;flag=0 ;;
							2) 	Add_Entry "$usr"; clear;flag=0 ;;									
							3) 	Remove_Entry "$usr"; clear;flag=0 ;;
							4) 	Change_Entry "$usr" ; clear;flag=0 ;;
							5) 	Change_Master_Password "$usr"; clear;flag=0 ;;
							6) 	echo -e "\n\t\t\t\t\t\t\tAre you sure you want to delete your profile."
								echo -e "\n\t\t\t\t\t\t\tYou will lose are your data."
								echo -en "\n\t\t\t\t\t\t\tPress any key (Y/N) : "
								read choice
								if [[ $choice == "Y" ]]
								then
									rm "$usr.ppu"
									echo -e "\n\t\t\t\t\t\t\tYou are about to logout from the session."
									echo -en "\n\t\t\t\t\t\t\tPress any key to exit : "
									read
									return
								fi
								clear ;;
							7) 	return;;
							*)	echo -e "\n\t\t\t\t\t\t\t   Invalid choice!\n"
								flag=1;;
						esac
					done
				else
					echo
					printf "%57s%-20s\n" " " "Wrong Password"
				fi
			done
		fi
	done		
}

function View_Entry()
{
	line=$(sed -n '$=' "$1.ppu")
	flag=0
	if [[ $line == "4" ]]																#If no entries are present
	then
		clear
		echo -e "\n\t\t\t\t\t\t\tNo entries present."
		echo -en "\n\t\t\t\t\t\t\tPress any key to exit."
		read
		return
	fi
	while [[ 1 ]]
	do
		
		if [[ $flag == 0 ]]
		then
		clear
		awk -f print_details.awk "$1.ppu"
		fi
		echo -en "\n\t\t\t\t\t\t\t    Enter your choice (E to exit) : " 
		read choice
		while [[ -z "$choice" ]]
		do
			echo -en "\t\t\t\t\t\t\t   ";
			read choice
		done
		if [[ $choice == "E" ]]
		then
			return
		fi
		if ! [[ $choice =~ ^[0-9]+$ ]]
		then 
			echo -e "\n\t\t\t\t\t\t\t   Invalid choice"
			flag=1
		continue
		fi
		if [[  $choice -le 0 || $choice -gt $(($line/4 - 1)) ]]
		then 
			echo -e "\n\t\t\t\t\t\t\t   Invalid choice"
			flag=1
			continue
		fi
		flag=0
		clear
		awk -v var=$((choice*4+1)) '
					BEGIN{
						arr[0]="Note"
						arr[1]="Website"
						arr[2]="User ID" 
						arr[3]="Password"
						i=1
					}
					{
						if (NR >=var && NR <= var+3 )
						{
							if (NR%4 == 3)
							{
								cmd = "bash decryption.sh " "\"" $0 "\" " "\"" substr(FILENAME,1,length(FILENAME)-4) "\""
								cmd | getline pass
								printf "\n\t\t\t\t\t\t\t%d) %-10s: %s\n",i++,arr[NR%4],pass
							}
							else
							{
								printf "\n\t\t\t\t\t\t\t%d) %-10s: %s\n",i++,arr[NR%4],$0
							}
						}
					}' "$1.ppu"	
		echo -en "\n\t\t\t\t\t\t\tPress any key to exit."
		read
	done
}


function Add_Entry()
{
	clear
	echo -e "\n"
	while [[ 1 ]]
	do
		printf "%56s%20s" " " "Enter Website     (E to exit) : "
		read site_name
		while [[ -z "$site_name" ]]
		do
			echo -en "\t\t\t\t\t\t\t"
			read site_name
		done
		if [[ $site_name == "E" ]]
		then
			return
		fi
		printf "%56s%20s" " " "Enter ID          (E to exit) : "
		read ID
		while [[ -z "$ID" ]]
		do
			echo -en "\t\t\t\t\t\t\t"
			read ID
		done
		if [[ $ID == "E" ]]
		then
			return
		fi
		line=$(cat "$1.ppu" | egrep -n ''$site_name'' | cut -d ":" -f 1)
		for l in $line
		do
			id=$(sed -n ''$(($l+1))'p' "$1.ppu")
			if [[ $ID == $id ]]
			then
				echo -e "\n\t\t\t\t\t\t\tID already exists."
				continue
			fi
		done
		break
	done
	while [[ 1 ]]
	do
		printf "%56s%20s" " " "Enter password    (E to exit) : "
		pass1=$(input_password)
		if [[ $pass1 == "E" ]]
		then
			return
		fi
		echo
		printf "%56s%20s" " " "Re-enter password (E to exit) : "
		pass2=$(input_password)
		if [[ $pass2 == "E" ]]
		then
			return
		fi
		echo
		if [[ $pass1 == $pass2 ]]
		then
			echo -en "\n\t\t\t\t\t\t\tDo you wish to have a note (Y/N): "
			read choice
			while [[ -z "$choice" ]]
			do
				echo -en "\t\t\t\t\t\t\t"
				read choice
			done
			encoded=$(awk -f encrypt.awk "$pass1" "$1")
			if [[ $choice == "Y" ]]
			then
				echo -en "\n\t\t\t\t\t\t\tEnter Note : "
				read note
				
				echo -e "$site_name\n$ID\n$encoded\n$note" >> "$1.ppu"
			else
				echo -e "$site_name\n$ID\n$encoded\nNULL" >> "$1.ppu"
			fi
			echo -en "\n\t\t\t\t\t\t\tEntry Added.\n\t\t\t\t\t\t\tPress any key to exit. "
			read
			break;
		else
			echo -e "\n\t\t\t\t\t\t\tPassword not matched"
		fi
	done	
}

function Remove_Entry()
{
	line=$((($(wc -l "$1.ppu" | cut -d " " -f 1)/4)-1))
	clear
	if [[ $line -eq 0 ]]
	then
		echo -e "\n\t\t\t\t\t\t\tNo Entries Present."
		echo -en "\n\t\t\t\t\t\t\tPress any key to exit : "
		read
		return
	fi
	clear
	choice=1
	while [[ 1 ]]
	do
		if [[ $choice == 1 || $choice == 2  ]]
		then
			echo -e "\n\t\t\t\t\t\t\t1. Select from the list : "
			echo -e "\n\t\t\t\t\t\t\t2. Enter Details        : "
			echo -e "\n\t\t\t\t\t\t\t3. Exit                 :"
			echo -en "\n\t\t\t\t\t\t\t   Enter choice : "
		fi
		read choice
		while [[ -z "$choice" ]]
		do
			echo -en "\t\t\t\t\t\t\t   "
			read choice
		done
		case $choice in
			1)	while [[ 1 ]]
				do
					clear
					line=$((($(wc -l "$1.ppu" | cut -d " " -f 1)/4)-1))											#Checking again after updation
					if [[ $line -eq 0 ]]
					then
						echo -e "\n\t\t\t\t\t\t\tNo Entries Present."
						echo -en "\n\t\t\t\t\t\t\tPress any key to exit : "
						read
						return
					fi
					echo -e "\n\t\t\t\t\t\t\tTotal Entries : $line"
					printf "\n\t\t\t\t\t\t\t    %-20s %s\n" "Website" "ID"
					awk -f print_details.awk "$1.ppu"
					while [[ 1 ]]
					do
						echo -en "\n\t\t\t\t\t\t\tEnter your choice (E to exit) : "
						read todel
						while [[ -z "$todel" ]]
						do
							echo -en "\t\t\t\t\t\t\t"
							read todel
						done
						if [[ $todel == "E" ]]
						then
							break
						fi		
						
						if ! [[ $todel =~ ^[0-9]+$ ]]
						then 
							echo -e "\n\t\t\t\t\t\t\t   Invalid choice"
							continue
						fi
						if [[ $todel -le 0 || $todel -gt $line ]]
						then
							echo -e "\n\t\t\t\t\t\t\t   Invalid choice."
						else
							sed -n ''$(($todel*4+1))','$(($todel*4+4))'!p' "$1.ppu">temp
							cat temp>"$1.ppu"
							rm temp
							printf "\n\t\t\t\t\t\t\tEntry Deleted.\n"
							printf "\t\t\t\t\t\t\tPress any key to cxit."
							read
							break
						fi
					done
					if [[ $todel == "E" ]]
					then
						break
					fi
				done
				clear ;;
			2) 	clear
				while [[ 1 ]]
				do
					echo -en "\n\t\t\t\t\t\t\tEnter Website (E to exit): "
					read website
					while [[ -z "$website" ]]
					do
						echo -en "\t\t\t\t\t\t\t"
						read website
					done
				if [[ $website == "E" ]]
				then
					clear
					break		
				fi
				cmd="{5..$line..4}"
				let flag=0;
				for i in $(eval echo {5..$((($line+1)*4))..4})
				do
					str=$(sed -n ''$i'p' "$1.ppu")
					if [[ $str == "$website" ]]
					then
						flag=1
						break
					fi
				done
				if [[ $flag -eq 0 ]]
				then
					echo -e "\n\t\t\t\t\t\t\tNo such entry found."
				else
					while [[ 1 ]]
					do
						echo -en "\n\t\t\t\t\t\t\tEnter ID      (E to exit): "
						read id
						while [[ -z "$id" ]]
						do
							echo -en "\t\t\t\t\t\t\t"
							read id
						done
						if [[ $id == "E" ]]
						then
							break
						fi
						let flag=0;
						for i in $(eval echo  {6..$((($line+1)*4))..4})
						do
							str=$(sed -n ''$i'p' "$1.ppu")
							if [[ $str == "$id" && $(sed -n ''$(($i-1))'p' "$1.ppu") == "$website" ]]
							then
								flag=1
								sed -n ''$(($i-1))','$(($i+2))'!p' "$1.ppu">temp
								echo -e "\n\t\t\t\t\t\t\tEntry Deleted."
								cat temp>"$1.ppu"
								rm temp
								if [[ $(sed -n '$=' "$1.ppu") -eq 4 ]]
								then
									echo -e "\n\t\t\t\t\t\t\tNo Entries Present."
									echo -en "\n\t\t\t\t\t\t\tPress any key to exit."
									read 
									return
								fi
								echo -en "\n\t\t\t\t\t\t\tPress any key to exit."
								read
								break
							fi
						done
						if [[ $flag -eq 0 ]]
						then
							echo -e "\n\t\t\t\t\t\t\tNo such ID for $website"
							continue
						fi
						if [[ $(sed -n '$=' "$1.ppu") -eq 4 ]]
						then
							echo -e "\n\t\t\t\t\t\t\tNo Entries Present."
							echo -en "\n\t\t\t\t\t\t\tPress any key to exit : "
							read
							return
						fi
					done
					if [[ $id == "E" ]]
					then 
						clear
						break
					fi
				fi
				done ;;
			3) 	break;;
			*) 	echo -e "\n\t\t\t\t\t\t\tInvalid Choice."
				echo -en "\n\t\t\t\t\t\t\t   Enter choice : ";;
		esac
	done
}

function Change_Entry()
{
	line=$(sed -n '$=' "$1.ppu")
	clear
	if [[ $line -eq 4 ]]
	then
		echo -e "\n\t\t\t\t\t\t\tNo Entries Present."
		echo -en "\n\t\t\t\t\t\t\tPress any key to exit."
		read
		return
	fi
	while [[ 1 ]]
	do
		clear
		echo -e "\n\t\t\t\t\t\t\tTotal Entries : $(($line/4 - 1))"
		printf "\n\t\t\t\t\t\t\t    %-20s %s\n" "Website" "ID"
		awk -f print_details.awk "$1.ppu"
		echo -en "\n\t\t\t\t\t\t\tEnter your choice (E to exit) : "
		read tochange
		while [[ -z "$tochange" ]]
		do
			echo -en "\t\t\t\t\t\t\t"
			read tochange
		done
		if [[ $tochange == "E" ]]
		then
			return
		fi
		if ! [[ $tochange =~ ^[0-9]+$ ]]
		then 
			echo -e "\n\t\t\t\t\t\t\tInvalid choice"
		continue
		fi
		if [[  $tochange -le 0 || $tochange -gt $(($line/4 - 1)) ]]
		then 
			echo -e "\n\t\t\t\t\t\t\tInvalid choice"
			continue
		fi
		flag=0
		while [[ 1 ]]
		do
			if ! [[ $flag == 1 ]]
			then
				clear
				awk  -v var=$(($tochange * 4+1)) '
					BEGIN{
						arr[0]="Note"
						arr[1]="Website"
						arr[2]="User ID" 
						arr[3]="Password"
						i=1
					}
					{
						if (NR >=var && NR <= (var+3) )
						{
							if(NR%4==3)
							{
								cmd = "bash decryption.sh " "\"" $0 "\" " "\"" substr(FILENAME,1,length(FILENAME)-4) "\""
								cmd | getline result
								printf "\n\t\t\t\t\t\t\t%d) %-10s: %s\n",i++,arr[NR%4],result
							}
							else
								printf "\n\t\t\t\t\t\t\t%d) %-10s: %s\n",i++,arr[NR%4],$0
						}
					}' "$1.ppu"
			fi
			echo -en "\n\t\t\t\t\t\t\tEnter your choice (E to exit ) : "
			read ch
			while [[ -z "$ch" ]]
			do
				echo -en "\t\t\t\t\t\t\t"
				read ch
			done
			if [[ $ch == "E" ]]
			then
				break
			fi
			if ! [[ $ch == "1" || $ch == "2" || $ch == "3" || $ch == "4" ]]
			then
				echo -e "\n\t\t\t\t\t\t\tInvalid Choice!"
				flag=1
				continue
			fi
			arr[1]="Website"
			arr[2]="User ID"
			arr[3]="Password"
			arr[4]="Note"
			space=$((11-${#arr[$ch]}))														#allignment purpose
			printf "\n\t\t\t\t\t\t\tEnter ${arr[$ch]}"
			for (( i=1;i<=$space; i++ ))
			do
			echo -n " "
			done
			printf  "%s" " (E to exit ) : "
			read choose
			while [[ -z "$choose" ]]
			do
				echo -en "\t\t\t\t\t\t\t"
				read choose
			done
			if [[ $choose == "E" ]]
			then
				flag=0
				continue
			fi
			if [[ $ch == "3" ]]
			then
				choose=$(awk -f encrypt.awk "$choose" "$1")
			fi
			sed -n ''$(($tochange*4+$ch))'!p;'$(($tochange*4+$ch))'i'$choose'' "$1.ppu">temp			#replacing the specific line
			cat temp>"$1.ppu"
			rm temp
			echo -e "\n\t\t\t\t\t\t\t${arr[$ch]} Changed."
			echo -en "\n\t\t\t\t\t\t\tPress any key to exit."
			read
			flag=0
		done
	done
	clear
}


function Change_Master_Password()
{
	clear
	while [[ 1 ]]
	do
		echo  -en "\n\t\t\t\t\t\t\tEnter the password  : " 
		pass1=$( input_password )
		if [[ $pass1 == "E" ]]
		then
			return
		fi
		echo -en "\n\t\t\t\t\t\t\tReconfirm password  : "
		pass2=$(input_password)
		if [[ $pass2 == "E" ]]
		then
			return
		fi
		if [[ $pass1 == $pass2 ]]
		then
			encoded=$(awk -f encrypt.awk "$pass1" "$1")
			sed '2s/.*/'$encoded'/1' "$1.ppu" > temp
			cat temp > "$1.ppu"
			rm temp 
			echo -en "\n\n\t\t\t\t\t\t\tPassword Changed.\n\t\t\t\t\t\t\tPress any key to exit."
			read
			return
		else																
			echo -en "\n\n\t\t\t\t\t\t\tPassword not matched!\n"		
		fi
	done
}
