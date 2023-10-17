param parLocation string
param parNsgId string
param parStorageId string
param parWorkspaceResourceId string
param parNetworkWatcherName string
param parFlowlogName string 

resource resFlowlogBastionNsg 'Microsoft.Network/networkWatchers/flowLogs@2023-05-01' = {
  name: '${parNetworkWatcherName}/${parFlowlogName}'
  location: parLocation
  properties: {
    targetResourceId: parNsgId
    storageId: parStorageId
    enabled: true
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceRegion: parLocation
        workspaceResourceId: parWorkspaceResourceId
        trafficAnalyticsInterval: 10
      }
    }
    retentionPolicy: {
      days: 30
      enabled: true
    }
  }
}
