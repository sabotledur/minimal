#!/bin/sh

set -e

echo "mode auto ? (Y/n)"
read mode

for script in $(ls | grep '^[0-9]*_.*.sh'); do
  echo "Executing script '$script'."
  ./$script
  
  if [ $mode = "n" ] ; then
    echo "end of script '$script'. press enter to continue"
	read a
  fi
done
