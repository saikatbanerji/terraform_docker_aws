/*
 R53 for mapping the ELB alias with the actual domain name. 
*/


resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "xxxx.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.lb.dns_name}"
    zone_id                = "${aws_elb.lb.zone_id}"
    evaluate_target_health = true
  }
}