resource "aws_sns_topic" "account_budgets_alarm_topic" {
  name = "account-budget-alarms-topic"

  tags = var.tags
}

resource "aws_sns_topic_policy" "account_budgets_alarm_policy" {
  arn    = aws_sns_topic.account_budgets_alarm_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid    = "AWSBudgetsSNSPublishingPermissions"
    effect = "Allow"

    actions = [
      "SNS:Receive",
      "SNS:Publish"
    ]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
  }
}

resource "aws_budgets_budget" "budget_account" {
  name              = "${var.account_name} Account Monthly Budget"
  budget_type       = "COST"
  limit_amount      = var.account_budget_limit
  limit_unit        = var.budget_limit_unit
  time_unit         = var.budget_time_unit
  time_period_start = "2024-02-28_00:00"


  ## Alert when actual cost exceeds 90% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.email
    subscriber_sns_topic_arns = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
  }

  ## Alert when actual cost exceeds 100% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.email
    subscriber_sns_topic_arns = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
  }

  ## Alert when forecasted cost exceeds 100% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
    subscriber_email_addresses = var.email
  }

/*
  dynamic "notification" {
    for_each = var.notifications

    content {
      comparison_operator = notification.value.comparison_operator
      threshold           = notification.value.threshold
      threshold_type      = notification.value.threshold_type
      notification_type   = notification.value.notification_type
      subscriber_sns_topic_arns = [
        aws_sns_topic.account_budgets_alarm_topic.arn
      ]
    }
  }
*/

  depends_on = [
    aws_sns_topic.account_budgets_alarm_topic
  ]
}

resource "aws_budgets_budget" "budget_resources" {

  name              = var.account_name
  budget_type       = "COST"
  limit_amount      = var.account_budget_limit
  limit_unit        = "USD"
  time_period_end   = "2025-02-28_00:00"
  time_period_start = "2024-02-28_16:16"
  time_unit         = var.budget_time_unit

  ## Alert when actual cost exceeds 90% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.email
    subscriber_sns_topic_arns = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
  }

  ## Alert when actual cost exceeds 100% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.email
    subscriber_sns_topic_arns = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
  }

  ## Alert when forecasted cost exceeds 100% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns = [
      aws_sns_topic.account_budgets_alarm_topic.arn
    ]
    subscriber_email_addresses = var.email
  }

  depends_on = [
    aws_sns_topic.account_budgets_alarm_topic
  ]
}

resource "aws_iam_role" "chatbot_notification" {
  count = var.create_slack_integration == true ? 1 : 0

  name = "ChatBotNotificationRole"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "chatbot.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "chatbot_notification" {
  count = var.create_slack_integration == true ? 1 : 0

  name = "ChatBotNotificationPolicy"
  role = aws_iam_role.chatbot_notification[0].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ],
        Effect : "Allow",
        Resource : "*"
      }
    ]
  })
}

