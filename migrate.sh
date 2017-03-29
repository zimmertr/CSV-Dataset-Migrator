#!/bin/bash
echo
echo "******************************"
echo "*****CSV Dataset Migrator*****"
echo "******************************"
echo



#Ensure that the last job isn't still executing. 
if [[ -f "migrate.lck" ]]
then
	echo "Is the last job still running? If you're sure it's not, please delete ./migrate.lck to continue." && echo 
	echo "$(date) - [ERROR] - migrate.lck exists. Cannot continue. " >> output.log 2>&1
	exit 1
else
	touch migrate.lck
fi




#Check to see how many datasets are in 'incoming'. Ignore errors because ls throws a non-zero exit code when your glob returns no matches. 
numArchives=$((ls incoming/*.csv.gz | wc -l) 2> /dev/null)
if [[ $numArchives -lt 1 ]]
then
	#If there are no incoming datasets, exit with a status code.
	echo "There are no incoming archives to migrate. Exiting now..." && echo
	echo "$(date) - [ERROR] There were no .csv.gz archives in ./data/. Cannot continue." >> output.log 2>&1
	rm migrate.lck
	exit 1 
else
	echo "There are $numArchives archives to migrate. Migrating now..." && echo
	echo "" >> output.log 2>&1
	echo "$(date) - [INFO] - CSV Dataset Migrator has started a new job. Migrating $numArchives archives now." >> output.log 2>&1
fi




#For each archive in `incoming`, extract it and place it in ./data/. Trim off unneccessary information.
for i in $(ls incoming/*.csv.gz)
do
	echo -n .
	fileName=$(echo $i | sed 's@.*/@@' | sed 's/\.gz.*$//')

	#If a file with that name already exists prompt user for action.
	if [ -f "data/$fileName" ]
	then
		echo && echo
		while true
		do
			read -p "A file named $fileName already exists within ./data/. Would you like to Skip/Overwrite/Rename the file or Exit the program? (s/o/r/e) " srae
			case $srae in
				[Ss]* ) echo "$(date) - [WARN] - A file named $fileName already exists within ./data/. This CSV dataset has been skipped." >> output.log 2>&1; 
					break;;
				
				[Oo]* ) echo "$(date) - [WARN] - A file named $fileName already exists within ./data/. The old CSV dataset has been overwritten by the new CSV dataset." >> output.log 2>&1; 
					gunzip -c $i > data/$fileName 2>&1; 
					break;;
				
				[Rr]* ) read -p "Please enter a new file name: " newName; 
					while [ -f "data/$newName" ]
					do
						read -p "A file named $newName already exists within ./data/. Please enter a new filename: " newName;
					done;
					echo "$(date) - [WARN] - The file named $fileName already exists within ./data/. The file was renamed to $newName." >> output.log 2>&1; 
					gunzip -c $i > data/$newName 2>&1; 
					break;;
				
				[Ee]* ) echo "$(date) - [ERROR] - CSV Dataset Migrator was interrupted before completion." >> output.log 2>&1; 
					echo
					rm migrate.lck;
					exit;;
				
				* ) echo "Please answer with (Ss/Rr/Aa/Ee)."
			esac	
		done
	


	#If no files with that name exist... unzip the contents to ./data/ and delete the archive.
	else
	
		echo "$(date) - [INFO] - Extracting $i to data..." >> output.log 2>&1
		gunzip -c $i > data/$fileName 2>&1
		echo "$(date) - [INFO] - Cleaning up old archive..." >> output.log 2>&1
		rm $i
	fi
done
echo "$(date) - [INFO] - CSV Dataset Migrator has finished a job. " >> output.log 2>&1
echo "" >> output.log 2>&1
rm migrate.lck




#Ask the user if they would like to see the log. Open it in less so user can scroll.
echo && echo 
while true
do
	read -p "CSV Dataset Migrator has finished. Would you like to see the log? (y/n) " yn
	case $yn in
		[Yy]* ) less output.log; 
			break;;

		[Nn]* ) echo; 
			break;;

		* ) echo "Please answer with (Yy/Nn)."
	esac
done




#Ask if the user would like the log file emailed to them. Open mutt for interactive email.
ls -lah data/ incoming/ > tree.log
while true
do
	read -p "Would you like the log file to be emailed to you? (y/n) " yn
	case $yn in
		[Yy]* ) echo; 
			mutt -s "Log requested $(date)" -a "output.log" -a "tree.log" -- sysadmin@company.com; 
			echo "$(date) - [INFO] - An email of the output log was sent to the administrator." >> output.log 2>&1
			break;;

		[Nn]* ) echo; 
			break;;
		* ) echo "Please answer with (Yy/Nn)."
	esac
done
rm tree.log
exit
