param parLocation string
param parVmName string
param parVmSubnetId string
param parVmSize string = 'Standard_D2s_v3'
param parVmPublisher string = 'MicrosoftWindowsServer'
param parVmOffer string = 'WindowsServer'
param parVmSku string = '2022-Datacenter'
param parVmVersion string = 'latest'
param parVmStorageAccountType string = 'Premium_LRS'
param parAdminUsername string
@secure()
param parAdminPassword string


resource resNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
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

resource resVm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
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
        publisher: parVmPublisher
        offer: parVmOffer
        sku: parVmSku
        version: parVmVersion
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
  
  // Install the Azure Monitor Agent
  resource resAma 'extensions@2021-11-01' = {
    name: 'AzureMonitorWindowsAgent'
    location: parLocation
    properties: {
      publisher: 'Microsoft.Azure.Monitor'
      type: 'AzureMonitorWindowsAgent'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      enableAutomaticUpgrade: true
    }
  }
}

resource vmFEIISEnabled 'Microsoft.Compute/virtualMachines/runCommands@2023-07-01' = {
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
