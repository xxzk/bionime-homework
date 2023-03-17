variable "region" {
  type        = string
  description = "AWS region"
}

variable "access_key" {
  type        = string
  description = "Access key for AWS"
}

variable "secret_key" {
  type        = string
  description = "Secret key for AWS"
}

variable "ARN_myAmazonEKSNodeRole" {
  type        = string
  description = "EKS managed node Role ARN"
}

variable "ec2_ssh_key" {
  type        = string
  description = "EKS managed node SSH key pair"
}