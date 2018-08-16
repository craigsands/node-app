resource "aws_autoscaling_group" "node_app" {
  name                 = "node-app-asg"
  launch_configuration = "${aws_launch_configuration.node_app.name}"
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
  min_size             = 1
  max_size             = 2

  load_balancers = ["${aws_elb.http_3000.id}"]
  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}
