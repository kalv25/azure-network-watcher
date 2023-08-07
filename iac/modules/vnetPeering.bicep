param fromVNetName string
param toVNetName string

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: fromVNetName
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${fromVNetName}-to-${toVNetName}'
  parent: hubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', toVNetName)
    }
  }
}
