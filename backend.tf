terraform {
  backend "s3" {
    bucket = "my-unique-bucket-vamsi-1997"
    dynamodb_table = "terraform-state-lock-dynamo"
    key    = "Locking/terraform.tfstate"
    encrypt = true
    region = "us-east-1"
  }
}
