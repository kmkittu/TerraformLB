# Terraform Workshop 
# Introduction #
Welcome to Hands on Workshop! Are you bored with managing your cloud environment via Cloud portal? Are you tired with clicking icons repeatedly in Cloud portal to create resources?  Then it is the workshop you should try. This workshop will give you some different kind of experience for handling Cloud Resources. 
In this workshop we are not going to touch web portal, instead we learn and manage all the Cloud resources through Code, i.e Infrastructure As A Code. We are going to create cloud components/resources through Terraform script. We will discuss in detail about Terraform scripting for each Cloud resource and then we shall learn about creating an Instance in OCI with all dependent resources through Terraform.

### Note: We can use any flavor of Operating system for this workshop and Terraform should have been installed there. Reference: https://www.terraform.io/docs/enterprise/install/installer.html ###

Once Terraform installed and configured, we could follow the below steps.

In this workshop we are going to configure basic Load balancer setup with Web servers. We will be having Network setup with 2 compute web servers along with Load balancers.

## Prerequisites
Oracle Cloud login credentials


Download the attached script (Terraform.zip) available in this page. 
Extract the zip file.

## Steps
1) Prepare Terraform setup files
2) Create the Terraform code for OCI resources
3) Check the code integrity through Terraform plan command
4) Execute the code through Terraform apply command

Lets walk through each step in detail.

###1) Prepare Terraform setup files
The downloaded zip file has terraform.tfvars. It has the basic credentials required to login, that are User OCID, Tenancy OCID, fingerprint, compartment OCID, region and Private key. Lets discuss how to collect those values. 
Login into OCI cloud portal, thats the easy way to collect all the required attribute values.

### Tenancy OCID 
Open the Profile menu (User menu icon)  and click Tenancy: <your_tenancy_name>.
The tenancy OCID is shown under Tenancy Information. Click Copy to copy it to your clipboard.

![Tenancy](https://github.com/kmkittu/TerraformLB/blob/main/Tenancy.png)

The tenancy OCID looks something like this
ocid1.tenancy.oc1..<unique_ID>     (notice the word "tenancy" in it)

### User OCID    
If you're signed in as the user to OCI console: Open the Profile menu (User menu icon)   and click User Settings.
If you're an administrator doing this for another user: Open the navigation menu. Under Governance and Administration, go to Identity and click Users. Select the user from the list.
The user OCID is shown under User Information. Click Copy to copy it to your clipboard.

![User OCID](https://github.com/kmkittu/TerraformLB/blob/main/User%20OCID.png)

### Private key 
SSH key pair is required to login into OCI console
If SSH key pair is not created, then follow the below steps.
Login into any Linux machine and execute openssh command.
    $ openssh genrsa -out oci_key.pem 2048 
    Generating RSA private key, 2048 bit long modulus
    ...................................................................................+++
    .....+++
    e is 65537 (0x10001)

-out denotes output location of the generated private key.  In the above example, oci_key.pem is the private key. 

    [oracle@db key]$ ls -lrt
    -rw-r--r-- 1 oracle oinstall 1679 Apr  3 07:35 oci_key.pem

Generate Public Key with Pem(Privacy Enhanced Mail) format

    [oracle@db key]$ openssh rsa -pubout -in oci_key.pem -out oci_key_public.pem
    writing RSA key
    [oracle@db key]$ ls -lrt
    -rw-r--r-- 1 oracle oinstall 1679 Apr  3 07:35 oci_key.pem
    -rw-r--r-- 1 oracle oinstall  451 Apr  3 07:40 oci_key_public.pem

### Fingerprint   
You can get the key's fingerprint with the following OpenSSL command. If you're using Windows, you'll need to install Git Bash for Windows and run the command with that tool.

    openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c

Also in other way when you upload the public key in the Console (In the user details page) , the fingerprint is also automatically displayed there. It looks something like this: 12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef

![Fingerprint](https://github.com/kmkittu/TerraformLB/blob/main/Add%20public%20Key%20-%20Fingerprint.png)

### Region
Region at which OCI account is associated. You can find this information in the console easily

### Compartment OCID
Open the navigation menu, under Identity you can find compartments. Click that. It will list all the compartments available with the account. Choose the compartment on which we need to create instance. That will show the compartment details including OCID as shown in the picture.

![Compartment](https://github.com/kmkittu/TerraformLB/blob/main/Compartment%20OCID.png)


### Example:

        #tenancy and user information
        tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaalxltbjsgjhukykkd6trlxdfbwjuulnavxqehvv3crknt7ewhlpa"
        user_ocid = "ocid1.user.oc1..aaaaaaaaqidqcqnx6mfprmzt2nn6xudu3t4pgj4bbqlk23axlr4abbjbfyja"
        fingerprint= "bf:0a:e6:c7:9c:93:d2:84:87:94:4f:fc:d4:24:ec:c1"
        private_key_path = "/root/hol/oci_key.pem"


        # Region
        region = "us-ashburn-1"

        # Compartment
        compartment_ocid = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxedffdfdhhghgq7swk426b5hnflyvpq"


Instead of separate terraform.tfvars file we could specify these values directly in the main terraform files.

###2) Create the Terraform script  for OCI resources


3) Check the code integrity through Terraform plan command
4) Execute the code through Terraform apply command




