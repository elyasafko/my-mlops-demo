resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-cluster"
}

resource "aws_ecs_task_definition" "infer" {
  family                   = "${var.project}-infer"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_exec_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([{
    name      = "infer"
    image     = "${aws_ecr_repository.infer_repo.repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 80, protocol = "tcp" }]
    environment = [
      { name = "BUCKET_NAME", value = aws_s3_bucket.model_registry.bucket },
      { name = "AWS_REGION",  value = var.aws_region }
    ]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/ecs/${var.project}"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "infer"
      }
    }
  }])
}

resource "aws_ecs_service" "infer_svc" {
  name            = "${var.project}-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.infer.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet_ids.default.ids[0]]   # simplest: use default VPC first subnet
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "infer"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}
