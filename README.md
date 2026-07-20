# Cloud Architecture

## Part 1 (5 hours)
- Workshop materials
  - [Intro, Architecure, & Terraform](notes/part1/1.1_intro.md)
  - [VPC & Networking](notes/part1/1.2_vpc.md)
  - [IAM](notes/part1/1.3_iam.md)
  - [Provisioning the app](notes/part1/1.4_provisioning.md)
- Preface
  - step-by-step, hands-on creation of AWS resources from scratch
  - a little debugging, best-practices, and trade-off discussions
  - a little terraform magic
  - a few too many ducks 🦆 involved
  - a lot of networking and security

## Part 2
- Prerequisites
  - [ ] Terraform (`terraform version`)
  - [ ] AWS CLI (`aws --version`)
  - [ ] docker (`docker ps`)
- [Workshop materials](notes/part2/)
- 🐣 Beginner-Friendly Track
  - Revisit & reinforce of Part 1
  - Scaling
  - Observability fundamentals
- 🐤 Advanced Track
  - Recap of Part 1
  - Scaling
  - Terraform and modules refactoring
  - Observability fundamentals


---

# Installing Prerequisites

**Terraform**
- macOS (Homebrew): `brew tap hashicorp/tap && brew install hashicorp/tap/terraform`
- Windows (Chocolatey): `choco install terraform`
- Linux (apt, Debian/Ubuntu):
  ```
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```
- Manual (any OS): download the binary from [terraform.io/downloads](https://developer.hashicorp.com/terraform/install) and put it on your `PATH`.
- Verify: `terraform version`

**AWS CLI**
- macOS (Homebrew): `brew install awscli`
- Windows: download and run the [AWS CLI MSI installer](https://awscli.amazonaws.com/AWSCLIV2.msi)
- Linux (x86_64):
  ```
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```
- Verify: `aws --version`
- We will configure credentials with `aws configure` during the workshop

**Docker**
- macOS/Windows: install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Linux (Debian/Ubuntu): follow the [official convenience script](https://docs.docker.com/engine/install/ubuntu/):
  ```
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER   # then log out/in to apply group change
  ```
- Verify: `docker ps` (start Docker Desktop first if on macOS/Windows)
