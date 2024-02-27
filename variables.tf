variable "cidr_block" {
  # default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}

variable "common_tags" {
  type    = map(any)
  default = {}

}
variable "project_name" {
  
}

variable "vpc_tags" {
  type    = map(any)
  default = {}
}

variable "igw_tags" {
  default = {}
}

# public-subnet-variables
variable "public_subnet_cidr" {
    type = list 
    validation {
        condition = length(var.public_subnet_cidr) == 2
        error_message = "please provide 2 public subnet cidr"
    }
}
# variable "azs" {
# }
# variable "public_subnet_names" {
# }

# private-subnet-variables
variable "private_subnet_cidr" {
    type = list 
    validation {
        condition = length(var.private_subnet_cidr) == 2
        error_message = "please provide 2 private subnet cidr"
    }
}
# variable "private_subnet_names" {
# }

# database-subnet-variables
variable "database_subnet_cidr" {
   type = list 
    validation {
        condition = length(var.database_subnet_cidr) == 2
        error_message = "please provide 2 database subnet cidr"
    }
}

variable "nat_gateway_tags" {
  default = {}
}
variable "public_route_table_tags" {
  default = {}
}
variable "private_route_table_tags" {
  default = {}
}
variable "database_route_table_tags" {
  default = {}
}
# variable "db_subnet_group_tags" {
#   default = {}
# }