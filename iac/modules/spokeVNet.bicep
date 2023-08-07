param location string
param prefix string
param workloadName string
param vnetAddressPrefix string

var virtualNetworkName = '${prefix}-${workloadName}-vnet'
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${virtualNetworkName}-nsg'
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetAddressPrefix}'
      ]
    }
    subnets: [
      {
        name: 'workload-snet'
        properties: {        
          addressPrefix: vnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ] 
    enableDdosProtection: false
    enableVmProtection: false
  }
}

output name string = vnet.name
output id string = vnet.id
