output "secret_key" {
  value = aws_iam_access_key.this.*.encrypted_secret
}

output "access_key" {
  value = aws_iam_access_key.this.*.id
}

output "this_password" {
  value       = aws_iam_user_login_profile.this.*.encrypted_password
  description = "The encrypted password, base64 encoded"
}

output "this_key_fingerprint" {
  value = aws_iam_user_login_profile.this.*.key_fingerprint
}

output "user_name" {
  value = aws_iam_user.this.name
}