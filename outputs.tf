# defining resource values to be outputed
output "server_ip" {
  value = aws_instance.dev_server.public_ip
}
