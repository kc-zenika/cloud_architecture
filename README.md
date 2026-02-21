# Cloud Architecture

## Part 1 (5 hours)
### Intro (15 mins)
- mainly on AWS
- Goal: to create a set of maintainable/evolvable infra
  - day to day tasks of a platform engineer
  - a set of AWS resources to a public app
  - some system design challenges
### Tooling (60 mins)
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
### VPC (90 mins)
- use the module to create a VPC
- subnet segmentations best practices
- create internet/nat gateways
- security groups vs NACLs
### Basic app + design discussions (120 mins - to the end)
- thinking ECS would be more applicable
  - as most of the time its containers
- provision IAM role for execution
- provision ECS in private subnets
- provision ALB in public subnet to expose app
- Topics/Discussions
  - IAM, ECS and ALB discussions
  - server and serverless
  - scaling in theory (or maybe we can show it here)
  - what else is missing before we can go to prod? (For part 2 and 3)
- if theres more time
  - R53 and Cloudfront? - show some diagrams/homework

## Part 2
- Reprovision everything in part 1
- Topic 1: database
  - deploy an aurora in private DB subnet
- Topic 2: secrets management
  - connect to database from the app
  - updates to IAM auth and networking to make it work 
- Topic 3: Reliability
  - talk about multiaz availablility, scaling/replicas
  - healthchecks
  - backups / DR
- Topic 4: logging/monitoring
  - LGTM - logs, traces, metrics
  - some Cloudwatch alarms

## Part 3 (Need to discuss more)
- Topic 1: WAF 
- Topic 2: Security eco-system
  - configs, inspector, security hub, guard duty, cloudtrail
- Topic 3: Logs for audit, some compliance sharing?
- Topic 4: Cost awareness?
- Something todo with CD?