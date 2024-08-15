#!/bin/bash
# Purpose: Automated user creation in the AWS
# How to: ./aws-iam-create-user.sh <entry file format .csv>
# Entry file column name: user, group, password


INPUT=$1
OLDIFS=$IFS
IFS=',;'

# Check if the input file exists
[ ! -f "$INPUT" ] && { echo "$INPUT file not found"; exit 99; }

# Check if dos2unix is installed
command -v dos2unix >/dev/null || { echo "dos2unix tool not found. Please, install dos2unix tools before running the script."; exit 1; }

# Convert the input file to Unix format
dos2unix $INPUT

# Read the input file line by line
while read -r user group password || [ -n "$user" ]
do
    # Skip the header row
    if [ "$user" != "user" ]; then
        # Create the user in AWS IAM
        aws iam create-user --user-name "$user"
        
        # Create a login profile for the user with a password
        aws iam create-login-profile --password-reset-required --user-name "$user" --password "$password"
        
        # Add the user to the specified group
        aws iam add-user-to-group --group-name "$group" --user-name "$user"
    fi
done < "$INPUT"

#thanks to thecloudbootcamp for this script