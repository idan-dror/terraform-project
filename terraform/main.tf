module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
}

resource "aws_security_group" "internal_all" {
  name        = "${var.project_name}-internal-vpc-sg"
  description = "Allow all traffic within the VPC"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-internal-vpc-sg"
  }
}

#IAM for SSM
resource "aws_iam_role" "ssm_instance_role" {
  name = "ssm-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_instance_role.name
}


module "jenkins_controller" {
  source               = "./modules/ec2"
  name                 = "${var.project_name}-jenkins-controller"
  ami_id               = "ami-07c054f97256d3b18"
  instance_type        = "t3.small"
  security_group_ids   = [aws_security_group.internal_all.id]
  subnet_id            = module.vpc.private_subnet_ids[0]
  user_data            = file("./user_data/jenkins-controller.sh")
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  #attach existing EBS data volume
  data_volume_id   = var.jenkins_data_volume_id
  data_device_name = var.jenkins_data_device_name

  depends_on = [module.vpc]
}

module "jenkins_agent" {
  source               = "./modules/ec2"
  name                 = "${var.project_name}-jenkins-agent"
  ami_id               = "ami-0f46a4ad64cfb8085"
  instance_type        = "t3.small"
  security_group_ids   = [aws_security_group.internal_all.id]
  subnet_id            = module.vpc.private_subnet_ids[0]
  root_volume_size     = 20
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  depends_on = [module.vpc]
}


module "gitlab" {
  source               = "./modules/ec2"
  name                 = "${var.project_name}-gitlab-server"
  ami_id               = "ami-07c054f97256d3b18"
  instance_type        = "m7i-flex.large"
  security_group_ids   = [aws_security_group.internal_all.id]
  subnet_id            = module.vpc.private_subnet_ids[0]
  user_data            = file("./user_data/gitlab.sh")
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  root_volume_size     = 20
  #attach existing EBS data volume
  data_volume_id   = var.gitlab_data_volume_id
  data_device_name = var.gitlab_data_device_name

  depends_on = [module.vpc]
}


module "eks" {
  project_name       = var.project_name
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
