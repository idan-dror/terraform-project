module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name                       = "${var.project_name}-main-alb"
  load_balancer_type         = "application"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids
  enable_deletion_protection = false

  #security group for ALB:
  security_group_ingress_rules = {
    http_from_anywhere = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "Allow HTTP from any IP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https_from_anywhere = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "Allow HTTPS from any IP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all_egress = {
      ip_protocol = "-1"
      description = "allow outbound to anywhere inside VPC"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  #listeners:
  listeners = {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.acm_certificate_arn

      #default rule if host name don't match
      fixed_response = {
        content_type = "text/plain"
        message_body = "Host not allowed"
        status_code  = "404"
      }

      #host name based rules
      rules = {
        gitlab_host = {
          priority = 10
          actions = [
            {
              forward = {
                target_group_key = "gitlab"
              }
            }
          ]
          conditions = [
            {
              host_header = {
                values = ["git-tf.${var.domain_name}"]
              }
            }
          ]
        }

        jenkins_host = {
          priority = 20
          actions = [
            {
              forward = {
                target_group_key = "jenkins"
              }
            }
          ]
          conditions = [
            {
              host_header = {
                values = ["jenkins-tf.${var.domain_name}"]
              }
            }
          ]
        }
      }
    }

    http = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  #target groups:
  target_groups = {
    gitlab = {
      name_prefix = "git-"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = module.gitlab.instance_id
      vpc_id      = module.vpc.vpc_id

      health_check = {
        enabled  = true
        protocol = "HTTP"
        path     = "/users/sign_in"
        matcher  = "200-399"
      }
    }

    jenkins = {
      name_prefix = "jen-"
      protocol    = "HTTP"
      port        = 8080
      target_type = "instance"
      target_id   = module.jenkins_controller.instance_id
      vpc_id      = module.vpc.vpc_id

      health_check = {
        enabled  = true
        protocol = "HTTP"
        path     = "/login"
        matcher  = "200-399"
      }
    }
  }

  tags = {
    Name = "${var.project_name}-main-alb"
  }
}
