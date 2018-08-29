resource "aws_launch_configuration" "node_app" {
  image_id        = "${data.aws_ami.node_app.id}"
  instance_type   = "t2.small"
  #key_name        = "node-app-key"
  security_groups = ["${aws_security_group.node_app.id}"]

  user_data = <<EOF
#!/bin/bash
cd /usr/local/node-app
pm2 start ./bin/www --name='app'
EOF

  lifecycle {
    create_before_destroy = true
  }
}
