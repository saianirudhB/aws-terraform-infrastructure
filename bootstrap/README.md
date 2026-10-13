# Remote state bootstrap

This is a standalone Terraform configuration, separate from `modules/` and
`environments/`, whose only job is to create the two resources the remote
backend in `environments/dev` depends on:

- an S3 bucket (versioned, encrypted, public access blocked) to hold
  `terraform.tfstate`
- a DynamoDB table (`LockID` hash key, pay-per-request) for state locking

## Why this is separate

Terraform cannot create the backend it is about to store its own state in -
that's a chicken-and-egg problem. So this config runs with **local** state,
by hand, **once**, before anyone runs `terraform init` in `environments/dev`.
It is not part of the CI pipeline and nothing here is ever touched by a pull
request plan/apply.

## Usage

```bash
cd bootstrap
terraform init
terraform apply
```

Take the `state_bucket_name` and `lock_table_name` outputs and put them into
`environments/dev/backend.hcl` (copy it from `backend.hcl.example` first),
then:

```bash
cd ../environments/dev
cp backend.hcl.example backend.hcl   # edit with the real bucket/table names
terraform init -backend-config=backend.hcl
```

See the root `README.md`'s "Remote state & locking" section for the full
picture.
