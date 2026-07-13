variable "name" {
  description = "Base name for the launch template, ASG, and its tags"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to attach to instances"
  type        = string
}

variable "security_group_ids" {
  description = "Security group ids attached to the launch template"
  type        = list(string)
}

variable "user_data" {
  description = "Base64-encoded user data, rendered by the caller"
  type        = string
}

variable "tags" {
  description = "Common tags merged onto module resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnet ids for the ASG's vpc_zone_identifier"
  type        = list(string)
}

variable "target_group_arns" {
  description = "ALB target group ARNs the ASG registers instances with"
  type        = list(string)
}

variable "min_size" {
  description = "ASG minimum size"
  type        = number
}

variable "max_size" {
  description = "ASG maximum size"
  type        = number

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size must be >= min_size."
  }
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number

  validation {
    condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
    error_message = "desired_capacity must be between min_size and max_size."
  }
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for target tracking scaling"
  type        = number
  default     = 50
}
