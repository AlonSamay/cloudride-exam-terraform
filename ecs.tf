resource "aws_ecs_cluster" "alon_exam_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "alon_exam_task" {
  family                   = "alon_exam-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "alon_exam-task",
      "image": "${aws_ecr_repository.alon_exam_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
}

resource "aws_ecs_service" "alon_exam_service" {
  name            = "alon_exam-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.alon_exam_cluster.id}"       # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.alon_exam_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 2 # Setting the number of containers we want deployed to 2
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.alon_exam_task.family}"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group

  }
}