data "aws_ami" "node_app" {
  most_recent = true

  filter {
    name   = "name"
    values = ["node-app-*"]
  }
}
