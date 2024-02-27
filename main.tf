resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = var.project_name
    }
  )
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = var.project_name
    }
  )
}
# public subnet
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  map_public_ip_on_launch = true 
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-${local.azs[count.index]}"
    }

  )
}
# private subnet
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-${local.azs[count.index]}"
    }
  )
}
# database-subnet
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database-${local.azs[count.index]}"
    }
  )
}

#public_route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.common_tags,
     {
      Name = "${var.project_name}-public"
    }
  )
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.public]
}

resource "aws_eip" "eip" {  
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
     {
      Name = var.project_name
    },
    var.nat_gateway_tags   
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#private_route_table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private"
    }
  )
}


#database_route_table

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database"
    }
  )
}

#assosciate  public subnets with public route
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr) # length function is used to get the number of elements in a list or map.
  subnet_id      = element(aws_subnet.public[*].id, count.index) # element function is used to select a single element from a list or map. It allows you to access a specific element based on its index or key.
  route_table_id = aws_route_table.public.id
}

#assosciate  private subnets with private route
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

#assosciate  database subnets with database route table
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidr)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

# resource "aws_db_subnet_group" "roboshop" {
#   name       = var.project_name
#   subnet_ids = aws_subnet.database[*].id

#   tags = merge(
#     var.common_tags,
#     var.db_subnet_group_tags
#   )
# }
