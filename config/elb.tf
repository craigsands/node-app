resource "aws_elb" "http_3000" {
  name = "node-app-elb-http-3000"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = 3000
    instance_protocol = "http"
    lb_port = 3000
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:3000/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "node-app-elb-http-3000"
  }
}
