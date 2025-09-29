param parLocation string
param parVmName string
param parVmSubnetId string
param parVmSize string = 'Standard_D2s_v3'
@description('Specifies which OS should be deployed on VM.')
param parOsType string
param parVmStorageAccountType string = 'Standard_LRS'
param parAdminUsername string
@secure()
param parAdminPassword string

var varVmImage = {
  windows: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-Datacenter'
    version: 'latest'
  }
  linux: {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '16.04-LTS'
    version: 'latest'
  }
}

resource resNic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${parVmName}-nic'
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: parVmSubnetId
          }
        }
      }
    ]
  }
}

resource resVm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: parVmName
  location: parLocation
  properties: {
    hardwareProfile: {
      vmSize: parVmSize
    }
    osProfile: {      
      computerName: parVmName
      adminUsername: parAdminUsername
      adminPassword: parAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: varVmImage[parOsType].publisher
        offer: varVmImage[parOsType].offer
        sku: varVmImage[parOsType].sku
        version: varVmImage[parOsType].version
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: parVmStorageAccountType
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resNic.id
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource vmFEIISEnabled 'Microsoft.Compute/virtualMachines/runCommands@2024-11-01' = if (parOsType == 'windows') {
  name: 'enable-iis-at-${parVmName}'
  location: parLocation
  parent: resVm
  properties: {
    asyncExecution: false
    source: {
      script: '''
        Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value $("Hello from " + $env:computername)  
      '''
    }
  }
}

resource resScheduledShutdown 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${parVmName}'
  location: parLocation
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1600'
    }
    timeZoneId: 'W. Europe Standard Time'
    notificationSettings: {
      status: 'Disabled'
    }
    targetResourceId: resVm.id
  }  
}
