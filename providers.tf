provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      CreatedBy   = "Aasrith"
      Environment = "Dev"
      Project     = "Week 4"
      Purpose     = "Training Plan"
    }
  }
}