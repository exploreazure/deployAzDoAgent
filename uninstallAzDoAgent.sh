#!/bin/bash

# This script has been written to uninstall the Azure DevOps Agent on a Liunx virtual machine hosted in Azure
# This uses the RunShellScript command, which requires the VM agent to be installed
# Version 1
# Written on 05/09/2022

linuxUser='azureuser'
vmName='vm-agent03'
pathToAgent="/home/$linuxUser/myagent"
keyVaultName='kvlabselfh02'
secretName='azdoAgentPAT'
azdoOrg="https://dev.azure.com/barrysharpen/"
poolName="LinuxSelfHosted"

cd "$pathToAgent"

# Stop AzDO agent service
sudo ./svc.sh stop
# Uninstall AzDo agent service, to prevent restart on reboot
sudo ./svc.sh uninstall
# Unregister AzDo agent
az login --identity

secret=`az keyvault secret show --vault-name "$keyVaultName" --name "$secretName" --query "value"`
secret1="${secret:1:${#secret}-2}"

sudo -u $linuxUser -g $linuxUser ./config.sh remove --unattended --url $azdoOrg --auth pat --token $secret1 --pool $poolName --agent $vmName --acceptTeeEula

