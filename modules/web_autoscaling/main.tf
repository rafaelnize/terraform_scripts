# Specify the provider and access details
provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
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


#resource "aws_s3_bucket" "b" {
#    bucket = "mgl-${var.project}-elb-log2"
#    acl = "private"
#    tags {
#        Name = "mgl-${var.project}-elb-log2"
#        Environment = "Dev"
#    }
#}

# Create a new load balancer
resource "aws_elb" "elb" {
  name = "${var.project}-elb"

  #access_logs {
  #  bucket = "mgl-retira-loja-elb-log2"
  #  bucket_prefix = "log"
  #  interval = 60
  #}

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

  cross_zone_load_balancing = true
  subnets = ["${split(",",var.subnet_elb_list)}"]
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.elb-sg.*.id}"]
  tags {
    Name = "${var.project}-elb"
  }

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

resource "aws_launch_configuration" "as_conf" {
    name = "${var.project}tf-lc"
    image_id = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.web-server.id}"]
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "bar" {
    name = "${var.project}-tf-asg"
    vpc_zone_identifier = ["${split(",", var.subnet_list)}"]
    max_size = 4
    min_size = 1
    health_check_grace_period = 120
    health_check_type = "ELB"
    desired_capacity = 2
    load_balancers = ["${aws_elb.elb.*.name}"] 
    force_delete = true 
    launch_configuration = "${aws_launch_configuration.as_conf.name}"
    lifecycle {
      create_before_destroy = true
    }

   tag {
     key = "Name"
     value = "${var.project}-tf-asg"
     propagate_at_launch = true
    }

}
