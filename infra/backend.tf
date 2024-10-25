terraform {
  backend "s3" {
    bucket = "sonlh-tf-backend"
    key    = "tfstate"
    region = "us-east-2"
  }
}
