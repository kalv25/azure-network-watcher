# lab-08 - cleaning up resources

This is the most important part of the workshop. We need to clean up all resources that we provisioned during the workshop to avoid unexpected bills.

## Task #1 - delete lab infrastructure

Remove all resources that were created during the workshop by running the following commands:

```powershell
az group delete --name iac-ws6-spoke1-rg --yes --no-wait
az group delete --name iac-ws6-spoke2-rg --yes --no-wait
az group delete --name iac-ws6-hub-rg --yes --no-wait

# if you managed to create the network watcher with az cli, run this command as well
az group delete --name iac-ws6-networkwatcher-rg --yes --no-wait
```