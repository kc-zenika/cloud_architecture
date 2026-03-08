# Cloud Architecture

## Part 1 (5 hours)
### Intro (45 mins)
- mainly on AWS
- Goal: to create a set of maintainable/evolvable infra
  - day to day tasks of a platform engineer
  - a set of AWS resources to a public app
  - some system design challenges
- define what we are going to do
- perpare an environment thats fully ready
  - Permissions - RBAC and IBAC
  - show traffic flow diagram ingress (igw -> public subnet -> public ip -> private -> EC2)
  - ec2 app
- participants to follow along with instructions in notes
  - mainly steps/links
  - working-example is the answer incase they cant follow 
### Handson Tooling (30 mins)
- `.aws/config`
  - authenticate to sandbox aws account
  - talk about multi account
- basic terraform and IAC
  - simple terraform create a file with `local_file` to show its not just for AWS
  - some buffer time to get everyone installed correctly
  - what is a provider and backend, etc
- setup backend on s3 + dynamodb
### Handson VPC (60 mins)
- create a VPC
- subnet segmentations best practices (2 public, 2 private for now)
- security groups vs NACLs
### Handson Basic app + design discussions (120 mins - to the end)
- TODO
  - need some planned gotchas where participants can troubleshoot
- provision IAM role for execution role/instance profile
- provision an EC2 in private subnet
  - Just use AL2023 first, but show selection
    - TODO concept of cattle not pets? Immutable infra
    - talk about decisions on selecting this
    - what you do in prod (golden AMI)
  - selection of instance types (some ballparks)
  - storage size (encryption)
  - prep user data, bootstraping script
    - just runs nginx with a simple index.html
  - show that it cant install packages
    - create the NAT/igw to fix the bootstraping step
- Access using session manager
  - show it can only be accessed in private subnet
  - show metadata `curl 169.254.169.254/latest/meta-data`
  - show how its insecure to put keys in userdata cause its exposed in metadata
- provision EIP in public subnet to expose app
  - should be able to hit the index.html now
### Ending Topics/Discussions
- what else is missing before we can go to prod? (For part 2 and 3)
- if theres more time
  - ASG and show some scaling?
  - R53 and Cloudfront? - show some diagrams/homework


## Part 2 (DRAFT)
- Reprovision everything in part 1
- introduce modules in terraform
  - IAC modules, state segregation
- potential topics
  - asg - multiaz availablility, scaling/replicas
  - alb/nlb
  - efs/ebs
  - s3 - KMS/bucket key
  - waf, network firewall
  - cloudfront - cache
  - params and secret
  - cloudwatch - LGTM - logs, traces, metrics
  - R53
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
  - configure app to push to cloudwatch
  - some Cloudwatch alarms

## Part 3 (DRAFT)
- Topic 1: WAF 
- Topic 2: Security eco-system
  - configs, inspector, security hub, guard duty, cloudtrail
- Topic 4: Cost awareness?
- Something todo with CD?