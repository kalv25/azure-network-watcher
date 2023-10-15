param parSpokeVNetName string
param parSpokeVnetId string
param parHubVNetName string

resource resHubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: parHubVNetName  
}

resource resPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${parHubVNetName}-${parSpokeVNetName}'
  parent: resHubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: parSpokeVnetId
    }
  }
}
