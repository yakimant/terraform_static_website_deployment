resource "terraform_data" "file_provisioner" {
  triggers_replace = timestamp()

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = var.website_public_ip
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${var.website_root}/"
    destination = "/usr/share/nginx/html"
  }
}