variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
}

variable "project_name" {
  description = "Prefix for naming resources"
  type        = string
}

variable "jenkins_data_volume_id" {
  description = "Existing EBS volume ID for Jenkins data"
  type        = string
}

variable "jenkins_data_device_name" {
  description = "Name of Existing EBS volume for Jenkins data"
  type        = string
}

variable "gitlab_data_volume_id" {
  description = "Existing EBS volume ID for GitLab data"
  type        = string
}

variable "gitlab_data_device_name" {
  description = "Name of Existing EBS volume for gitlab data"
  type        = string
}

variable "acm_certificate_arn" {
  description = "AWS ACM certificate for main ALB load balancer"
  type        = string
}

#cloudflare:
variable "cloudflare_api_token" {
  description = "API token for cloudflare provider"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "ID of the zone of the domain in cloudflare"
  type        = string
}

variable "domain_name" {
  description = "Domain name for ALB from cloudflare"
  type        = string
}

#route53 private zone:
variable "private_domain_name" {
  description = "Private DNS domain for internal records in route53 private zone"
  type        = string
  default     = "tf.internal"
}



