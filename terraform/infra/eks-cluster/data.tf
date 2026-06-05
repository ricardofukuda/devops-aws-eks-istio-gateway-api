data "http" "icanhazip" { # get my current public ip
   url = "http://icanhazip.com"
}

data "aws_subnet" "us-east-1d" {
  availability_zone = "us-east-1d"
  vpc_id = module.vpc.vpc_id

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }

  depends_on = [ module.vpc ]
}

data "aws_subnet" "public-us-east-1d" {
  availability_zone = "us-east-1d"
  vpc_id            = module.vpc.vpc_id

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }

  depends_on = [module.vpc]
}