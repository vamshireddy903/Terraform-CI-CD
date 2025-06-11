resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_value
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "EKS-VPC"
    }
}

resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  
    tags = {
        Name = "EKS-Subnet-1"
    }
}

resource "aws_subnet" "sub2" {
    vpc_id=aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "EKS-Subnet-2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "EKS-Internet-Gateway"
    }
}



resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id

}
    tags = {
        Name = "EKS-Route-Table"
    }
}

resource "aws_route_table_association" "Rt1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "Rt2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id
}

#create security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
    vpc_id = aws_vpc.vpc.id
    name = "EKS-Cluster-SG"
    description = "Security group for EKS cluster"

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
     ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "EKS-Cluster-SG"
    }
}


#Create ec2 instance
resource "aws_instance" "eks_instance" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    subnet_id = aws_subnet.sub1.id
    vpc_security_group_ids = [aws_security_group.eks_cluster_sg.id]
    associate_public_ip_address = true
    user_data = base64encode(file("userdata.sh"))
    tags = {
        Name = "EKS-Instance"
    }
}


resource "aws_instance" "eks_instance1" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    subnet_id = aws_subnet.sub2.id
    vpc_security_group_ids = [aws_security_group.eks_cluster_sg.id]
    associate_public_ip_address = true
    user_data = base64encode(file("userdata1.sh"))
    tags = {
        Name = "EKS-Instance1"
    }
}

# Create load balancer
resource "aws_lb" "eks_lb" {
    name               = "eks-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.eks_cluster_sg.id]
    subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

    enable_deletion_protection = false

    tags = {
        Name = "EKS-Load-Balancer"
    }
}

#Create target group for load balancer
resource "aws_lb_target_group" "eks_target_group" {
    name     = "eks-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.vpc.id

    health_check {
        path                = "/"
        port = "traffic-port"
    }

    tags = {
        Name = "EKS-Target-Group"
    }
}

# Register targets to the target group
resource "aws_lb_target_group_attachment" "eks_target_attachment1" {
    target_group_arn = aws_lb_target_group.eks_target_group.arn
    target_id        = aws_instance.eks_instance.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "eks_target_attachment2" {
    target_group_arn = aws_lb_target_group.eks_target_group.arn
    target_id        = aws_instance.eks_instance1.id
    port             = 80
}

# Create listener for load balancer
resource "aws_lb_listener" "eks_listener" {
    load_balancer_arn = aws_lb.eks_lb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.eks_target_group.arn
    }

    tags = {
        Name = "EKS-Listener"
    }
}

