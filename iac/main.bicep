targetScope = 'subscription'

@description('Lab resources prefix.')
param parPrefix string = 'iac-ws6'

param parHubLocation string = 'norwayeast'
param parSpoke1Location string = 'westeurope'
param parSpoke2Location string = 'northeurope'

@description('Test VM admin username. Default is iac-admin.')
param parVMAdminUsername string = 'iac-admin'

@description('Test VM admin user password')
@secure()
param parVMAdminPassword string

var varTags = {
  Department: 'IaC'
  Owner: 'IaC Team'
}

var varHubResourceGroupName = '${parPrefix}-hub-rg'
resource resHubResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: varHubResourceGroupName
  location: parHubLocation
  tags: varTags
}

module modHub 'modules/hub.bicep' = {
  scope: resHubResourceGroup
  name: 'deploy-hub'
  params: {
    parLocation: parHubLocation
    parPrefix: parPrefix
    parVnetAddressPrefix: '10.10.0.0/25'
    parBastionSubnetAddressPrefix: '10.10.0.0/26'
    parWorkloadSubnetAddressPrefix: '10.10.0.64/26'
  }
}

var varUniqueString = uniqueString(subscription().id)
module modNSGFlowLogsNorwayEast 'modules/sa.bicep' = {
  name: 'deploy-nsg-flow-logs-sa-for-norwayeast'
  scope: resHubResourceGroup
  params: {
    parLocation: parHubLocation
    parStorageAccountName: take('norwayeast${varUniqueString}', 24)
  }
}
module modNSGFlowLogsWestEurope 'modules/sa.bicep' = {
  name: 'deploy-nsg-flow-logs-sa-for-westeurope'
  scope: resHubResourceGroup
  params: {
    parLocation: parSpoke1Location
    parStorageAccountName: take('westeurope${varUniqueString}', 24)
  }
}

module modNSGFlowLogsNorthEurope 'modules/sa.bicep' = {
  name: 'deploy-nsg-flow-logs-sa-for-northeurope'
  scope: resHubResourceGroup
  params: {
    parLocation: parSpoke2Location
    parStorageAccountName: take('northeurope${varUniqueString}', 24)
  }
}

param parNetworkWatcherResourceGroupName string = 'NetworkWatcherRG'
resource resNetworkWatcherResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: parNetworkWatcherResourceGroupName
  location: parHubLocation
  tags: varTags
}

var varNetworkWatcherName = 'NetworkWatcher_${parHubLocation}'
module modNetwrokWatcher 'modules/networkWatcher.bicep' = {
  scope: resNetworkWatcherResourceGroup
  name: 'deploy-networkwatcher-${parHubLocation}'
  params: {
    parLocation: parHubLocation
    parNetworkWatcherName: varNetworkWatcherName
  }
}

module modNsgFlowLogBastion 'modules/flowlogs.bicep' = {
  scope: resNetworkWatcherResourceGroup
  name: 'deploy-nsg-flowlog-bastion'
  params: {
    parFlowlogName: '${parPrefix}-bastion-nsg-flowlog'
    parLocation: parHubLocation
    parNetworkWatcherName: varNetworkWatcherName
    parNsgId: modHub.outputs.outBastionNsgId
    parStorageId: modNSGFlowLogsNorwayEast.outputs.outId
    parWorkspaceResourceId: modHub.outputs.outLogAnalyticsWorkspaceId
  }
}

module modNsgFlowLogHubWorkload 'modules/flowlogs.bicep' = {
  scope: resNetworkWatcherResourceGroup
  name: 'deploy-nsg-flowlog-hub-workload'
  params: {
    parFlowlogName: '${parPrefix}-hub-workload-nsg-flowlog'
    parLocation: parHubLocation
    parNetworkWatcherName: 'NetworkWatcher_${parHubLocation}'
    parNsgId: modHub.outputs.outWorkloadNsgId
    parStorageId: modNSGFlowLogsNorwayEast.outputs.outId
    parWorkspaceResourceId: modHub.outputs.outLogAnalyticsWorkspaceId
  }
}

