# data source presets values like ami-id so you don't have to manually choose it all the time
# aws ami (owners = select ami id to find owner id)
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

}
