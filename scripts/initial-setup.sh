#!/bin/bash

# Variables
location="westeurope"
resourceGroup="aca-rg-02"
appName="aca-gh-actions-022"

# Get the subscription ID
subscriptionId=$(az account show --query id -o tsv)

#
# Create/Get a resource group.
#
rg_query=$(az group list --query "[?name=='$resourceGroup']")
if [ "$rg_query" == "[]" ]; then
    echo -e "\nCreating Resource group '$resourceGroup'"
    az group create --name ${resourceGroup} --location ${location}
else
    echo "Resource group $resourceGroup already exists."
fi

#
# Create Azure Service Principal
#
sp_query=$(az ad sp list --filter "displayname eq '$appName'")
if [ "$sp_query" == "[]" ]; then
    echo -e "\nCreating Service principal '$appName'"
    #az ad sp create-for-rbac --name $appName --role contributor --scopes /subscriptions/${subscriptionId}/resourceGroups/${resourceGroup} --json-auth > auth.json
    az ad sp create-for-rbac --name $appName --role owner --scopes /subscriptions/${subscriptionId}/resourceGroups/${resourceGroup} --json-auth > auth.json
else
    echo "Service principal $appName already exists."
fi

