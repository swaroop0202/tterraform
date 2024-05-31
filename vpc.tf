resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames
  
  tags = merge (
    var.common_tags,
    var.vpc_tags,
    {

        Name = "${var.project_name}-${var.Environment}"
    }

  )  
  }

  resource "aws_subnet" "public" {
  availability_zone = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  count = length(var.public_subnet_cidrs)  
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = {
    Name = "${var.project_name}-${slice(data.aws_availability_zones.available.names, 0, 2)[count.index]}"
  }
}

 resource "aws_subnet" "private" {
  availability_zone = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  count = length(var.private_subnet_cidrs)  
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.project_name}-${slice(data.aws_availability_zones.available.names, 0, 2)[count.index]}"
  }
}

 resource "aws_subnet" "database" {
  availability_zone = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  count = length(var.database_subnet_cidrs)  
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = {
    Name = "${var.project_name}-${slice(data.aws_availability_zones.available.names, 0, 2)[count.index]}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.database[*].id
  tags = merge (
    var.common_tags,
    var.db_subnet_group,
    {

        Name = "${var.project_name}-${var.Environment}"
    }

  )
}

resource "aws_eip" "lb" {
   domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
    
  }
  tags = {
    Name = "${var.project_name}-public"
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
   
  }
  tags = {
    Name = "${var.project_name}-private"
  }
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
   
  }
  tags = {
    Name = "${var.project_name}-database"
  }
}



resource "aws_route_table_association" "RR" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "RR1" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "RR2" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

resource "aws_vpc_peering_connection" "pc" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept = var.acceptor_vpc_id == "" ? true : false
  tags = merge (
    var.common_tags,
    var.vpc_peering_tags,
    {

        Name = "${var.project_name}-${var.Environment}"
    }

  ) 
}

resource "aws_route" "r" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc.id
}

resource "aws_route" "r1" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc.id
}

resource "aws_route" "r2" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc.id
}

resource "aws_route" "r3" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = data.aws_route_tables.main.id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc.id
}






