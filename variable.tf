variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"

}

variable "enable_dns_hostnames" {
    type = bool
    default = "true"
}

variable "project_name" {
    type = string

}

variable "Environment"{
    type = string
    default = "Dev"
}
    
variable "common_tags"{
    type = map
    

}

variable "vpc_tags"{
    type = map
    default = {}

}

variable "public_subnet_cidrs"{
    type = list
    default = []
}

variable "private_subnet_cidrs"{
    type = list
    default = []
}

variable "database_subnet_cidrs"{
    type = list
    default = []
}

variable "db_subnet_group" {
    type = map
    default = {}
}



variable "is_peering_required" {
    type = bool
    default = "false"

}

variable "acceptor_vpc_id" {
    type = string
    default = ""

}

variable "vpc_peering_tags" {
    type = map
    default = {}
}




