
# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_key_pair" "example" {
  key_name   = "srinu-key"  # Replace with your desired key name
  public_key = file("/root/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}


# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Create subnets in each availability zone
resource "aws_subnet" "my_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.my_subnets[0].id
  route_table_id = aws_route_table.my_route_table.id
}

# Create ACL rules
resource "aws_network_acl" "my_acl" {
  vpc_id = aws_vpc.my_vpc.id

  # Define ingress and egress rules based on user input
  ingress {
    rule_no     = var.acl_rules[0].rule_no
    from_port   = var.acl_rules[0].from_port
    action      = var.acl_rules[0].action
    to_port     = var.acl_rules[0].to_port
    protocol    = var.acl_rules[0].protocol
    cidr_block  = var.acl_rules[0].cidr_block
  }

  egress {
    rule_no     = var.acl_rules[1].rule_no
    from_port   = var.acl_rules[1].from_port
    action      = var.acl_rules[1].action
    to_port     = var.acl_rules[1].to_port
    protocol    = var.acl_rules[1].protocol
    cidr_block  = var.acl_rules[1].cidr_block
  }
}

# Create security group
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "My Security Group"

  # Define ingress and egress rules based on user input
  ingress {
    from_port   = var.security_group_rules[0].from_port
    to_port     = var.security_group_rules[0].to_port
    protocol    = var.security_group_rules[0].protocol
    cidr_blocks = var.security_group_rules[0].cidr_blocks
  }

  egress {
    from_port   = var.security_group_rules[1].from_port
    to_port     = var.security_group_rules[1].to_port
    protocol    = var.security_group_rules[1].protocol
    cidr_blocks = var.security_group_rules[1].cidr_blocks
  }

  vpc_id = aws_vpc.my_vpc.id
}

# EC2 Instance
resource "aws_instance" "ec2" {
  count = 1
  ami           = "ami-080e1f13689e07408" # Replace with desired AMI ID
  instance_type = var.instance_type
  key_name      = aws_key_pair.example.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id = aws_subnet.my_subnets[0].id

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("/root/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update",
      "sudo apt list upgradable",
      "sudo apt install software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
    ]
  }

  tags = {
    Name = "My-EC2-Instance"
  }
}

# Create EBS volume
resource "aws_ebs_volume" "my_volume" {
  availability_zone = var.availability_zones[0]  # Specify the availability zone where the instance is launched
  size              = 10  # Size of the EBS volume in GiB
  tags = {
    Name = "MyEBSVolume"
  }
}

# Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/xvdf"  # Device name to attach the volume to (replace with appropriate device name)
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.ec2[0].id
}
