resource "aws_route53_zone" "private" {
  name = var.private_domain_name
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  comment = "${var.project_name} private hosted zone"
}

resource "aws_route53_record" "gitlab_private" {
  zone_id = aws_route53_zone.private.zone_id
  name = "git"
  type = "A"
  ttl = 3600
  records = [module.gitlab.instance_private_ip]
}

resource "aws_route53_record" "jenkins_private" {
  zone_id = aws_route53_zone.private.zone_id
  name = "jenkins"
  type = "A"
  ttl = 3600
  records = [module.jenkins_controller.instance_private_ip]
}
