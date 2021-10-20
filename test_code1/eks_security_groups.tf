
resource "aws_security_group" "eks-control-plane-sg" {
  name        = "${var.cluster_name}-control-plane"
  description = "Cluster communication with worker nodes [${var.cluster_name}]"
  vpc_id      = aws_vpc.cluster.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-control-plane-sg.id}"
  to_port           = 443
  type              = "ingress"
}
