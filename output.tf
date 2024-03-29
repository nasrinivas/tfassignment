# Output 

output "vpc_id" {
  value = aws_vpc.my_vpc.id
  description = "vpc output"
}

output "subnet_id" {
  value = aws_subnet.my_subnets[0].id
  description = "ID of the EC2 instance"
}

output "public_ip" {
  value = aws_instance.ec2[0].public_ip
  description = "Public IP address of the EC2 instance"
}

output "instance_id" {
  value = aws_instance.ec2[0].id
  description = "ID of the EC2 instance"
}

