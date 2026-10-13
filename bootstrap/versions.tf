terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Deliberately local state. This config creates the S3 bucket and
  # DynamoDB table that environments/dev's remote backend depends on - it
  # cannot also store its own state in them (chicken-and-egg). Run this
  # once, keep the resulting terraform.tfstate somewhere safe (or import it
  # into a separate, already-existing bucket later if you want it remote
  # too), and otherwise treat it as a rarely-touched, one-time setup step.
}
