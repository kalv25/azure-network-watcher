# lab-01 - provisioning of lab resources

As always, we need to provision lab environment before we can start working on the lab tasks. 

```powershell
# Make sure that all Resource Providers are registered
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Compute
az provider register --namespace microsoft.devtestlab

```

| Vnet | IP range | Location |
|------|----------|----------|
| iac-ws6-hub-vnet | 10.10.0.0/25 | norwayeast |
| iac-ws6-spoke1-vnet | 10.10.0.128/26 | westeurope |
| iac-ws6-spoke2-vnet | 10.10.0.192/26 | northeurope |      


