#!/bin/sh

set -e

echo -e '##########################--------------___________________________ \e[34mWanpulse Imaging Tool\e[0m ___________________________--------------##########################'


#extract informations from config file 
#Mount hidden partition

#Read config file
# Read the 'FORCE_32_BIT_BINARIES' property from '.config'
#FORCE_32_BIT_BINARIES="$(grep -i ^FORCE_32_BIT_BINARIES $SRC_DIR/.config | cut -f2 -d'=')"

#backup folder on FTP server
BACKUP_PATH='chip-pc'

#backup files name
BACKUP_FILENAME='-back.img.tar.gz'

#size of each packet captured
BLOCK_SIZE='50M'

#number of packet to capture
TOTAL_PACKETS_NUMBER=153

#ftp server address
FTP_SERVER='192.168.2.159'

#ftp server port
FTP_SERVER_PORT='21'

#ftp user
FTP_USERNAME='alex'

#ftp password
FTP_PASSWORD='alex123456'

#disk to backup
DISK_TARGET='/dev/sda'

#partition type
PARTITION_TYPE='ntfs'



# ask user for mode to execute
read -p 'Please select Backup (B) or Restore (R) image:' mode

if [ mode = "B" ]
then

	echo "Configuration of disk backup:"
	echo 'Backup files name:' $BACKUP_FILENAME
	echo 'Block size:' $BLOCK_SIZE
	echo 'Number of block to capture:' $TOTAL_PACKETS_NUMBER
	echo 'FTP server address:' $FTP_SERVER
	echo 'FTP server port:' $FTP_SERVER_PORT
	echo 'FTP server user:' $FTP_USERNAME
	echo 'FTP server password:' $FTP_PASSWORD
	echo 'Disk to backup:' $DISK_TARGET
	echo 'Partition type:' $PARTITION_TYPE	
	
	CPT_INCREMENT=0

	while [ $CPT_INCREMENT -lt $TOTAL_PACKETS_NUMBER ]
	do
		#catpure block of block size predefined
		dd if=$DISK_TARGET bs=$BLOCK_SIZE count=1 skip=$CPT_INCREMENT of=$CPT_INCREMENT$BACKUP_FILENAME
		
		#send block to ftp server
		ftpput -v -u $FTP_USERNAME -p $FTP_PASSWORD $FTP_SERVER:$FTP_SERVER_PORT $BACKUP_PATH/$CPT_INCREMENT$BACKUP_FILENAME
		
		#delete block
		rm $CPT_INCREMENT$BACKUP_FILENAME
		
		#increment cpt
		let 'CPT_INCREMENT=CPT_INCREMENT+1'
		
		#calcultate % to finished
		PROGRESS_PERCENT=$(($CPT_INCREMENT*100/$TOTAL_PACKETS_NUMBER))
		
		echo $PROGRESS_PERCENT'%to finished'
	done

	echo -e '\e[32mBackup Finished !\e[0m'
else
	echo "Configuration of restore image:"
	echo 'Backup files name:' $BACKUP_FILENAME
	echo 'Block size:' $BLOCK_SIZE
	echo 'Number of block to restore:' $TOTAL_PACKETS_NUMBER
	echo 'FTP server address:' $FTP_SERVER
	echo 'FTP server port:' $FTP_SERVER_PORT
	echo 'FTP server user:' $FTP_USERNAME
	echo 'FTP server password:' $FTP_PASSWORD
	echo 'Target disk to restore:' $DISK_TARGET
	echo 'Partition type:' $PARTITION_TYPE
	
	CPT_INCREMENT=0

	while [ $CPT_INCREMENT -lt $TOTAL_PACKETS_NUMBER ]
	do
		#download block from ftp
		ftpget -v -u $FTP_USERNAME -p $FTP_PASSWORD $FTP_SERVER:$FTP_SERVER_PORT $BACKUP_PATH/$CPT_INCREMENT$BACKUP_FILENAME
	
		#catpure block of block size predefined
		dd if=$CPT_INCREMENT$BACKUP_FILENAME bs=$BLOCK_SIZE count=1 seek=$CPT_INCREMENT of=$DISK_TARGET
		
		#delete block
		rm $CPT_INCREMENT$BACKUP_FILENAME
		
		#increment cpt
		let 'CPT_INCREMENT=CPT_INCREMENT+1'
		
		#calcultate % to finished
		PROGRESS_PERCENT=$(($CPT_INCREMENT*100/$TOTAL_PACKETS_NUMBER))
		
		echo $PROGRESS_PERCENT'%to finished'
	done
	
	echo -e '\e[32mRestore Finished !\e[0m'
fi