resource "aws_launch_configuration" "node_app" {
  image_id      = "${data.aws_ami.node_app.id}"
  instance_type = "t2.small"
  security_groups = ["${aws_security_group.node_app.id}"]

  lifecycle {
    create_before_destroy = true
  }
}
