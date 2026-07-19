
This is my rough idea/guideline on how to deliver the Part 1 recap presentation.

slide 1 - Introduce recap topic, explain this is to lock in networking and security fundamentals before moving into infra scaling.

slide 2 - Use office building analogy to warm up memory, but remind learners real AWS terms are the final source of truth.

slide 3 - Explain core network path: VPC, public/private subnets, route tables, IGW, NAT, and why VPC endpoints reduce internet dependency.

slide 4 - Explain why we need both NACL and Security Group, focus on stateless vs stateful and subnet boundary vs workload intent.

slide 5 - Flow 1 request and response walkthrough (User -> ALB -> EC2 -> User).
- Pause when rule highlight appears.
- Call out ports/rules clearly:
  - `nacl-public` inbound Rule 110 (TCP 443)
  - `nacl-private` inbound Rule 110 (TCP 443)
  - `nacl-private` outbound Rule 120 (TCP 1024-65535)
  - `nacl-public` outbound Rule 120 (TCP 1024-65535)

slide 6 - Flow 2 outbound and return walkthrough (EC2 -> NAT -> Internet -> EC2).
- Pause when rule highlight appears.
- Call out ports/rules clearly:
  - `nacl-private` outbound Rule 110 (TCP 443)
  - `nacl-public` outbound Rule 110 (TCP 443)
  - `nacl-public` inbound Rule 120 (TCP 1024-65535)
  - `nacl-private` inbound Rule 120 (TCP 1024-65535)
- Emphasize why source can be `0.0.0.0/0` on return traffic at NACL level.

slide 7 - Run interactive checks: RDS placement and NAT failure scenario, ask learners to reason before revealing answers.

slide 8 - IAM recap, do policy then role then instance profile.
- Add simple definitions:
  - identity = user/role that can be authenticated
  - principal = the actor referenced in policy logic

slide 9 - EC2 recap, split into config path and debug path.
- Config path: AMI -> role -> user data -> service start.
- Debug path: systemctl -> localhost curl -> logs -> IMDS/role checks.

slide 10 - Terraform recap, show init/plan/apply/destroy and remind state is shared in S3 backend.

slide 11 - Final self-check, ask learners to explain both packet flows and justify each security control without notes.

Quick presenter reminders
- Keep repeating: request path uses 443, return path often uses ephemeral ports.
- When a rule row highlights, pause 2-3 seconds and read the rule aloud.
- If learners ask why a rule is needed, answer using packet direction + stateless NACL behavior.
