# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
} 

data "aws_vpc_peering_connection" "pc" {
  vpc_id          = aws_vpc.main.id
  peer_cidr_block = data.aws_vpc.default.cidr_block
}

data "aws_route_tables" "main" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

