variable "proxmox_api_url" {
  type        = string
  description = "The API URL for your Proxmox VE"
}

variable "proxmox_username" {
  type        = string
  description = "The username for Proxmox API authentication"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "The password or API token secret for the Proxmox user"
}

variable "vm_id" {
  type        = number
  default     = 3467
  description = "The specific VM ID to assign to the Security Onion instance"
}