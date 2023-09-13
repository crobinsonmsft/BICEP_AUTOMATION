//=======This bicep file creates a Recovery Services Vault which is required for ASR and Backup =======//

//=================Params=================//

//global params

param vaultName string
param location string
param tags object
param sku object

//Create the Recovery Services Vault
resource RecoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-01-01' = {
  name: vaultName
  location: location
  tags: tags
  sku: sku
  properties: {}
}
