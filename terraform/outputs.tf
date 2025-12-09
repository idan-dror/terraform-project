output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}


output "jenkins_controller_instance_id" {
  value = module.jenkins_controller.instance_id
}

output "jenkins_controller_private_ip" {
  value = module.jenkins_controller.instance_private_ip
}


output "gitlab_instance_id" {
  value = module.gitlab.instance_id
}

output "gitlab_private_ip" {
  value = module.gitlab.instance_private_ip
}


output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
