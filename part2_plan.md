# Part 2 (4.5 hours)
## goals
- how to be more resilient and secure when traffic increases
- how to perform basic infra monitoring
- (advance) encapsulate resources with terraform modules

## Newbie track
- reinforce purely cloud only
- revisit part 1 + more examples
- less terraform, execute too, but no modules, just hand out
- cloudwatch
## Advance track
- 30mins - recap
  - go through notes and explain the why again
  - for candidates that didnt attended part 1 too
  - more network
- ASG/EC2 + alb/nlb
  - S3/EBS/EFS + KMS
- 50mins - encapsulating into terraform modules
- 10mins - break 
- 60mins - cloudwatch
  - sprinkle IAM policies to log to cloudwatch
  - IBAC and RBAC



# Part 3/4
- ecs 
- cross account role - can work together
- databse - backups, logss
- CF - s3 and vpc_orgin
- WAF
- s3 static file



# Materials to prepare
1. recap materials (Fion + Dax)
  - overview of part 1
  - more detailed explainations on some topics that were missed (especially the NaCl)
2. handling scaling (Sujie)
  - topics
    - HA (multi-AZ failover) vs performance scaling ( capacity under load)
    - self healing (how ASG detects and replaces unhealthy instances) - healthcheck
    - when and how to scale up/down
    - cooldown/warmup period (prevent thrashing; callbacks to user_data.sh)
    - connection draining/deregistration delay (graceful shutdown)
  - terraform
    - create launch template (replaces launch config)
    - create ASG
    - point ALB to ASG
    - setup scaling policies and targets
    - demo: terminate one instance manually → watch self-healing
3. terraform modules (kc)
  - explain how modules work (inputs, outputs, encapsulation)
  - extract subnets as a module
  - extract app as a module (EC2, ALB, target group)
  - will prepare the rest as examples, can be mixture of modules + raw
  - reprovision everything again
4. cloudwatch (kc)
  - topics
    - LGTM - logs, traces, metrics 
      - traces not covered in workshop
    - app monitoring
      - LETS - latency, error rates, traffic, saturation
    - infra monitoring
      - USE - utilization, saturation, errors
  - terraform/console
    - ec2 metrics - metrics explorer, 1 dashboard?
    - alarms (should we try forwarding a slack as demo?)
    - pipe Cloudfront/ALB access logs, and using log insights


# To discuss
- format
  - big room outside (advance)
  - meeting room (newbie)
- how to delegate work
- workshop dates (24 july) 


