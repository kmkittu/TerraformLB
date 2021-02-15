
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
default = "/root/.oci/oci_api_key.pem"
}

variable "compartment_ocid" {
default = "ocid1.compartment.oc1..aaaaaaaa4cffiat2knvzy4bjs7eprhns5qspej5pfcelkfvrb7s5vahgr4yq"
}

variable "region" {
default = "ap-mumbai-1"
}


variable "preserve_boot_volume" {
  default = false
}
variable "boot_volume_size_in_gbs" {
  default = "256"
}
variable "assign_public_ip" {
  default = ""
}

variable "ssh_authorized_keys" {
  default = "/root/tcs_scripts/4.w/new.pub"
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

variable "availability_domain" {
  default = 1
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domain" "ad1" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}


/* Network */

resource "oci_core_vcn" "vcn1" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "vcn1"
  dns_label      = "vcn1"
}

resource "oci_core_subnet" "subnet1" {
  availability_domain = data.oci_identity_availability_domain.ad1.name
  cidr_block          = "10.1.20.0/24"
  display_name        = "subnet1"
  dns_label           = "subnet1"
  security_list_ids   = [oci_core_security_list.securitylist1.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1.id
  route_table_id      = oci_core_route_table.routetable1.id
  dhcp_options_id     = oci_core_vcn.vcn1.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_subnet" "subnet2" {
  availability_domain = data.oci_identity_availability_domain.ad1.name
  cidr_block          = "10.1.21.0/24"
  display_name        = "subnet2"
  dns_label           = "subnet2"
  security_list_ids   = [oci_core_security_list.securitylist1.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1.id
  route_table_id      = oci_core_route_table.routetable1.id
  dhcp_options_id     = oci_core_vcn.vcn1.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_internet_gateway" "internetgateway1" {
  compartment_id = var.compartment_ocid
  display_name   = "internetgateway1"
  vcn_id         = oci_core_vcn.vcn1.id
}

resource "oci_core_route_table" "routetable1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "routetable1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internetgateway1.id
  }
}

resource "oci_core_public_ip" "test_reserved_ip" {
  compartment_id = "${var.compartment_ocid}"
  lifetime       = "RESERVED"

  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

resource "oci_core_security_list" "securitylist1" {
  display_name   = "public"
  compartment_id = oci_core_vcn.vcn1.compartment_id
  vcn_id         = oci_core_vcn.vcn1.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22 
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }
}

/* Instances */

resource "oci_core_instance" "instance1" {
  availability_domain = "LxbT:AP-MUMBAI-1-AD-1"
  compartment_id      = var.compartment_ocid
  display_name        = "be-instance1"
  shape               = "VM.Standard2.1"

  metadata = {
    user_data = base64encode(var.user-data)
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet1.id
    hostname_label = "be-instance1"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa7oaxxmtsvkk5vc53bryvxlxqn7lb5bjemkhbw5newm7oulnzquwq"
  }
}

resource "oci_core_instance" "instance2" {
    availability_domain = "LxbT:AP-MUMBAI-1-AD-1"
  compartment_id      = var.compartment_ocid
  display_name        = "be-instance2"
  shape               = "VM.Standard2.1"

  metadata = {
    user_data = base64encode(var.user-data)
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet2.id
    hostname_label = "be-instance2"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa7oaxxmtsvkk5vc53bryvxlxqn7lb5bjemkhbw5newm7oulnzquwq"
  }
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver Apache installation begins #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
# yum update -y
echo '########## basic webserver ##############'
yum install -y httpd
systemctl enable  httpd.service
systemctl start  httpd.service
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
firewall-offline-cmd --add-service=http
systemctl enable  firewalld
systemctl restart  firewalld
touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF

}

/* Load Balancer */

resource "oci_load_balancer" "lb1" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.subnet1.id
  ]

  display_name = "lb1"
  reserved_ips {
      id = "${oci_core_public_ip.test_reserved_ip.id}"
    }
}


variable "load_balancer_shape_details_maximum_bandwidth_in_mbps" {
  default = 100
}

variable "load_balancer_shape_details_minimum_bandwidth_in_mbps" {
  default = 10
}

resource "oci_load_balancer_backend_set" "lb-bes1" {
  name             = "lb-bes1"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}


resource "oci_load_balancer_hostname" "test_hostname1" {
  #Required
  hostname         = "app.example.com"
  load_balancer_id = oci_load_balancer.lb1.id
  name             = "hostname1"
}

resource "oci_load_balancer_hostname" "test_hostname2" {
  #Required
  hostname         = "app2.example.com"
  load_balancer_id = oci_load_balancer.lb1.id
  name             = "hostname2"
}

resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
  hostname_names           = [oci_load_balancer_hostname.test_hostname1.name, oci_load_balancer_hostname.test_hostname2.name]
  port                     = 80
  protocol                 = "HTTP"
#  rule_set_names           = [oci_load_balancer_rule_set.test_rule_set.name]

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}


resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.instance1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be2" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.instance2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}


output "lb_public_ip" {
  value = [oci_load_balancer.lb1.ip_address_details]
}


