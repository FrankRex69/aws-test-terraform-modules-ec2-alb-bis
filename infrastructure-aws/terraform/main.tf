# Variables from variables.tfvars

variable "aws_profile" {
    type = string
}
variable "aws_region" {
    type = string
}
variable "aws_availability_zone" {
    type = string
}
variable "aws_ami_ec2" {
    type = string
}
variable "aws_key_name" {
    type = string
}



# ---------------------------------------------------
# Provider
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}


# ---------------------------------------------------
## CALL MODULES

# 1. Create vpc
module "vpc" {
    source = "./modules/vpc"
}
# 2. Create Internet Gateway
module "ig" {
    source = "./modules/ig"
    # vpc_id = aws_vpc.prod-vpc.id
    vpc_id = module.vpc.vpc.id
}
# 3. Create Custom Route Table
module "rt" {
    source = "./modules/rt"
    vpc_id = module.vpc.vpc.id
    gatewayId = module.ig.gateway.id
}
# 4. Create a Subnet 
module "subnet" {
    source = "./modules/subnet"
    vpc_id = module.vpc.vpc.id
    availabilityzone = var.aws_availability_zone
}
# 5. Associate subnet with Route Table
module "ass_route_table" {
    source = "./modules/ass_route_table"
    subnetId = module.subnet.subnet_id
    routeTable_id = module.rt.route_table_id
}
# 6. Create Security Group to allow port 22,80,443
module "sg" {
    source = "./modules/sg"
    vpc_id = module.vpc.vpc.id
}
# 7. Create a network interface with an ip in the subnet that was created in step 4
module "ni" {
    source = "./modules/ni"
    subnetid      = module.subnet.subnet_id
    securitygroups = [module.sg.security_groups_id]
}
# 8. Assign an elastic IP to the network interface created in step 7
module "elastic_ip" {
    source = "./modules/elastic_ip"
    networkinterface         = module.ni.network_interface_id
    internet_gateway = [module.ig.gateway]
}
# 9. Create Ec2 ==> Ubuntu server and install/enable Nginx
module "ec2" {
    source = "./modules/ec2"
    ami_ec2               = var.aws_ami_ec2
    availabilityZone = var.aws_availability_zone
    keyName          = var.aws_key_name
    networkInterface_id = module.ni.network_interface_id
    aws_user_data = file("userdata.tpl")
}


# ---------------------------------------------------
# Output
output "serverPublic_ip" {
    value = module.ec2.server_public_ip
}
output "serverPrivate_ip" {
    value = module.ec2.server_private_ip
}
output "vpc_id" {
    value = module.vpc.vpc.id
}