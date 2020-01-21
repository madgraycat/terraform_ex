provider "aws" {
region = "${var.region}"
}

resource "aws_security_group" "test" {
 name = "test"
 vpc_id = "${var.vpc_id}"
 ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }

}
resource "aws_key_pair" "my_aws" {
 key_name = "my_aws"
 public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "nginx" {
 ami = "${var.instance_ami}"
 instance_type = "${var.instance_type}"
 key_name = "my_aws"
 subnet_id = "${var.subnet_id}"
 vpc_security_group_ids = ["${aws_security_group.test.id}"] 

provisioner "remote-exec" {
 inline = [
  "sudo apt -y update",
  "sudo apt -y install nginx"
 ]
}

connection {
 type = "ssh"
 user = "ubuntu"
 private_key = "${file(var.private_key_path)}"
}

provisioner "file" {
 source = "./index.html"
 destination = "/tmp/index.html"
}

provisioner "remote-exec" {
 inline = [
  "sudo rm /var/www/html/index.nginx-debian.html",
  "sudo cp /tmp/index.html /var/www/html/"
]
}

}
