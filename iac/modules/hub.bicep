param parLocation string
param parPrefix string
param parVnetAddressPrefix string
param parBastionSubnetAddressPrefix string
param parWorkloadSubnetAddressPrefix string
@description('Azure Storage Account Name')

resource resBastionNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${varVirtualNetworkName}-bastion-nsg'
  location: parLocation
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

var varVirtualNetworkName = '${parPrefix}-hub-vnet'
resource resWorkloadNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${varVirtualNetworkName}-workload-nsg'
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
        name: 'AzureBastionSubnet'
        properties: {        
          addressPrefix: parBastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: resBastionNsg.id
          }
        }
      }
      {
        name: 'workload-snet'
        properties: {        
          addressPrefix: parWorkloadSubnetAddressPrefix
          networkSecurityGroup: {
            id: resWorkloadNsg.id
          }
        }
      }      
    ] 
    enableDdosProtection: false
    enableVmProtection: false
  }
}

var varBastionHostName = '${parPrefix}-bas'
var varBastionPublicIpAddressName = '${varBastionHostName}-pip'

resource resBastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: varBastionPublicIpAddressName
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource resBastionHost 'Microsoft.Network/bastionHosts@2023-04-01' = {
  name: varBastionHostName
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${resVnet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: resBastionPublicIpAddress.id
          }
        }
      }
    ]
  }
}


resource resLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${parPrefix}-${uniqueString(resourceGroup().id)}-law'
  location: parLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

output outVnetName string = resVnet.name
output outVnetId string = resVnet.id
output outWorkloadSubnetId string = '${resVnet.id}/subnets/workload-snet'
output outBastionNsgId string = resBastionNsg.id
output outWorkloadNsgId string = resWorkloadNsg.id
output outLogAnalyticsWorkspaceId string = resLogAnalyticsWorkspace.id
