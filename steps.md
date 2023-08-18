az login

az account set --subscription "SUBSCRIPTION_ID"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" --name="GitHub-Actions"
    appId (Azure) → client_id (Terraform).
    password (Azure) → client_secret (Terraform).
    tenant (Azure) → tenant_id (Terraform).

\az group create --name $RESOURCE_GROUP_NAME --location "West Europe"

az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY