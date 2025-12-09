resource "aws_instance" "ec2" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile = var.iam_instance_profile
  user_data = var.user_data
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }
  tags = {
    Name = var.name
  }
}

#Attach an additional data volume if provided 
resource "aws_volume_attachment" "data" {
  count = var.data_volume_id != null ? 1 : 0
  device_name = var.data_device_name
  volume_id = var.data_volume_id
  instance_id = aws_instance.ec2.id
}
