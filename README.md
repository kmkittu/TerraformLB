# Terraform Workshop 
# Introduction #
Welcome to Hands on Workshop! Are you bored with managing your cloud environment via Cloud portal? Are you tired with clicking icons repeatedly in Cloud portal to create resources?  Then it is the workshop you should try. This workshop will give you some different kind of experience for handling Cloud Resources. 
In this workshop we are not going to touch web portal, instead we learn and manage all the Cloud resources through Code, i.e Infrastructure As A Code. We are going to create cloud components/resources through Terraform script. We will discuss in detail about Terraform scripting for each Cloud resource and then we shall learn about creating an Instance in OCI with all dependent resources through Terraform.

### Note: We can use any flavor of Operating system for this workshop and Terraform should have been installed there. Reference: https://www.terraform.io/docs/enterprise/install/installer.html ###

Once Terraform installed and configured, we could follow the below steps.

In this workshop we are going to configure basic Load balancer setup with Web servers. We will be having Network setup with 2 compute web servers along with Load balancers.

## Prerequisites
Oracle Cloud login credentials

## Steps
1) Prepare Terraform setup files
2) Create the Terraform code for OCI resources
3) Check the code integrity through Terraform plan command
4) Execute the code through Terraform apply command

Lets walk through each step in detail.

###1) Prepare Terraform setup files

Remember we are going to create resources in cloud, for that first we need to specify OCI credentials to terraform for login into OCI. We shall create terraform.tfvars file and include all the login credentials in that. The basic credentials required to login are User OCID, Tenancy OCID, fingerprint, compartment OCID, region and Private key. 

First create a folder to store all Terraform scripts. Inside the folder create terraform.tfvars with below details.
    #tenancy and user information
    tenancy_ocid = <Tenancy OCID>
    user_ocid = <User OCID>
    fingerprint= <FinerPrint value>
    private_key_path = <Private key file with location>

### Tenancy OCID 
Open the Profile menu (User menu icon)  and click Tenancy: <your_tenancy_name>.
The tenancy OCID is shown under Tenancy Information. Click Copy to copy it to your clipboard.

![Tenancy](https://github.com/kmkittu/Terraform_LB/blob/main/Tenancy.png)

The tenancy OCID looks something like this
ocid1.tenancy.oc1..<unique_ID>     (notice the word "tenancy" in it)


