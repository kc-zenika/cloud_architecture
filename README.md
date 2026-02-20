# Cloud Architecture

## TODOs
- [ ] Go through part 1/2/3
- [ ] AWS accounts
  - check with piere do we have some form of sandbox accound/workshop studio/ cloud guru
- [ ] Align on dates + Send out invites

## Part 1 (5 hours)
### Intro
- mainly on AWS
- Goal: to create a set of maintainable/evolvable infra
  - day to day tasks of a platform engineer
  - a set of AWS resources to a public app
  - some system design challenges
### Tooling
- `.aws/config` and aws vault
  - authenticate to sandbox aws account
  - talk about multi account
- IAC and terragrunt
  - asdf - with `.tool_versions`
  - idempotency and drift
  - module boundaries, dependency graph etc
- setup terragrunt backend on s3
  - create workspace
  - introduce modules
### VPC
- use the module to create a VPC
- subnet segmentations best practices
- create internet/nat gateways
- security groups vs NACLs
### Basic apps
- we can do native EC2, but thinking ECS would be more applicable
  - EC2 would be more native
  - ECS 
- provision IAM role for execution
- provision ECS in private subnets
- provision ALB/Cloudfront to expose app
- Topics
  - server and serverless
  - scaling in theory (or maybe we can show it here)


## Part 2
- Reprovision everything in part 1
- Topic 1: database
  - use aurora 
  - talk about availablility, replicas, backups
  - deploy in private DB subnet
- Topic 2: secrets management
  - connect to database from the app
  - IAM auth
  - networking
- Topic 3: Cloudwatch
  - some alarms

## Part 3
- Topic 1: WAF
- Topic 2: Security eco-system
  - configs, inspector, security hub, guard duty, cloudtrail
- Topic 3: Logs for audit, some compliance sharing
- Topic 4:Cost awareness
