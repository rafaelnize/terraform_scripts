variable "project" {
   description = "Ex: project01"
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "sa-east-1"
}

variable "aws_zones" {
    description = "example: sa-east-1a, sa-east-1c"
    default = "sa-east-1a, sa-east-1c"
}

variable "subnet_list" {
   description = "Example subnet-b7a68fd2, subnet-ab6ebcf2"
}

variable "subnet_elb_list" {
    description = "Example subnet-b7a68fd2, subnet-bda333ca, subnet-ab6ebcf2"
}

variable "aws_access_key" {
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
}

variable "aws_vpc_id" {
   description = "vpc-caeba7af"
}

variable "instances" {
  default = 2
}

variable "subnet_list" {
   description = "subnet-69ded60c, subnet-6bf3911c, subnet-0dfe4a54"
}

variable "instance_type" {
    description = "Instance type"
    default = "t2.micro"
}

variable "aws_amis" {
    default = {
        sa-east-1 = "ami-4d883350"
        #sa-east-1 = "ami-109b1f7c"
    }
}

variable "server_prefix" {
    description = "Server name prefix"
    default = "tf_web"
}

variable "sshusername" {
    description = "Name of the SSH login to use in AWS."
    default = "ubuntu"
}

variable "key_name" {
    description = "Name of the SSH keypair to use in AWS."
    default = "terraform_mlg_b"
}

variable "key_path" {
    description = "Path to the private portion of the SSH key specified."
    default = "/home/terraform/.ssh/id_rsa"
}

#variable "dns_zone_id" {
#    description = "DNS Zone id"
#}
