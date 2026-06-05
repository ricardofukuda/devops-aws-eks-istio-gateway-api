data "http" "icanhazip" { # get my current public ip
   url = "http://icanhazip.com"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.cluster_name]
  }
}

data "aws_subnet" "us-east-1d" {
  availability_zone = "us-east-1d"
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

data "aws_subnet" "public-us-east-1d" {
  availability_zone = "us-east-1d"
  vpc_id            = data.aws_vpc.selected.id

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}