# BICEP AUTOMATION

A variety of different bicep scripts to assist with automating Azure


## Execution

You can target your deployment to a resource group, subscription, management group, or tenant level. Depending on the scope of the deployment, you use different commands.
### First, set your subscription:
   
```
az account set --subscription <subscription name or id>
```

### To see your current subscription, type 
```
az account show
```

### To see all subscriptions, type 
```
az account list
```

				
## Run your bicep template against a resource group:
### First, create a Resource Group from Command Line (East US region assumed but can be changed)

```
az group create --name [YOUR-RESOURCE-GROUP-NAME] --location "eastus"
```

### To see acceptable locations for current subscription

```
az account list-locations 
```
### To deploy against a parameter file:

```
az group create --name [YOUR-RESOURCE-GROUP-NAME-MINUS-SURROUNDING-BRACKETS] --location "eastus" --parameters .\parameterfilename.json
```


## Run bicep file against resource group
```
az deployment group create --resource-group [resource_group_name] --template-file .\[some_bicep_file]
```

## To run it against a subscription (to deploy a landing zone for example) do the following:

```
az deployment sub create --name [SOME DEPLOYMENT NAME] --location eastus --template-file .\Main.bicep
```

### See acceptable locations for current subscription

```
az account list-locations  
```

### Run against subscription using parameter file
```
az deployment sub create --name [SOME DEPLOYMENT NAME] --location eastus --template-file .\Main.bicep --parameters .\parameterfilename.json
```



## Cleanup 
### Delete a Resource Group

```
az group delete -n [someresourcegroupname] -y
```


