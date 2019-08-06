variable "api_key" {}
variable "team_id" {}

provider "gorillastack" {
  api_key = "${var.api_key}"
  team_id = "${var.team_id}"
}

# resource "gorillastack_tag_group" "ec2_instance_targets" {
#   name    = "EC2 Instance Targets"
#   tag_expression = "i \"application\":\"crm\" and not /environment/:/production/"
# }

# resource "gorillastack_tag_group" "autoscaling_group_targets" {
#   name    = "AutoScaling Group Targets"
#   tag_expression = "i \"type\":\"api\" and not /environment/:/production/"
# }
