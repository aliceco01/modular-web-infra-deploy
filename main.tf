# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  access_key = "Insert Access Key Here"
  secret_key = "Insert Secret Access Key Here"
  token = "Insert Token Here"
}

# Creating VPC

resource "aws_vpc" "web_app_vpc" {
  cidr_block = var.vpc_prefix
  tags = {
    Name = "Web App VPC"
  }
}

# Making IGW for my VPC

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.web_app_vpc.id
}

# Making Public Route Table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.web_app_vpc.id

  route {
    cidr_block = var.public_route_table_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Making Private Route Table 1

resource "aws_route_table" "private_route_table-1" {
  vpc_id = aws_vpc.web_app_vpc.id

  route {
    cidr_block = var.private_route_table_cidr
    nat_gateway_id = aws_nat_gateway.nat-gateway-1.id
  }

  tags = {
    Name = "Private Route Table 1"
  }
}

# Making Private Route Table 2

resource "aws_route_table" "private_route_table-2" {
  vpc_id = aws_vpc.web_app_vpc.id

  route {
    cidr_block = var.private_route_table_cidr
    nat_gateway_id = aws_nat_gateway.nat-gateway-2.id
  }

  tags = {
    Name = "Private Route Table 2"
  }
}

# Creating Public Subnet 1

resource "aws_subnet" "public_subnet-1" {
  vpc_id = aws_vpc.web_app_vpc.id
  cidr_block = var.public_subnet-1_cidr
  availability_zone = var.availability_zone-1

  tags = {
    Name = "Public Subnet 1"
  }
}

# Creating Private Subnet 1

resource "aws_subnet" "private_subnet-1" {
  vpc_id = aws_vpc.web_app_vpc.id
  cidr_block = var.private_subnet-1_cidr
  availability_zone = var.availability_zone-1

  tags = {
    Name = "Private Subnet 1"
  }
}

# Creating Public Subnet 2

resource "aws_subnet" "public_subnet-2" {
  vpc_id = aws_vpc.web_app_vpc.id
  cidr_block = var.public_subnet-2_cidr
  availability_zone = var.availability_zone-2

  tags = {
    Name = "Public Subnet 2"
  }
}

# Creating Private Subnet 2

resource "aws_subnet" "private_subnet-2" {
  vpc_id = aws_vpc.web_app_vpc.id
  cidr_block = var.private_subnet-2_cidr
  availability_zone = var.availability_zone-2

  tags = {
    Name = "Private Subnet 2"
  }
}

# Associating the Public Subnet 1 with the Public Route Table

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associating the Private Subnet 1 with the Private Route Table 1

resource "aws_route_table_association" "private-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.private_subnet-1.id
  route_table_id = aws_route_table.private_route_table-1.id
}

# Associating the Public Subnet 2 with the Public Route Table

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associating the Private Subnet 2 with the Private Route Table 1

resource "aws_route_table_association" "private-subnet-2-route-table-association" {
  subnet_id      = aws_subnet.private_subnet-2.id
  route_table_id = aws_route_table.private_route_table-2.id
}

# Creating Security Group to Allow HTTP Traffic

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.web_app_vpc.id

  ingress {
    description      = "Allow HTTP Traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow HTTP Traffic"
  }
}

# Allocating Elastic IP 1

resource "aws_eip" "eip-for-nat-1" {
  vpc      = true
  tags = {
    Name = "Elastic IP 1"
  }
}

# Allocating Elastic IP 2

resource "aws_eip" "eip-for-nat-2" {
  vpc      = true
  tags = {
    Name = "Elastic IP 2"
  }
}

# Create NAT Gateway 1 in Public Subnet-1

resource "aws_nat_gateway" "nat-gateway-1" {
  allocation_id = aws_eip.eip-for-nat-1.id
  subnet_id = aws_subnet.public_subnet-1.id

  tags = {
    Name = "NAT Gateway Public Subnet 1"
  }
}

# Create NAT Gateway 2 in Public Subnet-2

resource "aws_nat_gateway" "nat-gateway-2" {
  allocation_id = aws_eip.eip-for-nat-2.id
  subnet_id = aws_subnet.public_subnet-2.id

  tags = {
    Name = "NAT Gateway Public Subnet 2"
  }
}

# Creating a Target Group for my Application Load Balancer

resource "aws_lb_target_group" "alb" {
  name     = "web-app-tg"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_app_vpc.id

  stickiness {
    type = "lb_cookie"
    enabled = true
    cookie_duration = "600"
  }
}

# Creating an Application Load Balancer

resource "aws_lb" "web-alb" {
  name               = "WebApp-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.public_subnet-1.id, aws_subnet.public_subnet-2.id]
}

# Creating a Launch Template

resource "aws_launch_template" "webapp-lt" {

  name = "webapp-launch-template"

  # Amazon Linux 2 AMI
  image_id = var.ami

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = filebase64("Userdata.txt")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web-App-ASG"
    }
  }
}

# Creating Auto Scaling Group - ASG

resource "aws_autoscaling_group" "webapp-asg" {
  vpc_zone_identifier = [aws_subnet.private_subnet-1.id, aws_subnet.private_subnet-2.id]
  desired_capacity   = 2
  min_size           = 2
  max_size           = 6
  name = "web-asg"

  launch_template {
    id      = aws_launch_template.webapp-lt.id
    version = "$Latest"
  }
}

# Create a new ALB Target Group attachment

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webapp-asg.id
  lb_target_group_arn    = aws_lb_target_group.alb.arn
}

# Forward Traffic to The Target Group

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

# Scaling Down Policies
# Scale 1 Down if CPU Utilization is under 30% over 2 periods of 2 mins (4mins total).
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale_down"
  autoscaling_group_name = aws_autoscaling_group.webapp-asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_description   = "Monitors CPU utilization for Web App ASG"
  alarm_name          = "scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "30"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp-asg.name
  }
}

# Scaling Up Policies
# Scale 1 Up if CPU Utilization is over 70% over 2 periods of 2 mins (4mins total).
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale_up"
  autoscaling_group_name = aws_autoscaling_group.webapp-asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_description   = "Monitors CPU utilization for Web App ASG"
  alarm_name          = "scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp-asg.name
  }
}
