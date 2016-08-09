variable "availability_zones" {
   description = "availability zones for elb pools"
   default = "sa-east-1a"

}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "sa-east-1"
}


variable "vpc_id" {
   default = "vpc-7f95d51a"
}

variable "elb_name" {
   description = "ELB name"

}

variable "instances" {
  default = 3
}

variable "subnet_list" {
   description = "list of subnets that ELB will answer for"
}
