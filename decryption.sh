#!/bin/bash

if [[ "$1" == "" || "$2" == "" ]]
then
	echo -n "Error: Null Arguments"
	exit
fi
IFS=""

str="$1"
len_code=${#str}

################## Retrieving the length of the key ################

len_key="${str##*b}"                       
#echo $len_key


################## Retrieving the length of the password ###########

t1=${str##*a}
len_id=${t1%b*}
#echo $len_id 


################## Retrieving the matrix elements ##################

mat_str="${str%a*}"
#echo $mat_str
#echo ${#mat_str}

l=$(echo "${#mat_str}" | awk '{print int(sqrt($1))}')
#echo $l

mat_str_len=${#mat_str}


################## Forming the matrix ##############################

declare -A mat
declare -A main_mat
for (( i=0;i<l;i++))
do
		for (( j=0;j<l;j++ ))
		do
			if [[ i%2 -eq 0 ]]
			then
				#echo ${mat_str:j:1}
				mat[$i,$j]="${mat_str:j:1}"
				main_mat[$i,$j]="${mat[$i,$j]}"
				#echo ${mat[$i,$j]}
			else
				
				mat[$i,$l-$j-1]="${mat_str:l-j-1:1}"
				main_mat[$i,$j]="${mat[$i,$l-$j-1]}"
				#echo ${mat[$i,$l-$j-1]}
			fi
		done
		mat_str="${mat_str:l}"
done
: '
for (( i=0;i<l;i++ ))
do
	for (( j=0;j<l;j++ ))
	do
		if [[ i%2 -eq 0 ]]
		then
			echo -n ${main_mat[$i,$j]} " "
			
		else
			echo -n ${main_mat[$i,$j]} " "
		fi
	done
	echo
done
'
################ Transpose of the matrix ############################


for (( j=0;j<l;j++ ))
do
		for (( i=j+1;i<l;i++ ))
		do
			#echo " swapping ${main_mat[$i,$j]} with ${main_mat[$j,$i]} " 
			tmp="${main_mat[$i,$j]}"
			main_mat[$i,$j]="${main_mat[$j,$i]}"
			main_mat[$j,$i]="$tmp"
		done
done


: '
echo -e "\nTranspose\n"

for (( i=0;i<l;i++ ))
	do
		for (( j=0;j<l;j++ ))
		do
			echo -n ${main_mat[$i,$j]} " "
		done
		echo
	done

'
################ Undoing the shuffling ###############################
#echo "Row swapping"

for (( j=0;j<l/2;j++ ))
do
	for (( i=1;i<l;i+=2 ))
	do
		h=$(( $l-$j-1 ))
		#echo " swapping ${main_mat[$i,$j]} with ${main_mat[$i,$h]} "
		tmp="${main_mat[$i,$j]}"
		main_mat[$i,$j]="${main_mat[$i,$h]}"
		main_mat[$i,$h]="$tmp"
	done
done


: '
for (( i=0;i<l;i++ ))
do
	for (( j=0;j<l;j++ ))
	do
		echo -n ${main_mat[$i,$j]} " "
	done
	echo
done
'

#echo "Column swapping"


for (( i=0;i<l/2;i++ ))
do
	for (( j=0;j<l;j+=2 ))
	do
		h=$(( $l-$i-1 ))
		#echo " swapping ${main_mat[$i,$j]} with ${main_mat[$h,$j]} "
		tmp="${main_mat[$i,$j]}"
		main_mat[$i,$j]="${main_mat[$h,$j]}"
		main_mat[$h,$j]="$tmp"
	done
done

#echo -e "\nUndo the shuffling \n"
: '
for (( i=0;i<l;i++ ))
do
	for (( j=0;j<l;j++ ))
	do
		echo -n ${main_mat[$i,$j]} " "
	done
	echo
done
'

################## Retrieving the main string ######################

#echo -e "\nTaking out the main string\n"

var1=0
var2=0
l2=$l
tl=$(( $len_key + $len_id ))


while [[ $var1 -lt $l ]] && [[ $var2 -lt $l2 ]]
do
	for (( i=var2;i<l2;i++ ))
	do
		echo -n ${main_mat[$var1,$i]}
	done
	var1=$(( var+1 ))
	
	for (( i=var1;i<l;i++ ))
	do
		echo -n ${main_mat[$i,$(( l2-1 ))]}
	done
	l2=$(( l2-1 ))
	
	if [[ $var1 -lt $l ]]
	then
		for (( i=l2-1;i>=var2;i-- ))
		do
			echo -n ${main_mat[$(( l-1 )),$i]}
		done
		l=$(( l-1 ))
	fi
	if [[ $var2 -lt $l2 ]]
	then
		for (( i=l-1;i>=var1;i-- ))
		do
			echo -n ${main_mat[$i,$var2]}
		done
		var2=$(( var2+1 ))
	fi
done > codelin3
new_str=$(cat codelin3)
$(shred -u codelin3)
new_str=${new_str:0:tl}
new_str=$(echo $new_str | rev )
#echo $new_str
pass=${new_str:(( len_key/2 )):len_id}          ##### Retrieving the password
#echo $pass
key=$( echo ${new_str/$pass/""} )             ##### Retrieving the key
#echo $key 



if [[ $key == $2 ]]
then
	echo "$pass"
else
	echo -n ""
fi
