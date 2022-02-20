resource "aws_lb" "aws-nlb" {
  name               = "${var.aws_cluster_name}-nlb"
  load_balancer_type = "network"
  internal           = var.aws_elb_internal
  subnets            = length(var.aws_elb_subnets) <= length(var.aws_avail_zones) ? var.aws_elb_subnets : slice(var.aws_elb_subnets, 0, length(var.aws_avail_zones))
  idle_timeout       = 400
  enable_cross_zone_load_balancing   = true

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-nlb"
  }))
}

resource "aws_lb_target_group" "aws-nlb-tg" {
  name     = "${var.aws_cluster_name}-nlb-tg"
  protocol = "TCP"
  port = var.aws_tg_port  
  target_type = "instance"
  vpc_id   = var.aws_vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
  }
}

resource "aws_lb_listener" "aws-nlb-api-listener" {
  load_balancer_arn = aws_lb.aws-nlb.arn
  port              = var.aws_elb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws-nlb-tg.arn
  }
}


resource "aws_lb_target_group_attachment" "target-group-instance" {
  count = length(var.instance_id)
  target_group_arn = aws_lb_target_group.aws-nlb-tg.arn
  target_id        = element(var.instance_id, count.index)
  port             = var.aws_tg_port
}