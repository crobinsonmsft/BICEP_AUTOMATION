param location string
param rg_01_name string
param rg_02_name string
param rg_03_name string
param tags object

targetScope = 'subscription'


//Create Our Connectivity Resource Group
resource rg_01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : rg_01_name
  location: location
  tags:tags
}

resource rg_02 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : rg_02_name
  location: location
  tags:tags
}

resource rg_03 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : rg_03_name
  location: location
  tags:tags
}
