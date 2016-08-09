# Specify the provider and access details
provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

resource "aws_security_group" "rabbitmq-srv" {
        name = "${var.project}-rabbitmq-sg"
        description = "RabbitMQ "
        vpc_id = "${var.aws_vpc_id}"
        ingress {
           from_port = 22
           to_port = 22
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
           from_port = 4369
           to_port = 4369
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
           from_port = 5671
           to_port = 5672
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
           from_port = 15672
           to_port = 15672
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
           from_port = 61613
           to_port = 61614
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }

}

resource "aws_instance" "ec2" {
  count = "${var.instances}"
  connection {
    user = "${var.sshusername}"
    key_file = "${var.key_path}"
  }
  instance_type = "${var.instance_type}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = ["${aws_security_group.rabbitmq-srv.*.id}"]
  key_name = "${var.key_name}"
  subnet_id = "${element(split(",", var.subnet_list), count.index)}"
  tags {
    "Name" = "${var.project}-${var.server_prefix}-${format("%02d", count.index+1)}"
    "Notes" = "RabbitMQ Server - Created by Terraform"
  }
}


#####################  EBS disks #####################################################

resource "aws_ebs_volume" "ebsvol01" {
        count = "${var.instances}"
        availability_zone = "${element(aws_instance.ec2.*.availability_zone, count.index)}"
        size = 10
        type = "gp2"
        tags {
            "Name" = "${element(aws_instance.ec2.*.tags.Name, count.index)}"
            "Notes" = "RabbitMQ - Created by Terraform"
        }
}

resource "aws_volume_attachment" "ebs_att01" {
  count = "${var.instances}"
  device_name = "/dev/xvdi"
  volume_id = "${element(aws_ebs_volume.ebsvol01.*.id, count.index)}"
  instance_id = "${element(aws_instance.ec2.*.id, count.index)}"
}


###### Route 53 ###########################################################
resource "aws_route53_record" "route53addr" {
   count = "${var.instances}"
   zone_id = "${var.dns_zone_id}"
   name = "${element(aws_instance.ec2.*.tags.Name, count.index)}"
   type = "A"
   ttl = "300"
   records = ["${element(aws_instance.ec2.*.private_ip, count.index)}"]
}
