variable "gitlab_var" {
  type        = string
  default     = "gitlab_key"
  description = "Key-pair generated by Terraform"
}

variable "dir_admin_repo" {
  type        = string
  default     = "/home/admin/.ssh/config"
}

provider "aws" {
    region = "YOUR REGION"
    access_key = "YOUR ACCESS KEY"
    secret_key = "YOUR SECRET KEY"
}

resource "aws_eip_association" "eip_assoc_ansible" {
    instance_id   = aws_instance.Ansible.id
    allocation_id = aws_eip.Ansible.id
}
resource "aws_eip" "Ansible" {
  instance = aws_instance.Ansible.id
  vpc      = true
}

resource "aws_instance" "Ansible" {
    instance_type = "t4g.medium"
    ami = "YOUR AMI IMAGE"
    subnet_id = "YOUR SUBNET ID ALREADY CREATED"
    vpc_security_group_ids = ["YOUR VPC SECURITY GROUP ID ALREADY CREATED"]
    key_name = "EC2_Keys"
    tags = {
        Name = "Enzo - Ansible"
    }

 provisioner "file" {
    source  = "EC2_Keys"  
    destination  = "/home/admin/.ssh/EC2_Keys"  
    
    connection {
        type = "ssh"
        user = "YOUR USER AUTORISE WITH SSH"
        private_key = file("./EC2_Keys")
        host = self.public_ip
  }
}

 provisioner "file" {
    source  = "config"  
    destination  = "/home/admin/.ssh/config"  
    
    connection {
        type = "ssh"
        user = "YOUR USER AUTORISE WITH SSH"
        private_key = file("./EC2_Keys")
        host = self.public_ip
  }
}
   
    provisioner "remote-exec" {
        inline = ["sudo apt update -y",
                  "sudo apt upgrade -y", 
                  "sudo apt install python3 -y", 
                  "sudo apt install ansible -y",
                  "sudo apt install git -y",
                  "sudo apt install python3-pip",
                  "sudo pip3 install -U pip setuptools",
                  "sudo pip3 install pyopenssl --upgrade",
                  "sudo apt install enum",
                  "sudo apt install tree -y",
                  "sudo mv /home/admin/.ssh/EC2_Keys /root/.ssh/EC2_Keys",
                  "sudo ssh-keygen -o -a 100 -t ed25519 -f /root/.ssh/${var.gitlab_var} -C enzo.wintz1@outlook.fr -P ''",
                  "sudo chown root ${var.dir_admin_repo}",
                  "sudo mv ${var.dir_admin_repo} /root/.ssh/config"
                 ]
    

    connection {
        type = "ssh"
        user = "YOUR USER AUTORISE WITH SSH"
        private_key = file("./EC2_Keys")
        host = self.public_ip
      }
    }

}

output "ip" {
  value = "${aws_eip_association.eip_assoc_ansible.public_ip}"
}