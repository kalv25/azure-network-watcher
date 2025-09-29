param parLocation string
param parNetworkWatcherName string = 'NetworkWatcher_${parLocation}'

resource resNetworkWatcher 'Microsoft.Network/networkWatchers@2024-07-01' = {
  name: parNetworkWatcherName
  location: parLocation
  properties: {}
}
