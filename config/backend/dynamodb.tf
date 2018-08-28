variable "lock_table_name" {}

resource "aws_dynamodb_table" "main" {
  "attribute" {
    name = "LockID"
    type = "S"
  }

  hash_key       = "LockID"
  name           = "${var.lock_table_name}"
  read_capacity  = 5
  write_capacity = 5
}

output "lock_table_name" {
  value = "${aws_dynamodb_table.main.name}"
}
