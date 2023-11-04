output "id" {
  description = "List of IDs of instances"
  value       = ["${aws_instance.this.*.id}"]
}

output "availability_zone" {
  description = "List of availability zones of instances"
  value       = ["${aws_instance.this.*.availability_zone}"]
}

output "key_name" {
  description = "List of key names of instances"
  value       = ["${aws_instance.this.*.key_name}"]
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = ["${aws_instance.this.*.public_dns}"]
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = ["${aws_instance.this.*.public_ip}"]
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = ["${aws_instance.this.*.private_dns}"]
}

output "security_groups" {
  description = "List of associated security groups of instances"
  value       = ["${aws_instance.this.*.security_groups}"]
}

output "subnet_id" {
  description = "List of IDs of VPC subnets of instances"
  value       = ["${aws_instance.this.*.subnet_id}"]
}