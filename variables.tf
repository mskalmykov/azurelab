variable "azure_region" {
  default = "westeurope"
}

variable "resource_group_name" {
  default = "EPAM_Diploma"
}

variable "DB_PASSWORD" {
  description = "Password for MariaDB admin (get from environment)"
  type        = string
}
