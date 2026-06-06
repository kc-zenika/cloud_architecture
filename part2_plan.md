# Part 2 (4.5 hours)
## goals
- encapsulate resources with terraform modules
- how to expose traffic in public
- how to scale up when traffic increases
- how to perform basic infra monitoring
## flow
- 30mins - recap
  - go through notes and explain the why again
  - for candidates that didnt attended part 1 too
- 50mins - encapsulating into terraform modules
- 10mins - break
- 60mins - cloudfront
- 60mins - ASG 
- 30mins - cloudwatch


# Materials to prepare
0. recap materials
  - overview of part 1
  - more detailed explainations on some topics that were missed (especially the NACL)
1. terraform modules
  - explain how modules work (inputs, outputs, encapsulation)
  - extract subnets as a module
  - extract app as a module (EC2, ALB, target group)
  - will prepare the rest as examples, can be mixture of modules + raw
  - reprovision everything again
2. exposing public with cloudfront
  - topics
    - edge performance - latency reduction, caching at edge
    - perimeter & origin security
    - a little bit of WAF and shield
    - r53 hosted zone and alias (explain why skip in workshop - needs custom domain)
    - use *.cloudfront.net" for the workshop
  - terraform
    - create a cloudfront dis
    - cloudfront -> ALB (internet)
    - verify `*.cloudfront.net` URL and some nslookup commands
    - switch alb to internal and create vpc-origin
    - cloudfront -> ALB (internal)
3. handling scaling
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
4. cloudwatch
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
- workshop goals, flow and topics ok?
- format
  - 2 rooms (we should try)
    - 1 by fion, 1 by sujie
  - 1 big room outside again
- how to delegate work
- workshop dates


