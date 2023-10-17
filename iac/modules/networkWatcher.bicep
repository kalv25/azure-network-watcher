param parLocation string
param parNetworkWatcherName string = 'NetworkWatcher_${parLocation}'

resource resNetworkWatcher 'Microsoft.Network/networkWatchers@2023-05-01' = {
  name: parNetworkWatcherName
  location: parLocation
  properties: {}
}
