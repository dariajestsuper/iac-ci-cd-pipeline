provider "aws" {
  alias                       = "localstack"
  region                      = "eu-north-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}