#!/bin/bash

# This has been script written to deploy the Azure DevOps Agent onto a Liunx virtual machine hosted in Azure
# This uses the RunShellScript command, which requires the VM agent to be installed
# Version 1
# Written on 26/08/2022

# Script Variables
linuxUser='azureuser'
vmName='vm-agent03'
vmResourceGroup='rg-azdo-selfhosted02'
pathToAgent="/home/$linuxUser/myagent"
agentVersion='https://vstsagentpackage.azureedge.net/agent/2.206.1/vsts-agent-linux-x64-2.206.1.tar.gz'
keyVaultName='kvlabselfh02'
secretName='azdoAgentPAT'
azdoOrg="https://dev.azure.com/<yourorg>/"
poolName="LinuxSelfHosted"

# Create Azure DevOps agent directory if doesn't exist
if [ ! -d "$pathToAgent" ]
then
    # fix, the az vm run-command was defaulting to wrong user - Used sudo to resolve this
    sudo -u $linuxUser -g $linuxUser mkdir $pathToAgent
fi

# Lets check to see if the Azure DevOps agent is running
cd "$pathToAgent"
pwd
if ( sudo ./svc.sh status | grep -ce "running" )
then
   echo "Azure DevOps Agent is running, no need to continue with deployment"
   exit 0
else
   # This section of the script, will extract the Azure DevOps agent if required

   if [ ! -f "$pathToAgent/config.sh" ]; then
      sudo -u $linuxUser -g $linuxUser wget $agentVersion
      tarFile=`echo $agentVersion | awk -F'/' '{ print $6 }'`
      tarPath="$pathToAgent/$tarFile"
      sudo -u $linuxUser -g $linuxUser tar -zxvf "$tarPath"
   fi

   # This section of the script, will install Azure CLI
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

   if [ ! -f "$pathToAgent/svc.sh" ]; then
      # This section of the script, will configure agent
      az login --identity

      secret=`az keyvault secret show --vault-name "$keyVaultName" --name "$secretName" --query "value"`
      secret1="${secret:1:${#secret}-2}"
      command="/config.sh --unattended --url $azdoOrg --auth pat --token $secret1 --pool $poolName --agent $vmName --acceptTeeEula"
      sudo -u $linuxUser -g $linuxUser .$command
   fi

   # Lets install and start the agent as a service
   sudo ./svc.sh install
   sudo ./svc.sh start

   # Script has completed
fi     