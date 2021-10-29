BEGIN{
	i=1
}

{
	if(NR > 4 && (NR%4==1 || NR%4 ==2))
	{
		if(NR%4==1) 
			printf "\n%56s%d : %-20s"," ",i,$0
		else
		{
			print " "$0
			i++
		}
	}
} 
