# Specify the provider and access details
provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

resource "aws_security_group" "web-server" {
        name = "${var.project}_auto_web_in"
        description = "Terraform Allow HTTP and SSH inbound traffic"
        vpc_id = "${var.aws_vpc_id}"
        ingress {
           from_port = 22
           to_port = 22
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
           from_port = 80
           to_port = 80
           protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
           from_port = 8000
           to_port = 8000
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
  vpc_security_group_ids = ["${aws_security_group.web-server.*.id}"]
  key_name = "${var.aws_key_name}"
  subnet_id = "${element(split(",", var.subnet_list), count.index)}"
  tags {
    "Name" = "${var.project}-${var.server_prefix}-${format("%02d", count.index+1)}"
    "Notes" = "Created by Terraform"
  }
}

resource "aws_route53_record" "route53addr" {
   count = "${var.instances}"
   zone_id = "${var.dns_zone_id}"
   name = "${element(aws_instance.ec2.*.tags.Name, count.index)}"
   type = "A"
   ttl = "300"
   records = ["${element(aws_instance.ec2.*.private_ip, count.index)}"]
}


resource "aws_security_group" "elb-sg" {
    name = "${var.project}-elb-sg"
    description = "Allow HTTP and SSH inbound traffic"
    vpc_id = "${var.aws_vpc_id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
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


# Create a new load balancer
resource "aws_elb" "elb" {
  name = "${var.project}-elb"

  listener {
    instance_port = 8000
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8000/"
    interval = 30
  }

  instances = ["${aws_instance.ec2.*.id}"]
  cross_zone_load_balancing = true
  subnets = ["${split(",",var.subnet_elb_list)}"]
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.elb-sg.*.id}"]
  tags {
    Name = "${var.project}-elb"
  }



#module "elb_web_pool" {
#   source = "../elb_web_pool/"
#   instances = "${join(",", aws_instance.ec2.*.id)}"
#   subnet_list = "${var.subnet_list}"
#   elb_name = "${var.project}-st-elb"
#}
