#!/bin/bash
# Default user_data for modules/ec2: installs and starts Docker on
# Amazon Linux 2023. Overridable via the user_data variable.
set -euxo pipefail

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

# Allow the default ec2-user to run docker without sudo.
usermod -aG docker ec2-user

docker --version
