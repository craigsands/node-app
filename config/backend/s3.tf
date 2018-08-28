variable "s3_bucket_name" {}

resource "aws_s3_bucket" "state" {
  bucket = "${var.s3_bucket_name}"

  versioning {
    enabled = true
  }
}

output "s3_bucket_name" {
  value = "${aws_s3_bucket.state.bucket}"
}
