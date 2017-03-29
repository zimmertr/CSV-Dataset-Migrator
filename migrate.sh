#!/bin/bash
#####################################################################################################################
#####################################################################################################################
###CSV Dataset Migrator is an application that manages CSV datasets. When called, it will check the contents of   ###
###the ./incoming/ directory for .csv.gz archives and, if detected, will extract and migrate the contents to      ###
###the ./data/ directory. Supports logging, error handling, emails, exit codes, and interactive problem solving.  ###
### 														  ###
###Run the application manually:                 $./migrate.sh		                			  ###
###Run the application with a custom timeout:    $./migrate.sh 15						  ###
###Run the application hourly with cron:         0 * * * * /home/admin/migrate.sh 0                               ###
###														  ###
###WARNING: Script must be located in the same directory as ./data/ and ./incoming/.                              ###
#####################################################################################################################
#####################################################################################################################
###Features: 													  ###
###    - Accepts a single integer parameter which serves as a timeout for several interactive elements.           ###
###    - Supports 'quiet mode' by passing '0' as the timeout value. Helpful for executing with cron.              ###
###    - Has functionality to detect if a filename exists and allows Skipping, Overwriting, or Renaming the file. ###
###    - Allows user to exit the program prematurely if they decide not to Skip, Overwrite, or Rename the file.   ###
###    - Uses lock files to prevent application collision in the event of a previous job taking a long time.      ###
###    - Program will not execute if ./incoming/ directory does not contain any .csv.gz archives.                 ###
###    - Supports exit codes to indicate whether the program terminated successfully or prematurely.              ###
###    - Supports robust logging including log-levels.                                                            ###
###    - Supports the ability to view log file while executing or to email the log file using an interactive CLI. ###
###    - If an email is requested, an additional log file is generated which displays the directory structures.   ###
###    - Progress of the application is indicated to the user by incrementing dots as files are migrated.         ###
###    - Has basic error handling.                                                                                ###
#####################################################################################################################
 



echo
echo "****************************************"
echo "**********CSV Dataset Migrator**********"
echo "****************************************"
echo




#If user doesn't provide a timeout, default to 5 seconds. If user provides '0' as the timeout, skip log questions. Do not allow negative timeouts.  
if [[ $1 -gt -1 ]]
then
	timeout=$1
else
	echo "Invalid timeout specified."
	echo "$(date) - [ERROR] - An invalid timeout was specified. Cannot continue." >> output.log 2>&1
	echo
	exit 1
fi
if [[ $# -eq 0 ]]
then
	timeout=5
fi




#Ensure that the last job isn't still executing to avoid collisions.  
if [[ -f "migrate.lck" ]]
then
        echo "Is the last job still running? If you're sure it's not, please delete ./migrate.lck to continue." && echo 
        echo "$(date) - [ERROR] - A lock file exists. Cannot continue. " >> output.log 2>&1
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
	echo "****************************************" >> output.log 2>&1
	echo "**********CSV Dataset Migrator**********" >> output.log 2>&1
	echo "****************************************" >> output.log 2>&1
	echo >>  output.log 2>&1
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
                        read -t $timeout -n 1 -sp "A file named $fileName already exists. Skip/Overwrite/Rename the file or Exit? (s/o/r/e) (Skip after $timeout second timeout)" srae
			echo

			if [ ! -z $srae ]
			then

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
						rm $i >> /dev/null 2>&1
						break;;


					[Ee]* ) echo "$(date) - [ERROR] - CSV Dataset Migrator was interrupted before completion." >> output.log 2>&1;
						rm migrate.lck;
						echo
						exit 1;;


					* ) echo "Please answer with (Ss/Rr/Aa/Ee)." && echo
				esac 
			else
				break
			fi 
                done
        
    


        #If no files with that name exist... unzip the contents to ./data/ and delete the archive.
        else
        
                echo "$(date) - [INFO] - Extracting $i to data..." >> output.log 2>&1
                gunzip -c $i > data/$fileName 2>&1
                echo "$(date) - [INFO] - Cleaning up old archive..." >> output.log 2>&1
		#Remove the file. Ignore error if the file was previously removed due to rename.
                rm $i >> /dev/null 2>&1 
        fi
done
echo && echo "$(date) - [INFO] - CSV Dataset Migrator has finished a job. " >> output.log 2>&1
echo "" >> output.log 2>&1
rm migrate.lck




echo && echo && read -t $timeout -n 1 -sp "CSV Dataset Migration has completed. Press 'y' to see the log file. ($timeout second timeout)" input
echo
if [ ! -z $input ]
then
	less output.log
fi




read -t $timeout -n 1 -sp "Press 'y' to email the log file to the administrator. ($timeout second timeout)" input
echo
if [ ! -z $input ]
then
	ls -lah data/ incoming/ > tree.log
        mutt -s "Log requested $(date)" -a "output.log" -a "tree.log" -- sysadmin@company.com
	rm tree.log
        echo "$(date) - [INFO] - An email of the output log was sent to the administrator." >> output.log 2>&1
fi
echo
exit
