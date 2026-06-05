variable "env" {
  type = string
}

variable "vpc_cird" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "route53_domain"{
  type = string
}