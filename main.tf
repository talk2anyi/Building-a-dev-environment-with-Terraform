# aws vpc resource
resource "aws_vpc" "vscode_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

# aws public subnet
resource "aws_subnet" "vscode_public_subnet" {
  vpc_id                  = aws_vpc.vscode_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

# aws internet gateway
resource "aws_internet_gateway" "vscode_igw" {
  vpc_id = aws_vpc.vscode_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

# aws route table
resource "aws_route_table" "vscode_public_rt" {
  vpc_id = aws_vpc.vscode_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

# AWS default route for the route table resource
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.vscode_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vscode_igw.id
}

# aws route table association with subnet id
resource "aws_route_table_association" "vscode_rt_assoc" {
  subnet_id      = aws_subnet.vscode_public_subnet.id
  route_table_id = aws_route_table.vscode_public_rt.id
}

# aws security group
resource "aws_security_group" "vscode_sg" {
  name        = "dev_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vscode_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_sg"
  }
}

# aws keypair (file funtion abstracts the need to paste the public key directly into the script)
resource "aws_key_pair" "vscode_auth" {
  key_name   = "your_keypair"
  public_key = file("~/.ssh/your_keypair.pub")
}

# aws ec2 instance 
resource "aws_instance" "dev_server" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.vscode_auth.id
  vpc_security_group_ids = [aws_security_group.vscode_sg.id]
  subnet_id              = aws_subnet.vscode_public_subnet.id
  user_data              = file("userdata.tpl")

# adding root_block_device is optional
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-server"
  }

# installs vscode on remote machine and creates ssh connection to it from local machine vscode 
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/your_keypair"
    })
# interpreter for ssh config file
  #  interpreter = ["bash", "-c"]
  # interpreter = ["powershell", "-command"]  for windows users.

  # using terraform conditionals for the interpreter
    interpreter = var.host_os == "windows" ? ["powershell", "-command"] : ["bash", "-c"]
  }
}

