resource "cloudflare_dns_record" "gitlab" {
  zone_id = var.cloudflare_zone_id
  name    = "git-tf"
  type    = "CNAME"
  content = module.alb.dns_name
  proxied = false
  ttl     = 1 #auto ttl
}

resource "cloudflare_dns_record" "jenkins" {
  zone_id = var.cloudflare_zone_id
  name    = "jenkins-tf"
  type    = "CNAME"
  content = module.alb.dns_name
  proxied = false
  ttl     = 1 #auto ttl
}
