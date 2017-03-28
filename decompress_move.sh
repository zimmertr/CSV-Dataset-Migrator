#!/bin/bash
echo
echo "******************************"
echo "*****CSV Dataset Migrator*****"
echo "******************************"
echo


#Check to see how many datasets are in 'incoming'. Ignore errors because ls throws a non-zero exit code when your glob doesn't return any matches.
numArchives=$((ls incoming/*.csv.gz | wc -l) 2> /dev/null)
if [[ $numArchives -lt 1 ]]
then
	#If there are no incoming datasets, exit with a status code.
	echo "There are no incoming archives to parse. Exiting Now..."
	exit 1 
else
	echo "There are $numArchives archives to parse. Parsing Now..." && echo
fi



#For each archive in `incoming`, extract it and place it in `data`. #Trim off unneccessary information.
for i in $(ls incoming/*.csv.gz)
do
	echo -n .
	fileName=$(echo $i | sed 's@.*/@@' | sed 's/\.gz.*$//')


	if [ -f "data/$fileName" ]
	then
		echo && echo
		while true
		do
			read -p "$fileName already exists in 'data'. Would you like to Skip/Replace/Append the file or Exit the program? (s/r/a/e) " srae
			case $srae in
				[Ss]* ) echo "$(date) - [WARN] - A file named $fileName already exists within ./data/. This CSV dataset has been skipped." >> output.log 2>&1; break;;
				[Rr]* ) echo "$(date) - [WARN] - A file named $fileName already exists within ./data/. The old CSV dataset has been replaced with the new CSV dataset." >> output.log 2>&1; gunzip -c $i > data/$fileName 2>&1; break;;
				[Aa]* ) echo "$(date) - [WARN] - A file named $fileName already exists within ./data/. The new CSV dataset has had its name appended to preserve both files." >> output.log 2>&1; gunzip -c $i > data/$fileName 2>&1; break;;
				[Ee]* ) echo "$(date) - [ERROR] - CSV Dataset Migrator was interrupted before completion." >> output.log 2>&1; break 2;;
				* ) echo "Please answer with (Ss/Rr/Aa/Ee)."
			esac	
		done
	else
	
		echo "$(date) - [INFO] - Extracting $i to data..." >> output.log 2>&1
		gunzip -c $i > data/$fileName 2>&1
		echo "$(date) - [INFO] - Cleaning up old archive..." >> output.log 2>&1
		rm $i
	fi
done


#Ask the user if they would like to see the log
echo && echo 
while true
do
	read -p "CSV Dataset Migrator has finished. Would you like to see the log? (y/n) " yn
	case $yn in
		[Yy]* ) less output.log; exit;;
		[Nn]* ) echo; exit;;
		* ) echo "Please answer with (Yy/Nn)."
	esac
done
