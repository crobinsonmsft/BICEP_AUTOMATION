# BICEP_AUTOMATION

A variety of different bicep scripts to assist with automating Azure

//=============//

## Execution

You can target your deployment to a resource group, subscription, management group, or tenant level. Depending on the scope of the deployment, you use different commands.
1. First, set your subscription:
   - 
   ```
   az account set --subscription <subscription name or id>
   ```
	- To see all subscriptions, type 
    ```az account list
    ```
	- To see your current subscription, type 
    
    ```az account show
    ```
				
2. Run your bicep template against a resource group (to deploy a vnet for example):
   - Create a Resource Group from Command Line (East US region assumed but can be changed)
   ```
	 az group create --name [YOUR-RESOURCE-GROUP-NAME-MINUS-SURROUNDING-BRACKETS] --location "eastus"
     ```
				1) Use az account list-locations to see acceptable locations for current subscription
			ii. To deploy against a parameter file:
				1) az group create --name [YOUR-RESOURCE-GROUP-NAME-MINUS-SURROUNDING-BRACKETS] --location "eastus" --parameters .\parameterfilename.json
				
		
			i. Run bicep file against resource group
				1) az deployment group create --resource-group [resource_group_name] --template-file .\[some_bicep_file]
		c. To run it against a subscription (to deploy a landing zone for example) do the following:
			i. Run the bicep file against your preferred subscription
				1) az deployment sub create --name testdeployment --location eastus --template-file .\Main.bicep
				2) Use az account list-locations to see acceptable locations for current subscription
				3) az deployment sub create --name testdeployment --location eastus --template-file .\Main.bicep --parameters .\parameterfilename.json



## Cleanup 
### Delete a Resource Group

```
az group delete -n [someresourcegroupname]
```


