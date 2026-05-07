resource "tls_private_key" "instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "private_key_file" {
  triggers = {
    key_hash = sha256(tls_private_key.instance_key.private_key_openssh)
  }

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${path.module}/.ssh
      cat > ${path.module}/.ssh/id_rsa_instance.pem << 'KEYEOF'
${tls_private_key.instance_key.private_key_openssh}
KEYEOF
      chmod 600 ${path.module}/.ssh/id_rsa_instance.pem
    EOT
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${path.module}/.ssh/id_rsa_instance.pem"
  public_key = tls_private_key.instance_key.public_key_openssh
}

