#!/bin/bash

# This script has been written to uninstall the Azure DevOps Agent on a Liunx virtual machine hosted in Azure
# This uses the RunShellScript command, which requires the VM agent to be installed
# Version 1
# Written on 05/09/2022

linuxUser='azureuser'
pathToAgent="/home/$linuxUser/myagent"

cd "$pathToAgent"

sudo ./svc.sh stop
sudo ./svc.sh uninstall

