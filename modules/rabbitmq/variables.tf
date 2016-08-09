variable "project" {
   description = "Ex: retira-loja"
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "sa-east-1"
}

variable "aws_zones" {
    description = "sa-east-1a sa-east-1c"
    default = "sa-east-1a, sa-east-1c"
}

variable "aws_access_key" {
    decscription = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
}

variable "aws_vpc_id" {
   description = "Ex: vpc-7f95d51a"
}

variable "instances" {
  default = 2
}

variable "subnet_list" {
   description = "Example: subnet-b7a68fd2, subnet-b7a68fd2, subnet-ab6ebcf2"
}

variable "instance_type" {
    description = "Instance type"
    default = "t2.micro"
}

variable "aws_amis" {
    default = {
        sa-east-1 = "ami-0fb83963"
    }
}

variable "server_prefix" {
    description = "Server name prefix"
    default = "tf-rabbitmq"
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

variable "dns_zone_id" {
    description = "DNS Zone id"
}
