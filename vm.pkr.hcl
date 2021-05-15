
variable "app_name" {
  type    = string
  default = "httpd"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

locals { time = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "httpd" {
  ami_name      = "httpd-vm-${local.time}"
  instance_type = "t2.micro"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.httpd"]
  provisioner "shell" {
    script = "script/script.sh"
  }
  post-processor "shell-local" {
    inline = ["echo Done", "curl icanhazip.com"]
  }
}
