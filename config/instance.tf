resource "aws_instance" "node_app" {
  ami = "${data.aws_ami.node_app.id}"
  instance_type = "t2.small"
  security_groups = ["${aws_security_group.node_app.id}"]
}