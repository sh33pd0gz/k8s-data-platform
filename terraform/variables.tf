variable "colima_profile" {
  type        = string
  default     = "colima-dev"
  description = "Target `profile` name to prevent overriding the default Colima setup."
}

variable "cpu_cores" {
  type    = number
  default = 6
}

variable "memory_gb" {
  type    = number
  default = 16
}

variable "disk_gb" {
  type    = number
  default = 50
}
