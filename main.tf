resource "aws_instance" "ec2" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    tags = {
        Name = "MyEC2Instance "
    } 
}

resource "aws_s3_bucket" "bucket" {
    bucket = "my-unique-bucket-vamsi-1997"
    tags = {
        Name = "MyS3Bucket"
    }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
