resource "tls_private_key" "instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content = tls_private_key.instance_key.private_key_pem
  filename = "${path.module}/.ssh/id_rsa_instance.pem"
  file_permission = "0400"
}

resource "local_file" "public_key" {
  content = tls_private_key.instance_key.public_key_pem
  filename = "${path.module}/.ssh/id_rsa_instance_pub.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name = "${path.module}/.ssh/id_rsa_instance.pem"
  public_key = tls_private_key.instance_key.public_key_openssh
}

