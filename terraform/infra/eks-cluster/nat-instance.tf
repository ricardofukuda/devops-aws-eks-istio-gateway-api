module "nat-instance" {
  source = "../../modules/nat-instance"

  name                        = local.cluster_name
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = data.aws_subnet.public-us-east-1d.id
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  use_spot_instance           = false

  depends_on = [module.vpc]
}
