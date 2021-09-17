#! /bin/bash 
# remove above line in case you intend to use this in windows

#mendatory
KEY_VAULT=$1

#optional ( need to set, when user is working in multi-tenant mode)
TENANT_ID=$2

if [ -n "$2" ]; then
  #if tenant id is provided 
  az login --tenant $2
else
  # make sure the tenant is defaulted to the one in which keyvault resides
  az login
fi

function store_secret_to_keyvault() {
    local SECRET_KEY=$1
    local SECRET_VALUE=$2
    # store the key vault secret key and value
    # if already present then a new version will be created
    # if not present then a new secret will be created
    az keyvault secret set --vault-name "${KEY_VAULT}" --name "${SECRET_KEY}" --value "${SECRET_VALUE}"
}

#input file in which the key value will be added
file_name=".env"

#if file is not already present in the current directory
if ! [[ -f "${file_name}" ]] ; then
    # create a new one 
    # this means first execution in this condition will not store anything
    # so avoid this and add the key=value data in .env file in advance
    # format of data <key1>=<value1> ... seperated by new line
    touch $file_name
fi


#loop through input file line by line
while IFS= read -r line; do
    #split key value
    arr=(${line//=/ })
    #store into az keyvault
    store_secret_to_keyvault ${arr[0]} ${arr[1]}
done < ".env"
