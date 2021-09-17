#! /bin/bash 
# remove above line in case you intend to use this in windows

#mendatory
KEY_VAULT=$1
#optional ( need to set, when user is working in multi-tenant mode)
TENANT_ID=$2


function fetch_secret_from_keyvault() {
    local SECRET_NAME=$1
    
    #fetch the secrets value from azure keyvault by secret key name
    az keyvault secret show --vault-name "${KEY_VAULT}" --name "${SECRET_NAME}" --query "value" | sed -e 's/^"//' -e 's/"$//'
} 


if [ -n "$2" ]; then
  #if tenant id is provided 
  az login --tenant $2
else
  # make sure the tenant is defaulted to the one in which keyvault resides
  az login
fi


#get the all the secrets available, parse it and store them in an array
declare -a arr=(`az keyvault secret list --vault-name ${KEY_VAULT} | jq -c '.[].name | @sh'| sed 's/\\[tn]//g; s/"\(.*\)"/\1/' |tr -d \'\"`)

#output file in which the key value will be added
file_name=".env"

#check if the file already exists
if [ -f "${file_name}" ] ; then
    #remove file
    rm -f "${file_name}"
fi

#loop though the array to get the secret value corresponding to secret key name
for i in "${arr[@]}"
do 
    # get the secret value
    value=$(fetch_secret_from_keyvault  "${i}")
    # append the key and value in the file
    echo "$i=$value" >> ${file_name}
done
