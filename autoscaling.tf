resource "aws_appautoscaling_target" "alon_exam_autoscaling" {
  max_capacity = 4
  min_capacity = 2
  resource_id = "service/${var.ecs_cluster_name}/${aws_ecs_service.alon_exam_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "alon_exam_memory" {
  name               = "alon-exam-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.alon_exam_autoscaling.resource_id
  scalable_dimension = aws_appautoscaling_target.alon_exam_autoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.alon_exam_autoscaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 100
  }
}

resource "aws_appautoscaling_policy" "alon_exam_cpu" {
  name = "alon-exam-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.alon_exam_autoscaling.resource_id
  scalable_dimension = aws_appautoscaling_target.alon_exam_autoscaling.scalable_dimension
  service_namespace = aws_appautoscaling_target.alon_exam_autoscaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 50
  }
}