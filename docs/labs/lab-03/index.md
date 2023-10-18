# lab-03 - use IP flow verify and NSG diagnostics to troubleshoot a vm network traffic filter problem

There are three Virtual Machines deployed in our lab environment. One Linux VM that is deployed into `iac-ws6-hub-vnet` virtual network and two Windows vms deployed into `iac-ws6-spoke1-vnet` and `iac-ws6-spoke2-vnet` virtual networks correspondingly.

| VM name | Vm private IP |Vnet | IP range | Location |
|-----|------|---|----------|----------|
| hubVm | 10.10.0.68 | iac-ws6-hub-vnet | 10.10.0.0/25 | norwayeast |
| spoke1Vm | 10.10.0.132 | iac-ws6-spoke1-vnet | 10.10.0.128/26 | westeurope |
| spoke1Vm | 10.10.0.196 | iac-ws6-spoke2-vnet | 10.10.0.192/26 | northeurope |      


![00](../../assets/images/lab-03/nsg-diag-01.png)

![00](../../assets/images/lab-03/nsg-diag-02.png)

![00](../../assets/images/lab-03/nsg-spoke1-2.png)

![00](../../assets/images/lab-03/nsg-spoke1-3.png)

![00](../../assets/images/lab-03/nsg-spoke1-4.png)

![00](../../assets/images/lab-03/nsg-spoke1-5.png)