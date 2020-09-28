variable "exoscale_key" {
  description = "Exoscale Key"
  type = string
}

variable "exoscale_secret" {
  description = "Exoscale Secret"
  type = string
}

variable "zone" {
  description = "Server Zone"
  type = string
  default = "at-vie-1"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
  type = string
}
