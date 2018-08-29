
/*
  Angular App Server. Here we are creating a front end EC2 with the proper ports open, and in the EC2 we are installing the dependencies and installing docker and docker compose. The we are cloning the dockercompose.yml file from 
  git, moving in that directory and then creating a container with the Nginx image in dockerhub as described in the document
*/
resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
	ingress {
        from_port = 1881
        to_port = 1881
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"
		}
	
    
    egress { 
        from_port = 1881
        to_port = 1881
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
	egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
	egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "Angularapp_web-1" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "us-east-1a"
    instance_type = "m1.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.us-east-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "Web Server 1"
    }
	 provisioner "remote-exec" {
    inline = [
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6",
       "sudo echo  'deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list",
      "sudo curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -",
      "sudo apt-get -y update",
      "sudo apt-get -y install git mongodb-org nodejs nginx build-essential wget",
      "sudo service nginx start",
      "sudo service nginx start",
      "sudo npm install -g bower",
      "sudo npm install -g gulp",
      "sudo npm install -g mean-cli",
	  "export LC_ALL=C"
      "sudo apt-get update -y"
      "sudo apt-get upgrade -y"
### install python-minimal
      "sudo apt-get install python-minimal -y"
  # install docker-engine
     "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
     "sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
     "sudo apt-get update"
     "sudo apt-get install -y docker-ce"
     "echo "Docker installed..." "
     "sudo usermod -aG docker ${whoami}"
     "sudo systemctl enable docker"
     "sudo systemctl start docker"
	 "pip install docker-compose"
	 "pip install --upgrade pip"
	# Dockercompose file will be downloaded from github in a directory called nginx which has the nginx and the angular app in the image
	 "git clone https://github.com/xxxx/nginx"  
	 "cd nginx"
	 "docker-compose up -d"
		    ]
}

resource "aws_eip" "web-1" {
    instance = "${aws_instance.web-1.id}"
    vpc = true
}