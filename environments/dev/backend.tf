# ---------------------------------------------------------------------------
# Remote state: S3 + DynamoDB locking.
#
# Terraform backend blocks cannot reference input variables, locals, or any
# other interpolation - the values here are intentionally a *partial*
# configuration (only `encrypt` is literal). Supply the real
# bucket/key/region/dynamodb_table at `terraform init` time via a backend
# config file, which is environment/account-specific and therefore NOT
# committed to version control:
#
#   cp backend.hcl.example backend.hcl   # then edit the real values in
#   terraform init -backend-config=backend.hcl
#
# Bootstrapping problem: the S3 bucket and DynamoDB table referenced by this
# backend block are NOT created by this configuration - Terraform cannot
# safely create the very backend it is about to store its own state in (a
# chicken-and-egg problem). They are created exactly ONCE, out-of-band,
# before the first `terraform init` here, by applying the standalone
# bootstrap config:
#
#   cd ../../bootstrap
#   terraform init
#   terraform apply
#
# See ../../bootstrap/README.md and the root README's "Remote state &
# locking" section for full details.
# ---------------------------------------------------------------------------
terraform {
  backend "s3" {
    encrypt = true

    # bucket         = set via backend.hcl -backend-config
    # key            = set via backend.hcl -backend-config
    # region         = set via backend.hcl -backend-config
    # dynamodb_table = set via backend.hcl -backend-config
  }
}
