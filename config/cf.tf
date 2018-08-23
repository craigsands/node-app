resource "aws_cloudformation_stack" "node_app" {
  # https://www.terraform.io/docs/providers/aws/r/cloudformation_stack.html
  name          = "node-app-asg"
  template_body = <<EOF
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Cloudformation node-app-template",
  "Resources": {
    "MyAsg": {
      "Type": "AWS::AutoScaling::AutoScalingGroup",
      "Properties": {
        "AvailabilityZones": ${jsonencode(data.aws_availability_zones.available.names)},
        "Cooldown": "30",
        "LaunchConfigurationName": "${aws_launch_configuration.node_app.name}",
        "MaxSize": "2",
        "MinSize": "1",
        "LoadBalancerNames": ["${aws_elb.http_3000.name}"],
        "TerminationPolicies": ["OldestLaunchConfiguration", "OldestInstance"],
        "HealthCheckType": "ELB",
        "HealthCheckGracePeriod": "600"
      },
      "UpdatePolicy": {
        "AutoScalingRollingUpdate": {
          "MinInstancesInService": "1",
          "MaxBatchSize": "2",
          "PauseTime": "PT5M"
        }
      }
    }
  },
  "Outputs": {
    "AsgName": {
      "Description": "The name of the auto scaling group",
      "Value": {"Ref": "MyAsg"}
    }
  }
}
EOF

  timeouts {
    create = "5m"
  }
}

resource "aws_autoscaling_policy" "node_app" {
  # https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
  name                   = "node-app-as-policy"
  autoscaling_group_name = "${aws_cloudformation_stack.node_app.outputs["AsgName"]}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "30"
  scaling_adjustment     = 1

  lifecycle {
    create_before_destroy = true
  }
}
