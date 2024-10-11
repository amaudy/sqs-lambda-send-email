output "public_ip" {
  description = "The public IP address of the Mailhog instance"
  value       = aws_instance.mailhog.public_ip
}

output "smtp_endpoint" {
  description = "The SMTP endpoint for Mailhog"
  value       = "${aws_instance.mailhog.public_ip}:1025"
}

output "web_ui_url" {
  description = "The URL for accessing Mailhog Web UI"
  value       = "http://${aws_instance.mailhog.public_ip}:8025"
}