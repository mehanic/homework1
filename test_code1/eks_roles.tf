
resource "aws_iam_role" "EKSClusterRole" {
  name               = "EKSClusterRole-${var.cluster_name}"
  description        = "Allows EKS to manage clusters on your behalf."
  assume_role_policy = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "Service":"eks.amazonaws.com"
         },
         "Action":"sts:AssumeRole"
      }
   ]
}
POLICY

}


resource "aws_iam_role_policy_attachment" "eks-policy-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
}

resource "aws_iam_role_policy_attachment" "eks-policy-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.EKSClusterRole.name
}
