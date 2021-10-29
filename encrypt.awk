function set()
{
	dir="L"
	left=0 
	up=0 
	down=len-1 
	right=len-1;
	count=0;
	declare -a temp
	temp=substr(ARGV[2],1,length(ARGV[2])/2) ARGV[1] substr(ARGV[2],(length(ARGV[2])/2+1))
	toreplace=length(temp);
	while(toreplace>=1)
	{
		if(dir=="L")
		{
			for(i=left;i<=right;i++)
				if(toreplace!=0)
				{
					mat[up][i]=substr(temp,toreplace--,1)
					#toreplace--
				}
			up++;
			dir="D";
		}
		else if(dir=="D")
		{
			for(i=up;i<=down;i++)
				if(toreplace!=0)
				{
					mat[i][right]=substr(temp,toreplace--,1)
					#toreplace--
				}
				right--;
			dir="R";
		}
		else if(dir=="R")
		{
			for(i=right;i>=left;i--)
				if(toreplace!=0)
				{
					mat[down][i]=substr(temp,toreplace--,1)
					#toreplace--
				}
			down--;
			dir="U";
		}
		else if(dir=="U")
		{
			for(i=down;i>=up;i--)
				if(toreplace!=0)
				{
					mat[i][left]=substr(temp,toreplace--,1)
					#toreplace--
				}
					
			left++;
			dir="L";
		}
	}
}

function shuffle()
{
	for(i=0;i<len/2;i++)
		for(j=0;j<len;j+=2)
		{
			tmp=mat[i][j]
			mat[i][j]=mat[N-i-1][j]
			mat[N-i-1][j]=tmp
		}
	for(i=1;i<len;i+=2)
		for(j=0;j<len/2;j++)
		{
			tmp=mat[i][j]
			mat[i][j]=mat[i][N-j-1]
			mat[i][N-j-1]=tmp
		}
}

function transpose()
{
	for(i=0;i<N;i++)
		for(j=i+1;j<N;j++)
		{
			tmp=mat[i][j];
			mat[i][j]=mat[j][i];
			mat[j][i]=tmp;
		}
}
function display()
{
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
			printf mat[i][j] " "
		print
	}		
}

BEGIN{
	len_pass=length(ARGV[1])
	len_key=length(ARGV[2])
	N=int(sqrt(len_pass+len_key)+2)
	len=N
	srand(systime());
	for(i=0;i<len;i++)
	{
		for(j=0;j<len;j++)
			mat[i][j]=int((rand()*1000)*rand()%10)
	}
	set()
	shuffle()
	transpose()
	for(i=0;i<len;i++)
		for(j=0;j<len;j++)
		{
			if(i%2 == 0)
				printf mat[i][j]
			else
				printf mat[i][len-j-1]
		}
	printf "a%db%d\n",length(ARGV[1]),length(ARGV[2])
}
