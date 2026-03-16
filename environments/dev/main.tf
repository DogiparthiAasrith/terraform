module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
}

module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name     = var.project_name
  environment      = var.environment
  private_subnets  = module.vpc.private_subnets
  target_group_arn = module.alb.target_group_arn
  vpc_id           = module.vpc.vpc_id
  alb_sg_id        = module.alb.alb_sg_id
  vpc_cidr         = module.vpc.vpc_cidr
}