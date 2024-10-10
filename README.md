# Deploying a MariaDB Database on cPouta using Terraform

The aim of this repository is to set up a MariaDB database on [cPouta](https://docs.csc.fi/cloud/pouta/) using [Terraform](https://developer.hashicorp.com/terraform/docs).

**Note: The default variables will need to be modified or overridden using the `-var` flags**

## Installation

We need to install some tools before we start

### OpenStack

Follow the instructions from the [CSC documentation](https://docs.csc.fi/cloud/pouta/install-client/) to install the OpenStack command line tools.
Ensure you download the OpenStack RC file as described [here](https://docs.csc.fi/cloud/pouta/install-client/#configure-your-terminal-environment-for-openstack) and execute the following command to add the environment variables 
```bash
source <project_name_here>-openrc.sh
```
You will be prompted to enter your CSC password.

To verify that the setup worked run
```bash
openstack flavor list
```
which will list all the available flavors as seen [here](https://docs.csc.fi/cloud/pouta/vm-flavors-and-billing/#cpouta-flavors).


### Terraform 

[Install Terraform](https://developer.hashicorp.com/terraform/downloads) suitable to the operating system on your local device.


## Deployment

There are three different stacks that can be deployed

1. [networking](base/) : The networking configuration that will be common. Needs to be run once
2. [cloud-volume](cloud-volume/): Creating a new persistent data volume
3. [server](server/): Creating a server instance for Neo4J

### Fresh Deployment

When deploying for the first time you will need to first create the floating IP address, the security group (and its rules) once.

First create a ssh keypair:

```bash
ssh-keygen -t rsa cloud.key
```

Then create the networking stack using the following commands:

```bash
cd networking
terraform init
terraform apply --var 'ssh_key_file=../cloud.key'
```
Note the floating ip address manually or by using `terraform output -json > ./networking.json`.

Next, create the `cloud-volume` stack by executing the following commands from the root directory to create 1600GB storage:

```bash
cd storage
terraform init 
terraform apply --var 'storage_size=1638400'
```
This will create a default persistent data volume. Save the name of the `volume_id` for the next steps either manually or by using `terraform output -json > ./storage.json`

Next, create the `server` stack by executing the following commands from the root directory:
```bash
cd server
terraform init
terraform apply 
```

This will ask the values the `volume-id`, `floating-ip` and other variables from the previous stacks.

## Accessing the database

Use `host -a <floating-ip-address>` to find the DNS name of the IP. Use this as the host to connect to MariaDB from any SQL client like DBeaver.

