output "cwlogs_groupname" {
  description = "Cloudwatch Log Group name"
  value       = "${aws_cloudwatch_log_group.techdebug.id}"
}
