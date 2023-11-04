//Create greoup policy for S3bucket limited access
resource "aws_iam_group_policy" "S3_Bucket_Limited_Access" {
  name  = var.s3_bucket_limited_access_policy_name
  group = aws_iam_group.iam_group.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListAllBucketINRoot",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "${var.policy_sid}",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.videos_s3_bucket_url}",
                "arn:aws:s3:::${var.static_url}",
                "arn:aws:s3:::${var.data_files_s3_bucket_url}",
                "arn:aws:s3:::data.devops.co.uk",
                "arn:aws:s3:::${var.mkt_bucket}",
                "arn:aws:s3:::${var.av_bucket}",
                "arn:aws:s3:::${var.private_bucket}",
                "arn:aws:s3:::${var.redshift_data_bucket}/*",
                "arn:aws:s3:::${var.citrusad_bucket}/*"

            ]
        },
        {
            "Sid": "AllowBelowOperations",
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.videos_s3_bucket_url}/*",
                "arn:aws:s3:::${var.static_url}/*",
                "arn:aws:s3:::${var.data_files_s3_bucket_url}/exact-target/${var.environment}/*",
                "arn:aws:s3:::data.devops.co.uk/${var.environment}/*",
                "arn:aws:s3:::${var.mkt_bucket}/*",
                "arn:aws:s3:::${var.av_bucket}/*",
                "arn:aws:s3:::${var.private_bucket}/*",
                "arn:aws:s3:::${var.redshift_data_bucket}/*",
                "arn:aws:s3:::${var.citrusad_bucket}/*"
            ]
        }
    ]
}
EOF

}

//Create group policy for SNS Publish
resource "aws_iam_group_policy" "sns_publish_policy" {
  name  = var.sns_publish_policy_name
  group = aws_iam_group.iam_group.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1403790154000",
            "Effect": "Allow",
            "Action": [
                "sns:ListSubscriptions",
                "sns:Publish"
            ],
            "Resource": [
                "arn:aws:sns:eu-west-1:${var.devops_resources_account_id}:${var.environment_name}-*",
                "arn:aws:sns:eu-west-1:${var.devops_main_account_id}:${var.environment_name}-*"
            ]
        }
    ]
}
EOF

}

//Create group policy for SQS SendReceiveDelete
resource "aws_iam_group_policy" "sqs_send_receive_delete_policy" {
  name  = var.sqs_send_receive_delete_policy_name
  group = aws_iam_group.iam_group.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1403790292000",
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ListQueues",
                "sqs:ReceiveMessage",
                "sqs:SendMessage"
            ],
            "Resource": [
                "arn:aws:sqs:eu-west-1:${var.devops_resources_account_id}:${var.environment_name}-*",
                "arn:aws:sqs:eu-west-1:${var.devops_main_account_id}:${var.environment_name}-*"
            ]
        }
    ]
}
EOF

}

//Create iam group for User
resource "aws_iam_group" "iam_group" {
  name = var.iam_group_name
  path = "/"
}

//Add user to group
resource "aws_iam_group_membership" "group_membership" {
  name = var.group_membership_name

  users = [
    var.iam_vpc_user,
  ]

  group = aws_iam_group.iam_group.name
}

//Attach AWSDataPipeline_PowerUser policy to group
resource "aws_iam_group_policy_attachment" "vpc_app_policy_attachment" {
  group      = aws_iam_group.iam_group.name
  policy_arn = "arn:aws:iam::aws:policy/AWSDataPipeline_PowerUser"
}

resource "aws_iam_role" "role" {
  name = var.role_name

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

}

resource "aws_iam_role_policy_attachment" "ses_full_policy" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy" "policy" {
  name = var.policy_name
  role = aws_iam_role.role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": "ec2:Describe*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "elasticloadbalancing:Describe*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:Describe*"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "autoscaling:Describe*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:Get*"
          ],
          "Resource": "arn:aws:s3:::puppet.bootstrap/bootstrap_agent_nxt.sh"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:Get*"
          ],
          "Resource": [
            "arn:aws:s3:::devops-cybersource",
            "arn:aws:s3:::devops-cybersource/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "dynamodb:DescribeReservedCapacityOfferings",
            "dynamodb:ListGlobalTables",
            "dynamodb:ListTables",
            "dynamodb:DescribeReservedCapacity",
            "dynamodb:ListBackups",
            "dynamodb:PurchaseReservedCapacityOfferings",
            "dynamodb:DescribeLimits",
            "dynamodb:ListStreams"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "dynamodb:*",
          "Resource": [
            "arn:aws:dynamodb:eu-west-1:123456789:table/*/backup/*",
            "arn:aws:dynamodb::123456789:global-table/*",
            "arn:aws:dynamodb:eu-west-1:123456789:table/*/stream/*",
            "arn:aws:dynamodb:eu-west-1:123456789:table/*/index/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": "dynamodb:*",
          "Resource": "arn:aws:dynamodb:eu-west-1:123456789:table/*"
        }
    ]
}
EOF

}

resource "aws_iam_instance_profile" "profile" {
  name       = var.profile_name
  role       = aws_iam_role.role.name
  depends_on = [aws_iam_role.role]
}