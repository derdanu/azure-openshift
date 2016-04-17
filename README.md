# RedHat Openshift Origin cluster on Azure

When creating the RedHat Openshift Origin cluster on Azure, you will need a SSH RSA key for access. 

## SSH Key Generation

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac

## Create the cluster
### Create the cluster on the Azure Portal

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fderdanu%2Fazure-openshift%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fderdanu%2Fazure-openshift%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

### Create the cluster with powershell

```powershell
New-AzureRmResourceGroupDeployment -Name <DeploymentName> -ResourceGroupName <RessourceGroupName> -TemplateUri https://raw.githubusercontent.com/derdanu/azure-openshift/master/azuredeploy.json
```

## Install Openshift Origin with Ansible

You must use SSH Agentforwarding. The Installation is based on [Openshift Ansible](https://github.com/openshift/openshift-ansible). The lastest repository has been checked out on the master into the directory */opt/openshift-ansible/* and a minimal configuration file was created at */etc/ansible/hosts* for (Openshift Origin)[https://github.com/openshift/origin].


### Bash or Cygwin Terminal

```bash
user@localmachine:~$ eval `ssh-agent`
user@localmachine:~$ ssh-add
user@localmachine:~$ ssh -A <MasterIP>
[adminUsername@master ~]$ ./openshift-install.sh
```

### Putty on Windows

To login on the Master please refer to the [Agent forwarding HowTo](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#key-management-and-agent-forwarding-with-windows-pageant) for Putty using Pageant.

```bash  
[adminUsername@master ~]$ ./openshift-install.sh
```

------

## Parameters
### Input Parameters

| Name| Type           | Description |
| ------------- | ------------- | ------------- |
| adminUsername  | String       | Username for SSH Login and Openshift Webconsole |
|  adminPassword | SecureString | Password for the Openshift Webconsole |
| sshKeyData     | String       | Public SSH Key for the Virtual Machines |
| masterDnsName  | String       | DNS Prefix for the Openshift Master / Webconsole | 
| numberOfNodes  | Integer      | Number of Openshift Nodes to create |

### Output Parameters

| Name| Type           | Description |
| ------------- | ------------- | ------------- |
| openshift Webconsole | String       | URL of the Openshift Webconsole |
| openshift Master ssh |String | SSH String to Login at the Master |
| openshift Router Public IP | String       | Router Public IP. Needed if you want to create your own Wildcard DNS |

------

This template deploys a RedHat Openshift Origin cluster on Azure.