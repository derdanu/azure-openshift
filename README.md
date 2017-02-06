# RedHat Openshift Origin cluster on Azure

When creating the RedHat Openshift Origin cluster on Azure, you will need an SSH RSA key for access. 

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

### Create the cluster with azure cli
```
azure group deployment create <RessourceGroupName> <DeploymentName> --template-uri https://raw.githubusercontent.com/derdanu/azure-openshift/master/azuredeploy.json
```

## Install Openshift Origin with Ansible

After the Azure resources have been deployed by using this ARM template, you must connect via SSH to the jumbox. SSH Agentforwarding is required. The Installation is based on [Openshift Ansible](https://github.com/openshift/openshift-ansible). The lastest repository has been checked out on the jumpbox into the directory */opt/openshift-ansible/* and a minimal configuration file was created at */etc/ansible/hosts* for [Openshift Origin](https://github.com/openshift/origin).
To start the installation call the following bash script:

### Bash or Cygwin Terminal

```bash
user@localmachine:~$ eval $(ssh-agent)
user@localmachine:~$ ssh-add
user@localmachine:~$ ssh -A <JumpboxIP>
[adminUsername@jumpbox ~]$ ./openshift-install.sh
```

### Putty on Windows

To login on the jumpbox please refer to the [Agent forwarding HowTo](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#key-management-and-agent-forwarding-with-windows-pageant) for Putty using Pageant.

```bash  
[adminUsername@jumpbox ~]$ ./openshift-install.sh
```

------

## Parameters
### Input Parameters

| Name| Type           | Description |
| ------------- | ------------- | ------------- |
| adminUsername  | String | Username for SSH Login and Openshift Webconsole |
| adminPassword | SecureString | Password for the Openshift Webconsole |
| sshKeyData | String | Public SSH Key for the Virtual Machines |
| masterDnsName  | String | DNS Prefix for the Openshift Master / Webconsole | 
| image | String | Operating System to use. RHEL or CentOs |
| numberOfMasterNodes | Integer | Number of Openshift master nodes to create (usually either 1 or 3) |
| masterVMSize | String | The size of the master nodes |
| masterVMstorType | string | premium or standard storage |
| numberOfinfrasndes  | Integer | Number of Openshift intra nodes to create |
| infranodeVMSize| String | The size of the infra nodes |
| infranodeVMstorType | string | premium or standard storage |
| numberOfNodes  | Integer | Number of Openshift Nodes to create |
| nodeVMSize| String | The size of each node |
| nodeVMstorType | string | premium or standard storage |
| jumpVMSize| String | The size of the jumpbox |
| jumpVMstorType | string | premium or standard storage |

### Output Parameters

| Name| Type           | Description |
| ------------- | ------------- | ------------- |
| openshift Webconsole | String | URL of the Openshift Webconsole |
| openshift Jumpbox ssh |String | SSH String to Login at the Jumpbox |
| openshift CLI |String | OC command String to Login |
| openshift Router Public IP | String | Router Public IP. Needed if you want to create your own Wildcard DNS |

------

This template deploys a RedHat Openshift Origin cluster on Azure.
