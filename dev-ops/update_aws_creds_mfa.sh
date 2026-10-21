#!/usr/bin/env bash
# Description: If you have MFA enabled in AWS on your IAM user you need to use the "aws sts get-session-token" command in order to retrieve a token to use the AWS CLI.
# Then one has to update their ~/.aws/credentials file to save the token and suffix every subsequent command with --profile mfa. (using "mfa" as an example profile)
# This script save your IAM deets (which you can save to the file manually) then the script prompts for your MFA token and once entered it will update your ~/.aws/credentials flie - saving a copy of the original.


# Globals
IAM_ID="123123123"
AWS_USER="bobby-valenzuela"

# ==== MAIN PROGRAM START =====
#

read -p "Enter your MFA code: " MFA_CODE
mfa_creds=$(aws sts get-session-token --serial-number arn:aws:iam::${IAM_ID}:mfa/${AWS_USER}-authenticatorapp --token-code ${MFA_CODE})

echo "Got it, updating ~/.aws/credentials file..."
echo "JSON: ${mfa_creds}"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing..."
    sudo apt update
    sudo apt install -y jq
fi

AWS_CREDS_FILE=~/.aws/credentials

if [[ -f ${AWS_CREDS_FILE} ]]; then

  # This should create a backup of og file and delete the '[mfa]'' portion of the new file
  sed -i.bak '/\[mfa\]/,/^$/d' ${AWS_CREDS_FILE}

  access_key=$(printf "$mfa_creds" | jq '.Credentials.AccessKeyId' 2> /dev/null)
  secret_key=$(printf "$mfa_creds" | jq '.Credentials.SecretAccessKey' 2> /dev/null)
  token=$(printf "$mfa_creds" | jq '.Credentials.SessionToken')

  echo -e "Credentials: \n\tAccessKey: ${access_key}\n\tSecret: ${secret_key}\n\tToken: ${token}"

  printf "\n[mfa]\nregion = us-east-1\noutput = json\naws_access_key_id = ${access_key//\"/}\naws_secret_access_key = ${secret_key//\"/}\naws_session_token = ${token//\"/}\n" >> ${AWS_CREDS_FILE}

  echo "$AWS_CREDS_FILE has been updated!"

else
  echo "[!] File missing, exiting!"
fi
