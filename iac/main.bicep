targetScope = 'subscription'

@description('Resources location')
param location string = 'westeurope'

@description('Two first segments of Virtual Network address prefix. For example, if the address prefix is 10.10.0.0/22, then the value of this parameter should be 10.10')
param vnetAddressPrefix string = '10.10'

@description('Lab resources prefix.')
param prefix string = 'iac-ws6'

@description('Test VM admin username. Default is iac-admin.')
param testVMAdminUsername string = 'iac-admin'

@description('Test VM admin user password')
@secure()
param testVMAdminPassword string

var resourceGroupName = '${prefix}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Department: 'IaC'
    Owner: 'IaC Team'
  }
}

module hubVNet 'modules/hubVnet.bicep' = {
  name: 'DeployHubVNet'
  scope: rg  
  params: {
    location: location
    prefix: prefix
    vnetAddressPrefix: vnetAddressPrefix
  }
}

module spoke1VNet 'modules/spokeVNet.bicep' = {
  name: 'DeploySpoke1VNet'
  scope: rg
  params: {
    location: location
    prefix: prefix
    workloadName: 'wl1'
    vnetAddressPrefix: '${vnetAddressPrefix}.1.0/25'  // 10.10.1.0/25
  }
}

module spoke2VNet 'modules/spokeVNet.bicep' = {
  name: 'DeploySpoke2VNet'
  scope: rg
  params: {
    location: location
    prefix: prefix
    workloadName: 'wl2'
    vnetAddressPrefix: '${vnetAddressPrefix}.2.0/25'  // 10.10.2.0/25
  }
}

module hubToWL1Peering 'modules/vnetPeering.bicep' = {
  name: 'HubToWL1SpokePeering'
  scope: rg
  params: {
    fromVNetName: hubVNet.outputs.name
    toVNetName: spoke1VNet.outputs.name
  }
}

module WL1TohUBPeering 'modules/vnetPeering.bicep' = {
  name: 'WL1SpokeTohUBPeering'
  scope: rg
  params: {
    fromVNetName: spoke1VNet.outputs.name
    toVNetName: hubVNet.outputs.name
  }
}

module hubToWL2Peering 'modules/vnetPeering.bicep' = {
  name: 'HubToWL2SpokePeering'
  scope: rg
  params: {
    fromVNetName: hubVNet.outputs.name
    toVNetName: spoke2VNet.outputs.name
  }
}

module WL2TohUBPeering 'modules/vnetPeering.bicep' = {
  name: 'WL2SpokeTohUBPeering'
  scope: rg
  params: {
    fromVNetName: spoke2VNet.outputs.name
    toVNetName: hubVNet.outputs.name
  }
}

module bastion 'modules/bastion.bicep' = {
  name: 'DeployBastion'
  scope: rg
  params: {
    location: location
    prefix: prefix
    bastionSubnetId: '${hubVNet.outputs.id}/subnets/AzureBastionSubnet'
  }
}

// module testVM 'modules/testVM.bicep' = {
//   scope: rg
//   name: 'Deploy VM1'
//   params: {
//     location: location
//     vmName: 'testVM'
//     vmSubnetId: '${vnet.outputs.id}/subnets/testvm-snet'
//     adminUsername: testVMAdminUsername
//     adminPassword: testVMAdminPassword
//   }
// }
