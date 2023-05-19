# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = var.subnetid
  private_ips     = ["10.0.1.50"]
  security_groups = var.securitygroups
}