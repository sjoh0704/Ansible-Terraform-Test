data "template_file" "inventory" {
  template = file("./templates/inventory.tpl")

  vars = {
    public_ip_address_ec2 = join("\n", formatlist("%s ansible_host=%s",aws_instance.public-ec2-server.*.public_dns ,aws_instance.public-ec2-server.*.public_ip))
  }
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${var.inventory_file}"
  }

  triggers = {
    template = data.template_file.inventory.rendered
  }
}
