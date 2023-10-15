param parLocation string
param parPrefix string
param parWorkloadName string
param parVnetAddressPrefix string

var varVirtualNetworkName = '${parPrefix}-${parWorkloadName}-vnet'
resource resNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${varVirtualNetworkName}-nsg'
  location: parLocation
}

resource resVnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: varVirtualNetworkName
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        parVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'workload-snet'
        properties: {        
          addressPrefix: parVnetAddressPrefix
          networkSecurityGroup: {
            id: resNsg.id
          }
        }
      }
    ] 
    enableDdosProtection: false
    enableVmProtection: false
  }
}

output outVnetName string = resVnet.name
output outVnetId string = resVnet.id
output outWorkloadSubnetId string = '${resVnet.id}/subnets/workload-snet'
