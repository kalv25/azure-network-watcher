param parLocation string
param parPrefix string
param parWorkloadName string
param parVnetAddressPrefix string

var varVirtualNetworkName = '${parPrefix}-${parWorkloadName}-vnet'
resource resNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${varVirtualNetworkName}-nsg'
  location: parLocation
  properties: {
    securityRules: [
      {
        name: 'DenyAllInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'DenyAllOutbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'allow-outbound-http-to-169.254.169.254'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '10.10.0.128/26'
          destinationAddressPrefix: '169.254.169.254'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
        }
      }      
      {
        name: 'allow-outbound-to-168.63.129.16-port-8037'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '8037'
          sourceAddressPrefix: '10.10.0.128/26'
          destinationAddressPrefix: '168.63.129.16'
          access: 'Allow'
          priority: 250
          direction: 'Outbound'
        }
      }      
      {
        name: 'allow-outboud-to-storage-port-443'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.10.0.128/26'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }      
    ]
  }
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
