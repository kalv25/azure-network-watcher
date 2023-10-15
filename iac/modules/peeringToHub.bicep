param parFromVNetName string
param parFromVnetId string
param parToVNetName string

resource resHubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: parToVNetName  
}

resource resPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${parToVNetName}-${parFromVNetName}'
  parent: resHubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: parFromVnetId
    }
  }
}
