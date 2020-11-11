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

variable "node_exporter_port" {
  description = "Node Exporter Port"
  type = string
  default = "9100"
}

variable "zone_id" {
  description = "Server Zone ID"
  type = string
  default = "4da1b188-dcd6-4ff5-b7fd-bde984055548"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
  type = string
}
