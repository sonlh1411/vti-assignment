terraform {
  backend "s3" {
    bucket = "sonlh-tfstate"
    key    = "tfstate"
    region = "us-east-1"
  }
}
