variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "helium"
}

variable "env" {
  default = "prod"
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  default = "Z050039512T5DB5GPPHRV"
}

variable "argo_url" {
  default = "argo.oracle.test-helium.com"
}

variable "zone_cert" {
  default = "arn:aws:acm:us-east-1:848739503602:certificate/c9616061-04ef-48a3-91fa-0fc62fcab6df"
}

variable "domain_filter" {
  description = "External-dns Domain filter."
  type       = string
  default = "oracle.test-helium.com"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}