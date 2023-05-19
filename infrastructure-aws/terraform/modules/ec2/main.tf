# 9. Create Ec2 ==> Ubuntu server and install/enable Nginx
resource "aws_instance" "web-server-instance" {
  ami               = var.ami_ec2
  instance_type     = "t2.micro"
  availability_zone = var.availabilityZone
  key_name          = var.keyName

  network_interface {
    device_index         = 0
    network_interface_id = var.networkInterface_id
  }
  user_data = var.aws_user_data
  tags = {
    Name = "web-server-freendly"
  }
}


