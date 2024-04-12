#!/bin/bash

# Display Help message
Help()
{
   # Display Help
   echo "Deploy Azure Resources for the Container Apps application."
   echo
   echo "Syntax: ./action-pre-build.sh [-h|r|c]"
   echo "options:"
   echo "h     Print this Help."
   echo "r     Resource group name."
   echo "c     Container registry name."
   echo
}

# Check input options
while getopts "hr:c:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      r) # Enter the resource group name
         resourceGroup=$OPTARG;;
      c) # Enter the container registry name
         acrName=$OPTARG;;
     \?) # Invalid option
         Help
         exit;;
   esac
done

# mandatory arguments
if [ ! "$resourceGroup" ]; then
  echo "arguments -r with resource group name must be provided"
  Help; exit 1
fi

if [ ! "$acrName" ]; then
  echo "arguments -c with container registry name must be provided"
  Help; exit 1
fi

#
# Create/Get a container registry
#
cr_query=$(az acr list --query "[?name=='$acrName']")
if [ "$cr_query" == "[]" ]; then
    echo -e "\nCreating container registry '$acrName'"
    az acr create -n $acrName -g $resourceGroup --sku Basic
else
    echo "Container registry $acrName already exists."
fi

#
# Make sure the service principal can pull images from ACR
#
SERVICE_PRINCIPAL_ID=$(echo ${AZURE_CREDENTIALS} | jq -r .clientId)

echo "Service principal: ${SERVICE_PRINCIPAL_ID}"

# Populate value required for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $acrName --query id --output tsv)

# Assign the desired role to the service principal. Modify the '--role' argument
# value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role acrpull
