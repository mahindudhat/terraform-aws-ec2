output "PublicIP" {
      value="${aws_instance.myfirst.public_ip}"
  }
   output "PrivateIP" {
      value="${aws_instance.myfirst.private_ip}"
  }
