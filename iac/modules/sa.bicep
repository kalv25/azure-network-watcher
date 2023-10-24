param parLocation string
param parStorageAccountName string

resource resStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: parStorageAccountName
  location: parLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'      
    }
    accessTier: 'Hot'
  }
}


output outId string = resStorageAccount.id
