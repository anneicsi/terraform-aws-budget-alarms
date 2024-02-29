variable "account_name" {
  description = "Specifies the name of the AWS account"
  type        = string
  default     = ""
}

variable "email" {
  description = "email address for receiving alerts"
##  type        = string
  default     = ["anne@icsi.berkeley.edu"]
}


variable "account_budget_limit" {
  description = "Set the budget limit for the AWS account."
  type        = string
  default     = 1.0
}

variable "budget_limit_unit" {
  description = "The unit of measurement used for the budget forecast, actual spend, or budget threshold."
  type        = string
  default     = "USD"
}

variable "budget_time_unit" {
  description = "The length of time until a budget resets the actual and forecasted spend. Valid values: `MONTHLY`, `QUARTERLY`, `ANNUALLY`."
  type        = string
  default     = "MONTHLY"
}

#variable "notifications" {
#  description = "Can be used multiple times to configure budget notification thresholds."
#  type = map(object({
#    comparison_operator = string
#    threshold           = number
#    threshold_type      = string
#    notification_type   = string
#  }))
#}

variable "slack_channel_id" {
  type        = string
  description = "The ID of the Slack channel. (Should be set when create_slack_integration is enabled)."
  default     = "C06LQQ371V5"
}

variable "slack_workspace_id" {
  type        = string
  description = "The ID of the Slack workspace authorized with AWS Chatbot. (Should be set when create_slack_integration is enabled)."
  default     = "T01AXCG4SP4"
}

variable "create_slack_integration" {
  type        = bool
  description = "Whether to create the Slack integration through AWS Chatbot or not."
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags."
}
