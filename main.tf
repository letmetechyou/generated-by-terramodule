```terraform
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      Name = var.name
    },
  )
}

resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0
  
  tags = merge(
    var.tags,
    var.igw_tags,
    {
      Name = "${var.name}-igw"
    },
  )
}

resource "aws_internet_gateway_attachment" "this" {
  count = var.create_igw ? 1 : 0
  
  internet_gateway_id = aws_internet_gateway.this[0].id
  vpc_id              = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  
  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      Name = "${var.name}-public-${element(var.azs, count.index)}"
    },
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  
  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      Name = "${var.name}-private-${element(var.azs, count.index)}"
    },
  )
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    var.public_route_table_tags,
    {
      Name = "${var.name}-public"
    },
  )
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      Name = "${var.name}-private-${element(var.azs, count.index)}"
    },
  )
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_igw && length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```