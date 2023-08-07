param location string
param prefix string
param vnetAddressPrefix string

var virtualNetworkName = '${prefix}-hub-vnet'
resource workloadNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${virtualNetworkName}-workload-nsg'
  location: location
}

resource bastionNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${virtualNetworkName}-bastion-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          protocol: 'TCP'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          protocol: 'TCP'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '5701'
            '8080'
          ]
          direction: 'Inbound'
          priority: 120
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 4095
          protocol: 'TCP'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 4096
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSshRDPOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          direction: 'Outbound'
          priority: 100
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
      name: 'AllowAzureCloudOutbound'
      properties: {
        access: 'Allow'
        destinationAddressPrefix: 'AzureCloud'
        destinationPortRange: '443'
        direction: 'Outbound'
        priority: 110
        protocol: 'TCP'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '5701'
            '8080'
          ]
          direction: 'Outbound'
          priority: 120
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowHttpOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '80'
          direction: 'Outbound'
          priority: 130
          protocol: 'TCP'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 140
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }        
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetAddressPrefix}.0.0/25'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {        
          addressPrefix: '${vnetAddressPrefix}.0.0/26'
          networkSecurityGroup: {
            id: bastionNsg.id
          }
        }
      }
      {
        name: 'workload-snet'
        properties: {        
          addressPrefix: '${vnetAddressPrefix}.0.64/26'
          networkSecurityGroup: {
            id: workloadNsg.id
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
