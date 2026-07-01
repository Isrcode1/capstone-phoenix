resource "aws_instance" "master" {
  count         = var.master_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-master-${count.index}"
    Role = "master"
  }
}

resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-worker-${count.index}"
    Role = "worker"
  }
}
