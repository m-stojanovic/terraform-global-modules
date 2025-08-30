output "key_pair_name" {
  value = aws_key_pair.this.key_name
}

output "private_ip" {
  value = aws_eip.this.private_ip
}

output "public_ip" {
  value = aws_eip.this.public_ip
}