# CloudWatchイベント - EC2の定時起動
resource "aws_cloudwatch_event_rule" "start_swarmnode_rule" {
  count = var.auto_start ? 1 : 0

  name                = "${var.base_name}-SwarmNode-StartRule"
  description         = "Start Swarm Node"
  schedule_expression = var.auto_start_schedule

  tags = merge(
    {
      "Name" = "${var.base_name}-SwarmNode-StartRule"
    },
    var.tags
  )

}

resource "aws_cloudwatch_event_target" "start_swarmnode" {
  count = var.auto_start ? 1 : 0

  target_id = "${var.base_name}-StartInstanceTarget"
  arn       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:automation-definition/AWS-StartEC2Instance"
  rule      = aws_cloudwatch_event_rule.start_swarmnode_rule.0.name
  role_arn  = aws_iam_role.swarmnode_ssm_automation.arn

  input = <<DOC
{
  "InstanceId": ${jsonencode(values(aws_instance.swarm_nodes)[*].id)}
}
DOC
}

# CloudWatchイベント - EC2の定時停止
resource "aws_cloudwatch_event_rule" "stop_swarmnode_rule" {
  count = var.auto_stop ? 1 : 0

  name                = "${var.base_name}-SwarmNode-StopRule"
  description         = "Stop Swarm Node"
  schedule_expression = var.auto_stop_schedule

  tags = merge(
    {
      "Name" = "${var.base_name}-SwarmNode-StopRule"
    },
    var.tags
  )

}

resource "aws_cloudwatch_event_target" "stop_swarmnode" {
  count = var.auto_stop ? 1 : 0

  target_id = "${var.base_name}-StopInstanceTarget"
  arn       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:automation-definition/AWS-StopEC2Instance"
  rule      = aws_cloudwatch_event_rule.stop_swarmnode_rule.0.name
  role_arn  = aws_iam_role.swarmnode_ssm_automation.arn

  input = <<DOC
{
  "InstanceId": ${jsonencode(values(aws_instance.swarm_nodes)[*].id)}
}
DOC
}
