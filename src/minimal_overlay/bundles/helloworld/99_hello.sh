#!/bin/sh

set -e

echo -e '##########################--------------___________________________ \e[34mWanpulse Imaging Tool\e[0m ___________________________--------------##########################'

#backup files name
fileName='-back.img.tar.gz'

#size of each packet captured
bs='50M'

#number of packet to capture
count=153

#ftp server address
ftpServer='192.168.2.159'

#ftp server port
ftpServerPort='21'

#ftp user
ftpUser='alex'

#ftp password
ftpPwd='alex123456'

#disk to backup
ddToBackup='/dev/sda'

#partition type
partitionType='ntfs'



# ask user for mode to execute
read -p 'Please select Backup (B) or Restore (R) image:' mode

if [ mode = "B" ]
then

	echo "Configuration of disk backup:"
	echo 'Backup files name:' $fileName
	echo 'Block size:' $bs
	echo 'Number of block to capture:' $count
	echo 'FTP server address:' $ftpServer
	echo 'FTP server port:' $ftpServerPort
	echo 'FTP server user:' $ftpUser
	echo 'FTP server password:' $ftpPwd
	echo 'Disk to backup:' $ddToBackup
	echo 'Partition type:' $partitionType	
	
	cpt=0

	while [ $cpt -lt $count ]
	do
		#catpure block of block size predefined
		dd if=$ddToBackup bs=$bs count=1 skip=$cpt of=$cpt$fileName
		
		#send block to ftp server
		ftpput -v -u $ftpUser -p $ftpPwd $ftpServer:$ftpServerPort $cpt$fileName
		
		#delete block
		rm $cpt$fileName
		
		#increment cpt
		let 'cpt=cpt+1'
		
		#calcultate % to finished
		let 'percent=cpt*100/count'
		
		echo $percent'%to finished'
	done

	echo -e '\e[32mBackup Finished !\e[0m'
else
	echo "Configuration of restore image:"
	echo 'Backup files name:' $fileName
	echo 'Block size:' $bs
	echo 'Number of block to restore:' $count
	echo 'FTP server address:' $ftpServer
	echo 'FTP server port:' $ftpServerPort
	echo 'FTP server user:' $ftpUser
	echo 'FTP server password:' $ftpPwd
	echo 'Target disk to restore:' $ddToBackup
	echo 'Partition type:' $partitionType
	
	cpt=0

	while [ $cpt -lt $count ]
	do
		#download block from ftp
		ftpget -v -u $ftpUser -p $ftpPwd $ftpServer:$ftpServerPort $cpt$fileName
	
		#catpure block of block size predefined
		dd if=$cpt$fileName bs=$bs count=1 seek=$cpt of=$ddToBackup
		
		#delete block
		rm $cpt$fileName
		
		#increment cpt
		let 'cpt=cpt+1'
		
		#calcultate % to finished
		let 'percent=cpt*100/count'
		
		echo $percent'%to finished'
	done
	
	echo -e '\e[32mRestore Finished !\e[0m'
fi