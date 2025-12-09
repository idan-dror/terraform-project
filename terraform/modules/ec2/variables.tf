variable "name" {
  description = "Name tag for the instance"
  type = string
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type = string
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type = string
}

variable "security_group_ids" {
  description = "Security groups to attach to the instance"
  type = list(string)
  default = []
}

variable "iam_instance_profile" {
  description = "IAM instance profile name (for SSM)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type = string
  default = null
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type = number
  default = 8
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type = string
  default = "gp3"
}


variable "data_volume_id" {
  description = "ID of an additional existing EBS volume to attach"
  type = string
  default = null
}

variable "data_device_name" {
  description = "Device name for the attached volume"
  type = string
  default = null
}
