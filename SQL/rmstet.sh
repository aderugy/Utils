#!/usr/bin/env bash
#
# Rugy MySQL Table Export Tool
#
# Author: aderugy
# First bash script
#
#
# Description:
#
# Uploading a .sql file to a mysql database is long. Very long.
# I had to upload a database of 2 Go and only needed one table for it.
# With this script, you can import only the needed table (will maybe make it work with multiple).
#
#
# How does it work ?
#
# It first looks for the line that creates the table.
# After creating the table in the database that you have selected,
# it splits the database in chunks of 1000 lines (to keep the process alive)
# The INSERT INTO `table` statements are then scrapped and executed
# in the new database.
#
#
# Remark:
#
# The process may stay inactive for a while after processing all the files.
# This is because MySQL has to execute all the statements one by one.



echo 'Welcome to the Rugy MySQL Table Export Tool.'
echo ''
echo "Current location: $PWD"
echo 'Select the .sql file that contains the table to export.'
read path

echo ''

path="$PWD/$path"

if [ -f "$path" ]; then
	echo "Select this database ? $path (y/n)"
	read ans
	if [ $ans != "y" ] && [ $ans != "yes" ]; then 
		echo 'Aborting.'
		exit 1
	fi
fi	
echo ''

echo 'Show tables ? (y/n)'
read ans
if [ $ans == "y" ] || [ $ans == "yes" ]; then
	IFS="\\\`"
	echo ''
	echo "TABLES:"
	declare -i i=1
	for e in `grep '^CREATE TABLE' $path`; do
		if [ `expr $i % 2` == 0 ]; then
			echo "$e"
		fi
		i=`expr $i + 1`
	done
	echo ''
fi
echo ''

# Choosing the table to import
echo 'Select table to import'
read table
echo ''

# Choosing database that will host the data
echo 'Select hosting database'
read db
echo ''

# Asking for mysql username
echo 'Enter your mysql username'
read username
echo "Enter mysql password for $username"
read -s password
echo ''

splitdir="/tmp/database_exporter"
echo "Saving split database in: $splitdir"
mkdir -p $splitdir

split -l 1000 $path /tmp/database_exporter/$split_path
echo "Database split."
echo ''

declare -i filecount=0

for file in "$splitdir/$split_path"*
do
	filecount=`expr $filecount + 1`
done

output="$PWD/$table.sql"
touch $output

cleanup() {
  rm -rf $splitdir
  rm $output
}

# Register the cleanup function to be called when the script exits
trap cleanup EXIT


function writeToDatabase() {
	echo "$1" >> $output
}

writeToDatabase "USE $db;"
writeToDatabase "DROP TABLE IF EXISTS $table;"
writeToDatabase "$(sed -n "/^CREATE TABLE.*$table/,/;/p" $path)"

declare -i currentfile=1
for file in "$splitdir/$split_path"*
do
	if [ `expr $currentfile % 10` == 0 ] || [ $currentfile == $filecount ]; then
		echo "Processing $file ($currentfile/$filecount)"
	fi
	result=$(grep -E -e "^INSERT INTO \`$table\`" $file 2>/dev/null)
	writeToDatabase "$result"
	currentfile=`expr $currentfile + 1`
done

echo ''
echo "Writing to database...."
mysql --user=$username --password=$password -D $db < $output

echo "Process completed."
