variable "api_key" {}
variable "team_id" {}

provider "gorillastack" {
  api_key = "${var.api_key}"
  team_id = "${var.team_id}"
}

resource "gorillastack_tag_group" "ec2_instance_targets" {
  name    = "EC2 Instance Targets"
  tag_expression = "i \"application\":\"crm\" and not /environment/:/production/"
}

resource "gorillastack_tag_group" "autoscaling_group_targets" {
  name    = "AutoScaling Group Targets"
  tag_expression = "i \"type\":\"api\" and not /environment/:/production/"
}

resource "gorillastack_tag_group" "rds_targets" {
  name    = "RDS Targets"
  tag_expression = "not /environment/:/production/"
}

resource "gorillastack_rule" "test" {
  name      = "test rules creation from terraform"
  labels    = ["terraform", "test", "local"]
  enabled   = false

  context {
    aws {
    }  # should mean all accounts all regions
  }

  trigger {
    schedule {
      cron                = "0 0 9 1 1"
      timezone            = "Australia/Sydney"
      notification_offset = 30
      notifications {
        slack_webhook {
          room_id         = "5cfe861335112656bda2f80a"
        }
      }
    }
  }

  actions {
    delete_detached_volumes {
      index         = 1
      dry_run       = true
      tag_targeted  = false
      days_detached = 0
    }

    stop_instances {
      index         = 2
      tag_groups    = ["${gorillastack_tag_group.ec2_instance_targets.id}"]
    }

    update_autoscaling_groups {
      index         = 3
      tag_groups    = ["${gorillastack_tag_group.autoscaling_group_targets.id}"]
      min           = 0
      max           = 0
      desired       = 0
      store_existing_asg_settings = true
    }

    delay {
      index         = 4
      wait_duration = 10
    }

    stop_rds_instances {
      index         = 5
      tag_groups    = ["${gorillastack_tag_group.rds_targets.id}"]
    }
  }
}