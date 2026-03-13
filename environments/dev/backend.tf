terraform {
  required_version = ">= 1.14.3"

  backend "s3" {
    bucket  = "terraform-state-bucket-week4"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"

    # NEW: Enables native S3 locking without DynamoDB
    use_lockfile = true

    # Encrypt state file
    encrypt = true
  }
}