resource "aws_iam_role" "role" {
  name = var.iam_instance_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    var.tags,
  )
}

resource "aws_iam_instance_profile" "profile" {
  name = var.iam_instance_role_name
  role = aws_iam_role.role.name

  depends_on = [aws_iam_role.role]
}

resource "aws_iam_policy" "policy-s3" {
  name        = var.iam_instance_policy_s3_name
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_registry_storage_bucket_name}",
                "arn:aws:s3:::${var.s3_registry_storage_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "policy-ec2" {
  name        = var.iam_instance_policy_ec2_name
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeVolume*",
                "ec2:CreateVolume",
                "ec2:CreateTags",
                "ec2:DescribeInstances",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DeleteVolume",
                "ec2:DescribeSubnets",
                "ec2:CreateSecurityGroup",
                "ec2:DescribeSecurityGroups",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeRouteTables",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:DescribeLoadBalancerAttributes"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "1"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role-attach-policy-s3" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy-s3.arn
}

resource "aws_iam_role_policy_attachment" "role-attach-policy-ec2" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy-ec2.arn
}

resource "aws_iam_role_policy_attachment" "role-attach-policy-efs" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
}
