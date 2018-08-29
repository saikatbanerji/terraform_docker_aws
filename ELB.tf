/*
  ELB will act as a procy so that no one can directly hit the ec2 Nginx frontend server. The alias of ELB ideally an application ELB with cookies i.e. session based needs to be configured as an aliase on R53. Heath check 
  path has been just assumed in this case. Also the ARN for SSL for HTTPS is assumed.
*/



# Create a new load balancer
resource "aws_elb" "lb" {
  name               = "new-terraform-elb"
  availability_zones = ["us-east-1a", "us-east-2b", "us-east-2c"]

  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::XXXXXXXXXXXXXXXXXX:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.Angularapp_web-1.id}"] 
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "new-terraform-elb"
  }
}