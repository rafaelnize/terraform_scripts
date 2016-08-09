
resource "aws_security_group" "elb-sg" {
    name = "${var.elb_name}-elb-sg"
    description = "Allow HTTP and SSH inbound traffic"
    vpc_id = "${var.vpc_id}"
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
  name = "${var.elb_name}"
 
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

  instances = ["${split(",",var.instances)}"]
  cross_zone_load_balancing = true
  subnets = ["${split(",",var.subnet_list)}"]
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.elb-sg.*.id}"]
  tags {
    Name = "terraform-elb"
  }
}
