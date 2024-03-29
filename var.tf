
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to create subnets in"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets in each availability zone"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "acl_rules" {
  description = "ACL rules provided by the user"
  type        = list(object({
    rule_no       = number
    action        = string
    cidr_block    = string
    protocol      = number
    from_port     = number
    to_port       = number
  }))
  default = [
    {
      rule_no       = 300
      action        = "allow"
      cidr_block    = "0.0.0.0/0"
      protocol      = 6
      from_port     = 80
      to_port       = 80
    },
    {
      rule_no       = 400
      action        = "allow"
      cidr_block    = "0.0.0.0/0"
      protocol      = 22
      from_port     = 22
      to_port       = 22
    }
  ]
}

variable "security_group_rules" {
  description = "Security group rules provided by the user"
  type        = list(object({
    type        = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    },
    {
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    },
    {
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
    }
  ]
}

variable "instance_type" {
  type = string
  description = "EC2 instance type (e.g., t2.micro)"
  default = "t2.micro"
}
