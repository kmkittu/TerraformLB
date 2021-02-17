# Terraform Workshop 

## Introduction 

Welcome to Hands on Workshop! Are you bored with managing your cloud environment via Cloud portal? Are you tired with clicking icons repeatedly in Cloud portal to create resources?  Then it is the workshop you should try. This workshop will give you some different kind of experience for handling Cloud Resources. 
In this workshop we are not going to touch web portal, instead we learn and manage all the Cloud resources through Code, i.e Infrastructure As A Code. We are going to create cloud components/resources through Terraform script. We will discuss in detail about Terraform scripting for each Cloud resource and then we shall learn about creating an Instance in OCI with all dependent resources through Terraform.

### Note: We can use any flavor of Operating system for this workshop and Terraform should have been installed there. Reference: https://www.terraform.io/docs/enterprise/install/installer.html ###

Once Terraform installed and configured, we could follow the below steps.

In this workshop we are going to configure basic Load balancer setup with Web servers. We will be having Network setup with 2 compute web servers along with Load balancers.

## Prerequisites
Oracle Cloud login credentials

Download the attached script (Terraform.zip - https://github.com/kmkittu/TerraformLB/blob/main/Terraform.zip ) available in this page. 
Extract the zip file.

## Steps
1) Prepare Terraform setup files
2) Create the Terraform code for OCI resources
3) Check the code integrity through Terraform plan command
4) Execute the code through Terraform apply command

Lets walk through each step in detail.

### 1) Prepare Terraform setup files
First we need to collect basic details about about OCI account that are User OCID, Tenancy OCID, fingerprint, compartment OCID, region and Private key. Lets discuss how to collect those values. 
Login into OCI cloud portal to collect all the required attribute values.

#### Tenancy OCID 
Open the Profile menu (User menu icon)  and click Tenancy: <your_tenancy_name>.
The tenancy OCID is shown under Tenancy Information. Click Copy to copy it to your clipboard.

