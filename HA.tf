resource "aws_vpc" "Harris" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Harris"
  }
}

resource "aws_internet_gateway" "Harris-igw" {
  vpc_id = aws_vpc.Harris.id

  tags = {
    Name = "Harris-igw"
  }
}

resource "aws_subnet" "Pub-1a" {
  vpc_id     = aws_vpc.Harris.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "Pub-1a"
  }
}
resource "aws_subnet" "Pub-1b" {
  vpc_id     = aws_vpc.Harris.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "Pub-1b"
  }
}

resource "aws_subnet" "Priv-1a" {
  vpc_id     = aws_vpc.Harris.id
  cidr_block = "10.1.3.0/24"

  tags = {
    Name = "Priv-1a"
  }
}

resource "aws_subnet" "Priv-1b" {
  vpc_id     = aws_vpc.Harris.id
  cidr_block = "10.1.4.0/24"

  tags = {
    Name = "Priv-1b"
  }
}

resource "aws_route_table" "Pub-rt" {
  vpc_id = aws_vpc.Harris.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Harris-igw.id
  }

  tags = {
    Name = "Pub-rt"
  }
}

resource "aws_route_table_association" "Pub-rt-1a" {
  subnet_id      = aws_subnet.Pub-1a.id
  route_table_id = aws_route_table.Pub-rt.id
}

resource "aws_route_table_association" "Pub-rt-1b" {
  subnet_id      = aws_subnet.Pub-1b.id
  route_table_id = aws_route_table.Pub-rt.id
}

resource "aws_eip" "eip-1" {
  vpc      = true
}

resource "aws_eip" "eip-2" {
  vpc      = true
}

resource "aws_nat_gateway" "Nat-1" {
  allocation_id = aws_eip.eip-1.id
  subnet_id     = aws_subnet.Priv-1a.id

  tags = {
    Name = "Nat-1"
  }

  depends_on = [aws_internet_gateway.Harris-igw]
}

resource "aws_nat_gateway" "Nat-2" {
  allocation_id = aws_eip.eip-2.id
  subnet_id     = aws_subnet.Priv-1b.id

  tags = {
    Name = "Nat-2"
  }

  depends_on = [aws_internet_gateway.Harris-igw]
}

resource "aws_route_table" "Priv-rt-1" {
  vpc_id = aws_vpc.Harris.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-1.id
  }

  tags = {
    Name = "Priv-rt"
  }
}

resource "aws_route_table" "Priv-rt-2" {
  vpc_id = aws_vpc.Harris.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-2.id
  }

  tags = {
    Name = "Priv-rt-2"
  }
}

resource "aws_route_table_association" "Priv-rt-1a" {
  subnet_id      = aws_subnet.Priv-1a.id
  route_table_id = aws_route_table.Priv-rt-1.id
}

resource "aws_route_table_association" "Priv-rt-1b" {
  subnet_id      = aws_subnet.Priv-1b.id
  route_table_id = aws_route_table.Priv-rt-2.id
}
