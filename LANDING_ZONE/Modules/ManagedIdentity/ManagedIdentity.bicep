
param userAssignedIdentityName string
param location string
param tags object

// create user assigned managed identity
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: tags
}

output uami_id string = uami.id