![Tenancy](https://github.com/kmkittu/TerraformLB/blob/main/Tenancy.png)

The tenancy OCID looks something like this
ocid1.tenancy.oc1..<unique_ID>     (notice the word "tenancy" in it)

#### User OCID    
If you're signed in as the user to OCI console: Open the Profile menu (User menu icon)   and click User Settings.
If you're an administrator doing this for another user: Open the navigation menu. Under Governance and Administration, go to Identity and click Users. Select the user from the list.
The user OCID is shown under User Information. Click Copy to copy it to your clipboard.

![User OCID](https://github.com/kmkittu/TerraformLB/blob/main/User%20OCID.png)

#### Private key 
SSH key pair is required to login into OCI console
If SSH key pair is not created, then follow the below steps.
Login into any Linux machine and execute openssh command.

    $ openssh genrsa -out oci_key.pem 2048 
    Generating RSA private key, 2048 bit long modulus
    ...................................................................................+++
    .....+++
    e is 65537 (0x10001)

-out denotes output location of the generated private key.  In the above example, oci_key.pem is the private key. 

    $ ls -lrt
    -rw-r--r-- 1 oracle oinstall 1679 Apr  3 07:35 oci_key.pem

Generate Public Key with Pem(Privacy Enhanced Mail) format

    $ openssh rsa -pubout -in oci_key.pem -out oci_key_public.pem
    writing RSA key
    [oracle@db key]$ ls -lrt
    -rw-r--r-- 1 oracle oinstall 1679 Apr  3 07:35 oci_key.pem
    -rw-r--r-- 1 oracle oinstall  451 Apr  3 07:40 oci_key_public.pem

Login into OCI cloud consile, click user settings. 

![user settings ](https://github.com/kmkittu/TerraformLB/blob/main/user%20settings.png)

In the page click API Key

![api key](https://github.com/kmkittu/TerraformLB/blob/main/user%20API%20keys.png)

Click "Add API Key" button. Paste the oci_key_public.pem there.

![api key button](https://github.com/kmkittu/TerraformLB/blob/main/user%20add%20public%20key.png)

Now our public key become part of OCI. Once the key is added it will listed along with Fingerprint.

#### Fingerprint   
When you upload the public key in the Console (As you did in the user details page) , the fingerprint is also automatically displayed there. It looks something like this: 12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef

You can also get the key's fingerprint with the following OpenSSL command. If you're using Windows, you'll need to install Git Bash for Windows and run the command with that tool.

    openssl rsa -pubout -outform DER -in oci_key_public.pem | openssl md5 -c

![Fingerprint](https://github.com/kmkittu/TerraformLB/blob/main/Add%20public%20Key%20-%20Fingerprint.png)

### SSH public key pair

Create another set of SSH public key pair. This key will be used for compute instance SSH access. We will be specifying public key will creating the instance. Private key will be specified while connecting to the instance.

        # ssh-keygen
        Generating public/private rsa key pair.
        Enter file in which to save the key (/root/.ssh/id_rsa):
        Enter passphrase (empty for no passphrase):
        Enter same passphrase again:
        Your identification has been saved in /root/.ssh/id_rsa.
        Your public key has been saved in /root/.ssh/id_rsa.pub.
        The key fingerprint is:
        SHA256:2rVDTujOKBMWspEdFCKg8/omlPVhFOYRsZ/T+nDunHk root@terraform
        The key's randomart image is:
        +---[RSA 2048]----+
        |+ ..oB+          |
        |.. .+.o          |
        |o  o.+           |
        | o+.oo. o.       |
        |  ++o..+S.+      |
        | +. o. +o= .     |
        |o  . ..oo.+      |
        |... o  +* oE     |
        | o.  o. +B.      |
        +----[SHA256]-----+
        # ls -lrt /root/.ssh/
        total 12
        -rw-------. 1 root root  550 Jan 29 09:27 authorized_keys
        -rw-------. 1 root root 1679 Feb 17 06:56 id_rsa
        -rw-r--r--. 1 root root  396 Feb 17 06:56 id_rsa.pub

#### Region
Region at which OCI account is associated. You can find this information in the console easily

#### Compartment OCID
Open the navigation menu, under Identity you can find compartments. Click that. It will list all the compartments available with the account. Choose the compartment on which we need to create instance. That will show the compartment details including OCID as shown in the picture.
![Compartment](https://github.com/kmkittu/TerraformLB/blob/main/Compartment%20OCID.png)


### 2) Create the Terraform script  for OCI resources
The extracted Zip file has instance.tf which has the terraform script for creating VCN, Public Subnet and 2 compute web servers managed by Load Balancer. Place the instance.tf in the same folder where terraform.tfvars has been placed. In this workshop we cover all the above attributes in the instance.tf file.

Edit the instance.tf file and modify the below lines with above attributes.
        variable "tenancy_ocid" {
        default = "ocid1.tenancy.oc1..aaaaaaaaasqft24cgqwb6lsyij3kmp4nsoiwyn5mboi23mzxywgppre2m6cq"
        }
        variable "user_ocid" {
        default = "ocid1.user.oc1..aaaaaaaan6dokkau7zyiemiggmkht2vvkvhgij3usqnhms5jvddm6h6tbfza"
        }
        variable "fingerprint" {
        default = "2f:80:77:4c:30:8c:5c:e7:d9:94:68:f3:db:3a:ab:25"
        }
        variable "private_key_path" {
        default = "/root/.oci/oci_key.pem"  ===> Private key for OCI login credentials
        }
        variable "compartment_ocid" {
        default = "ocid1.compartment.oc1..aaaaaaaa4cffiat2knvzy4bjs7eprhns5qspej5pfcelkfvrb7s5vahgr4yq"
        }
        variable "region" {
        default = "ap-mumbai-1"
        }

        variable "ssh_authorized_keys" {
        default = "/root/id_rsa.pub"  ==> id_rsa.pub key with its path
        }

### 3) Check the code integrity through Terraform plan command
We have terraform.tfvars and instance.tf files in the same folder and we have already installed Terraform in the local system. Its time to start the execution part.
Execute command “terraform init”.  The terraform init command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration. It is safe to run this command multiple times. It will initialize backed; Install necessary oci provider in the directory and also provide information about deprecated parameters seen in the terraform code.
#### Example
        # terraform init
        Initializing the backend...
        Initializing provider plugins...
        - Reusing previous version of hashicorp/oci from the dependency lock file
        - Installing hashicorp/oci v4.11.0...
        - Installed hashicorp/oci v4.11.0 (signed by HashiCorp)
        Terraform has been successfully initialized!
        You may now begin working with Terraform. Try running "terraform plan" to see
        any changes that are required for your infrastructure. All Terraform commands
        should now work.
        If you ever set or change modules or backend configuration for Terraform,
        rerun this command to reinitialize your working directory. If you forget, other
        commands will detect it and remind you to do so if necessary.

Its time to execute “terraform plan” command.  The terraform plan command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files. This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state.
It will show the list of Cloud resources to be created. That information gives an idea of what this terraform script tries to achieve.
#### Example
         terraform plan -out instance.out

        An execution plan has been generated and is shown below.
        Resource actions are indicated with the following symbols:
        + create
        Terraform will perform the following actions:
        # oci_core_instance.instance1 will be created
        + resource "oci_core_instance" "instance1" {
            + availability_domain                 = "LxbT:AP-MUMBAI-1-AD-1"
            + boot_volume_id                      = (known after apply).
        .
        .
        .
        This plan was saved to: instance.out

        To perform exactly these actions, run the following command to apply:
            terraform apply "instance.out"

You can refer the full output of plan command in the attached instanct.out file. In case any errors are thrown as part of Plan execution, that has to be addressed first before proceeding to execution.

### 4) Execute the code through Terraform apply command
The terraform apply command is used to apply the changes required to reach the desired state of the configuration. The apply command will refer all the terraform scripts in the current folder and execute it in the appropriate order. Terraform knows which resource should be created first and it follows the predetermined order for resource creation. That’s where Terraform succeeds than Ansible. 


        [root@terraform 5.w]# terraform apply -auto-approve
        oci_core_vcn.vcn1: Creating...
        oci_core_public_ip.test_reserved_ip: Creating...
        oci_core_public_ip.test_reserved_ip: Creation complete after 0s [id=ocid1.publicip.oc1.ap-mumbai-1.amaaaaaaulymzmianfxwrxqzlpkitizgzogiekbeogsfuldvvwenepymy7xq]
        oci_core_vcn.vcn1: Creation complete after 0s [id=ocid1.vcn.oc1.ap-mumbai-1.amaaaaaaulymzmiacgejgo3r5fbgq6rlmgss4yzqjeqiysqwtil723dkauba]
        oci_core_internet_gateway.internetgateway1: Creating...
        oci_core_security_list.securitylist1: Creating...
        oci_core_security_list.securitylist1: Creation complete after 1s [id=ocid1.securitylist.oc1.ap-mumbai-1.aaaaaaaa2f7pbpn7k4egbdsoc4k6ocadnunatzakhgap5eovpcn5jixuwzra]
        oci_core_internet_gateway.internetgateway1: Creation complete after 1s [id=ocid1.internetgateway.oc1.ap-mumbai-1.aaaaaaaa57drr3gz4zo6gvfm4xrdym26r664xmz2zv5f63ogl54dmck543fq]
        oci_core_route_table.routetable1: Creating...
        oci_core_route_table.routetable1: Creation complete after 0s [id=ocid1.routetable.oc1.ap-mumbai-1.aaaaaaaab3bdjhidevnqyut5ei52353dg3wkgtmev5t73uxthrzy6u7ojqoq]
        oci_core_subnet.subnet2: Creating...
        oci_core_subnet.subnet1: Creating...
        oci_core_subnet.subnet2: Provisioning with 'local-exec'...
        oci_core_subnet.subnet2 (local-exec): Executing: ["/bin/sh" "-c" "sleep 5"]
        oci_core_subnet.subnet1: Provisioning with 'local-exec'...
        oci_core_subnet.subnet1 (local-exec): Executing: ["/bin/sh" "-c" "sleep 5"]
        oci_core_subnet.subnet2: Creation complete after 10s [id=ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaauhjqv2bnc4dem6bd6sa4ip2s3gw5yepwl6vosuu4opqh7bsgydfq]
        oci_core_instance.instance2: Creating...
        oci_core_subnet.subnet1: Still creating... [10s elapsed]
        oci_core_subnet.subnet1: Creation complete after 12s [id=ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaa3ksq2zrgzouruxbbqfmv5brrsb6s3wcyagpq4vvglfj2vnyzck3q]
        oci_load_balancer.lb1: Creating...
        oci_core_instance.instance1: Creating...
        oci_core_instance.instance2: Still creating... [10s elapsed]
        oci_load_balancer.lb1: Still creating... [10s elapsed]
        oci_core_instance.instance1: Still creating... [10s elapsed]
        oci_core_instance.instance2: Still creating... [20s elapsed]
        oci_core_instance.instance1: Still creating... [20s elapsed]
        oci_load_balancer.lb1: Still creating... [20s elapsed]
        oci_core_instance.instance2: Still creating... [30s elapsed]
        oci_load_balancer.lb1: Still creating... [30s elapsed]
        oci_core_instance.instance1: Still creating... [30s elapsed]
        oci_core_instance.instance2: Still creating... [40s elapsed]
        oci_core_instance.instance1: Still creating... [40s elapsed]
        oci_load_balancer.lb1: Still creating... [40s elapsed]
        oci_load_balancer.lb1: Creation complete after 44s [id=ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a]
        oci_load_balancer_hostname.test_hostname2: Creating...
        oci_load_balancer_hostname.test_hostname1: Creating...
        oci_load_balancer_backend_set.lb-bes1: Creating...
        oci_core_instance.instance2: Still creating... [50s elapsed]
        oci_core_instance.instance1: Still creating... [50s elapsed]
        oci_load_balancer_hostname.test_hostname2: Still creating... [10s elapsed]
        oci_load_balancer_hostname.test_hostname1: Still creating... [10s elapsed]
        oci_load_balancer_backend_set.lb-bes1: Still creating... [10s elapsed]
        oci_core_instance.instance2: Still creating... [1m0s elapsed]
        oci_load_balancer_hostname.test_hostname1: Creation complete after 14s [id=loadBalancers/ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a/hostnames/hostname1]
        oci_core_instance.instance1: Still creating... [1m0s elapsed]
        oci_load_balancer_hostname.test_hostname2: Still creating... [20s elapsed]
        oci_load_balancer_backend_set.lb-bes1: Still creating... [20s elapsed]
        oci_core_instance.instance1: Creation complete after 1m6s [id=ocid1.instance.oc1.ap-mumbai-1.anrg6ljrulymzmicooxhugcxc6d3qkkcqrlttdjt5slydk6hionjhpoj474a]
        oci_core_instance.instance2: Still creating... [1m10s elapsed]
        oci_load_balancer_hostname.test_hostname2: Still creating... [30s elapsed]
        oci_load_balancer_backend_set.lb-bes1: Still creating... [30s elapsed]
        oci_core_instance.instance2: Creation complete after 1m18s [id=ocid1.instance.oc1.ap-mumbai-1.anrg6ljrulymzmictsllnz3wtdgah5m3xkuegin5xfias5nq3mzoj34stguq]
        oci_load_balancer_hostname.test_hostname2: Creation complete after 34s [id=loadBalancers/ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a/hostnames/hostname2]
        oci_load_balancer_backend_set.lb-bes1: Still creating... [40s elapsed]
        oci_load_balancer_backend_set.lb-bes1: Still creating... [50s elapsed]
        oci_load_balancer_backend_set.lb-bes1: Creation complete after 54s [id=loadBalancers/ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a/backendSets/lb-bes1]
        oci_load_balancer_backend.lb-be2: Creating...
        oci_load_balancer_backend.lb-be1: Creating...
        oci_load_balancer_listener.lb-listener1: Creating...
        oci_load_balancer_backend.lb-be1: Still creating... [10s elapsed]
        oci_load_balancer_backend.lb-be2: Still creating... [10s elapsed]
        oci_load_balancer_listener.lb-listener1: Still creating... [10s elapsed]
        oci_load_balancer_backend.lb-be1: Still creating... [20s elapsed]
        oci_load_balancer_backend.lb-be2: Still creating... [20s elapsed]
        oci_load_balancer_listener.lb-listener1: Still creating... [20s elapsed]
        oci_load_balancer_backend.lb-be1: Still creating... [30s elapsed]
        oci_load_balancer_backend.lb-be2: Still creating... [30s elapsed]
        oci_load_balancer_listener.lb-listener1: Still creating... [30s elapsed]
        oci_load_balancer_backend.lb-be2: Creation complete after 34s [id=loadBalancers/ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a/backendSets/lb-bes1/backends/10.1.21.2:80]
        oci_load_balancer_backend.lb-be1: Still creating... [40s elapsed]
        oci_load_balancer_listener.lb-listener1: Still creating... [40s elapsed]
        oci_load_balancer_backend.lb-be1: Still creating... [50s elapsed]
        oci_load_balancer_listener.lb-listener1: Still creating... [50s elapsed]
        oci_load_balancer_listener.lb-listener1: Creation complete after 54s [id=loadBalancers/ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a/listeners/http]
        oci_load_balancer_backend.lb-be1: Still creating... [1m0s elapsed]
        oci_load_balancer_backend.lb-be1: Creation complete after 1m7s [id=loadBalancers/ocid1.loadbalancer.oc1.ap-mumbai-1.aaaaaaaarh3c4ass3fwrwp676hobwftb44soqms5el72w43sthzr6qy2s24a/backendSets/lb-bes1/backends/10.1.20.2:80]

        Warning: Value for undeclared variable

        The root module does not declare a variable named "vcn_display_name" but a
        value was found in file "terraform.tfvars". To use this value, add a
        "variable" block to the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Value for undeclared variable

        The root module does not declare a variable named "vcn_cidr" but a value was
        found in file "terraform.tfvars". To use this value, add a "variable" block to
        the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

        Outputs:

        lb_public_ip = [
        tolist([
            {
            "ip_address" = "152.67.31.57"
            "is_public" = true
            "reserved_ip" = tolist([
                {
                "id" = "ocid1.publicip.oc1.ap-mumbai-1.amaaaaaaulymzmianfxwrxqzlpkitizgzogiekbeogsfuldvvwenepymy7xq"
                },
            ])
            },
        ]),
        ]

Terraform scrip exectuion is completed. We could verify the resource creation through web portal.
Lets verify one by one. 
Login into OCI cloud portal and Click Networking -> Virtual Cloud Networks

![VCNn](https://github.com/kmkittu/TerraformLB/blob/main/VCN.png)

Verify that Load balancer is created by Terraform script execution. Click Networking -> Load balancers

![LBR](https://github.com/kmkittu/TerraformLB/blob/main/Load%20Balancers.png)

Click Compute -> Instances

![Instances](https://github.com/kmkittu/TerraformLB/blob/main/Instances%20page.png)

The page shows 2 compute instances are created and Web server has been installed in those server.
Lets verify the Web server page.

Ping first web server IP

![second web server](https://github.com/kmkittu/TerraformLB/blob/main/Second%20webserver.png)

We could see the server name in the first line. Lets ping second web server IP.

![First web server](https://github.com/kmkittu/TerraformLB/blob/main/First%20web%20server.png)

The first line shows the second web server name. As we know we have covered Both the compute instances via Load balancers and the traffic to Load balancer will be forwarded to one of the webserver. Lets test it.

![LBR1](https://github.com/kmkittu/TerraformLB/blob/main/Load%20Balancers1.png)

We have invoked Load balancers IP, it has forwarded to one of the web server. As per the setup the subsequent attempts should transfer to another web server. Lets test it by refreshing the browser.

![LBR2](https://github.com/kmkittu/TerraformLB/blob/main/Load%20Balancers2.png)

We could see it has forwarded to another web server. It concludes that Terraform script has created VCN and Two web servers managed by Load balancer.

