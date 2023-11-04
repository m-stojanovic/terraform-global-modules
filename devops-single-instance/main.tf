resource "aws_security_group" "this" {
  name        = "${var.hostname}-sg"
  description = "Security group for ${var.hostname} EC2 instance."
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "allow internal access"
    cidr_blocks = var.full_access_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "allow external access to everywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.hostname}-sg" }), var.tags)

}

resource "aws_route53_record" "this" {
  count   = var.instance_count
  zone_id = var.private_zone_id
  name    = "${var.hostname}-${format("%02d", count.index + 1)}"
  type    = "A"
  ttl     = "5"
  records = ["${element("${aws_instance.this.*.private_ip}", count.index)}"]
}

resource "aws_instance" "this" {
  count                       = var.instance_count
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  monitoring                  = true
  associate_public_ip_address = true
  source_dest_check           = false
  tags                        = merge(tomap({ "Name" = "${var.hostname}-${format("%02d", count.index + 1)}" }), var.tags)

  provisioner "remote-exec" {
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.env_pem)
    }
    inline = [
      # Set hostname of instance
      "sudo sed -i '/HOSTNAME/s/localhost/${var.hostname}-${format("%02d", count.index + 1)}/' /etc/sysconfig/network",

      "sudo service network restart",
      "sudo hostname ${var.hostname}-${format("%02d", count.index + 1)}",

      # Add puppet master to hosts file
      "/bin/echo '10.249.96.60    hub-auto-puppetmaster.eu-west-1.compute.internal' | sudo tee /etc/hosts",

      # boostrap
      "sudo yum install -y http://release-archives.puppet.com/yum/el/6/PC1/x86_64/puppetlabs-release-pc1-1.1.0-5.el6.noarch.rpm| true",
      "sudo sed -i -e 's/yum.puppetlabs.com/release-archives.puppet.com\\/yum/g' /etc/yum.repos.d/puppetlabs-pc1.repo",
      "sudo yum install -y puppet | true",
      "echo '10.249.96.60    hub-auto-puppetmaster.eu-west-1.compute.internal' | sudo tee -a /etc/hosts",
      "echo '[main]' | sudo tee /etc/puppetlabs/puppet/puppet.conf",
      "echo 'environment = ${var.environment}' | sudo tee -a /etc/puppetlabs/puppet/puppet.conf",
      "echo 'server = hub-auto-puppetmaster.eu-west-1.compute.internal' | sudo tee -a /etc/puppetlabs/puppet/puppet.conf",
    ]
  }
}