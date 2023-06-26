
resource "aws_instance" "app_server" {
  ami           = "ami-04cebc8d6c4f297a3"
  instance_type = "t2.micro"

  tags = {
    Name = "test-dev"
  }
}