var varSpoke1WorkloadName = 'spoke1'
var varSpoke1ResourceGroupName = '${parPrefix}-${varSpoke1WorkloadName}-rg'
resource resSpoke1ResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: varSpoke1ResourceGroupName
  location: parSpoke1Location
  tags: varTags
}

module modSpoke1 'modules/spoke1.bicep' = {
  scope: resSpoke1ResourceGroup
  name: 'deploy-${varSpoke1WorkloadName}'
  params: {
    parLocation: parSpoke1Location
    parPrefix: parPrefix
    parVnetAddressPrefix: '10.10.0.128/26'
    parWorkloadName: varSpoke1WorkloadName
  }
}

var varSpoke2WorkloadName = 'spoke2'
var varSpoke2ResourceGroupName = '${parPrefix}-${varSpoke2WorkloadName}-rg'
resource resSpoke2ResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: varSpoke2ResourceGroupName
  location: parSpoke2Location
  tags: varTags
}
module modSpoke2 'modules/spoke2.bicep' = {
  scope: resSpoke2ResourceGroup
  name: 'deploy-${varSpoke2WorkloadName}'
  params: {
    parLocation: parSpoke2Location
    parPrefix: parPrefix
    parVnetAddressPrefix: '10.10.0.192/26'
    parWorkloadName: varSpoke2WorkloadName
  }
}

module modLinkSpoke1ToHub 'modules/peeringToHub.bicep' = {
  scope: resHubResourceGroup
  name: 'link-spoke1-to-hub'
  params: {
    parToVNetName: modHub.outputs.outVnetName
    parFromVNetName: modSpoke1.outputs.outVnetName
    parFromVnetId: modSpoke1.outputs.outVnetId
  }
}
module modHubToSpoke1 'modules/peeringToHub.bicep' = {
  scope: resSpoke1ResourceGroup
  name: 'link-hub-to-spoke1'
  params: {
    parToVNetName: modSpoke1.outputs.outVnetName
    parFromVNetName: modHub.outputs.outVnetName
    parFromVnetId: modHub.outputs.outVnetId
  }
}

module modLinkSpoke2ToHub 'modules/peeringToHub.bicep' = {
  scope: resHubResourceGroup
  name: 'link-spoke2-to-hub'
  params: {
    parToVNetName: modHub.outputs.outVnetName
    parFromVNetName: modSpoke2.outputs.outVnetName
    parFromVnetId: modSpoke2.outputs.outVnetId
  }
}
module modHubToSpoke2 'modules/peeringToHub.bicep' = {
  scope: resSpoke2ResourceGroup
  name: 'link-hub-to-spoke2'
  params: {
    parToVNetName: modSpoke2.outputs.outVnetName
    parFromVNetName: modHub.outputs.outVnetName
    parFromVnetId: modHub.outputs.outVnetId
  }
}

module modSpoke1Vm 'modules/testVM.bicep' = {
  scope: resSpoke1ResourceGroup
  name: 'deploy-spoke1-testvm'
  params: {    
    parLocation: parSpoke1Location
    parVmName: 'spoke1Vm'
    parVmSubnetId: modSpoke1.outputs.outWorkloadSubnetId
    parAdminUsername: parVMAdminUsername
    parAdminPassword: parVMAdminPassword
  }
}

module modSpoke2Vm 'modules/testVM.bicep' = {
  scope: resSpoke2ResourceGroup
  name: 'deploy-spoke2-testvm'
  params: {    
    parLocation: parSpoke2Location
    parVmName: 'spoke2Vm'
    parVmSubnetId: modSpoke2.outputs.outWorkloadSubnetId
    parAdminUsername: parVMAdminUsername
    parAdminPassword: parVMAdminPassword
  }
}

module modHubVm 'modules/testVM.bicep' = {
  scope: resHubResourceGroup
  name: 'deploy-hub-testvm'
  params: {    
    parLocation: parHubLocation
    parVmName: 'hubVm'
    parVmSubnetId: modHub.outputs.outWorkloadSubnetId
    parAdminUsername: parVMAdminUsername
    parAdminPassword: parVMAdminPassword
  }
}
