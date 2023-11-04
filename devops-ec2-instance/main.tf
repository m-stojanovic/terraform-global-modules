resource "aws_instance" "this" {
  count = var.instance_count

  ami                                  = var.ami
  instance_type                        = var.instance_type
  user_data                            = var.user_data
  subnet_id                            = var.subnet_id[count.index]
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  vpc_security_group_ids               = var.vpc_security_group_ids
  iam_instance_profile                 = var.aws_iam_instance_profile_name
  associate_public_ip_address          = var.associate_public_ip_address
  private_ip                           = var.private_ip
  ipv6_addresses                       = var.ipv6_addresses
  ebs_optimized                        = var.ebs_optimized
  source_dest_check                    = var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy
  volume_tags                          = var.tags

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  credit_specification {
    cpu_credits = var.credit_specification
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%02d", var.name, count.index + 1)
    }
  )

  lifecycle {
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments
    ignore_changes = [
      private_ip,
      security_groups,
      ebs_block_device,
      subnet_id,
    ]
  }

  provisioner "remote-exec" {
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.env_pem)
    }
    inline = [
      "sudo sed -i '/HOSTNAME/s/localhost/${var.name}-${format("%02d", count.index + 1)}/' /etc/sysconfig/network",
      "sudo service network restart",
      "sudo hostname ${var.name}-${format("%02d", count.index + 1)}",
      "sudo hostnamectl set-hostname  ${var.name}-${format("%02d", count.index + 1)}",
      "/bin/echo '10.249.96.60    hub-auto-puppetmaster.eu-west-1.compute.internal' | sudo tee /etc/hosts",
      "sudo yum install -y http://release-archives.puppet.com/yum/el/6/PC1/x86_64/puppetlabs-release-pc1-1.1.0-5.el6.noarch.rpm| true",
      "sudo sed -i -e 's/yum.puppetlabs.com/release-archives.puppet.com\\/yum/g' /etc/yum.repos.d/puppetlabs-pc1.repo",
      "sudo yum install -y puppet | true",
      "echo '10.249.96.60    hub-auto-puppetmaster.eu-west-1.compute.internal' | sudo tee -a /etc/hosts",
      "echo '[main]' | sudo tee /etc/puppetlabs/puppet/puppet.conf",
      "echo 'environment = ${local.environment_without_suffix}' | sudo tee -a /etc/puppetlabs/puppet/puppet.conf",
      "echo 'server = hub-auto-puppetmaster.eu-west-1.compute.internal' | sudo tee -a /etc/puppetlabs/puppet/puppet.conf",
    ]
  }
}
