# CSV Dataset Migrator

### Summary:
CSV Dataset Migrator is an application that manages CSV datasets. When called, it will check the contents of the ./incoming/ directory for .csv.gz archives and, if detected, will extract and migrate the contents to the ./data/ directory. Supports logging, error handling, emails, exit codes, and interactive problem solving.


### Features:
    - Accepts a single integer parameter which serves as a timeout for several interactive elements.  
    - Supports 'quiet mode' by passing '0' as the timeout value. Helpful for executing with cron. 
    - Has functionality to detect if a filename exists and allows Skipping, Overwriting, or Renaming the file.  
    - Allows user to exit the program prematurely if they decide not to Skip, Overwrite, or Rename the file.   
    - Uses lock files to prevent application collision in the event of a previous job taking a long time.      
    - Program will not execute if ./incoming/ directory does not contain any .csv.gz archives.                 
    - Supports exit codes to indicate whether the program terminated successfully or prematurely.              
    - Supports robust logging including log-levels.                                                            
    - Supports the ability to view log file while executing or to email the log file using an interactive CLI.  
    - If an email is requested, an additional log file is generated which displays the directory structures.   
    - Progress of the application is indicated to the user by incrementing dots as files are migrated.         
    - Has basic error handling.                                                                                

### How To Use:
  1) Clone the application: $git clone https://github.com/zimmertr/CSV-Dataset-Migrator.git  
  2) Make the application executable: $chmod +x migrate.sh  
  3) Call the application: $./migrate.sh  
  3a) In quiet mode: $./migrate.sh 0  
  3b) With custom timeout: $./migrate.sh 15  
  3c) With an hourly cron task: 0 * * * * /home/admin/migrate.sh 0  

### Dependencies
The application relies on mutt for sending emails. If mutt is not installed, email functionality will not work but the program will still function as expected. Mutt can be found within most default package manager repositories: http://www.mutt.org/download.html


---

**WARNING: The script must remain in the same directory as ./data/ and ./incoming/.**

### Screenshots

**Showcasing the Application**

![Alt text](https://raw.githubusercontent.com/zimmertr/CSV-Dataset-Migrator/master/screenshots/csv_dataset_migrator.png "Example Execution")

**Example Log File**

![Alt text](https://raw.githubusercontent.com/zimmertr/CSV-Dataset-Migrator/master/screenshots/example_log.png "Example Log")

**Example Email**

![Alt text](https://raw.githubusercontent.com/zimmertr/CSV-Dataset-Migrator/master/screenshots/example_email.png "Example Email")


---

## Original Project Description:

### SUMMARY
As part of a deployment for a new client, you need to build a script to handle moving critical files around and feeding them into the application processes. This data is critical for the production systems and, as such, this script will be running in the production environment(s). Due to the nature of the system, it needs to be capable of being run from a crontab. 

### INPUT:
Another process is uploading new, compressed files continuously to an “/incoming” location. The files have the format “DATA_YYYMMDD_hhmm.csv.gz”.

### OUTPUT: 
The script needs to decompress the files, move them to “/data” and delete the original file.

### CONSIDERATIONS:
The scripting of the task as detailed is relatively straight forward, so in addition to generation of a functionally correct script, please detail out a list of considerations that you’d add to the design of this and script them as appropriate. For example: how to handle failure scenarios and push them to an alerting system, etc.
