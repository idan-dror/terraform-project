#IAM for EKS cluster:
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


#IAM for EKS Node group:
data "aws_iam_policy_document" "eks_nodegroup_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name               = "${var.cluster_name}-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodegroup_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#EKS cluster:
resource "aws_eks_cluster" "cluster" {
  name = "${var.project_name}-${var.cluster_name}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = var.cluster_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "coredns"
}


#EKS Node GROUP:
resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "${aws_eks_cluster.cluster.name}-node-group"
  node_role_arn = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = [var.node_instance_type]

  tags = {
    Name = "${aws_eks_cluster.cluster.name}-node-group"
  }

  depends_on = [
    aws_eks_cluster.cluster
  ]
}