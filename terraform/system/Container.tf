resource "aws_ecr_repository" "content" {
  name                 = "tf-content"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "course" {
  name                 = "tf-course"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "user" {
  name                 = "tf-user"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#https://stackoverflow.com/questions/74825569/build-docker-image-with-terraform-push-it-to-ecr-repo-getting-provisioner-local
resource "null_resource" "content-ECR-push" {
  provisioner "local-exec" {
    command = <<EOF
        aws ecr get-login-password --region ap-northeast-2 | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.content.repository_url}; \
        cd ${path.module}/../../app/content; \
        sudo docker build -t ${aws_ecr_repository.content.name}:1.0 .; \
        sudo docker tag ${aws_ecr_repository.content.name}:1.0 ${aws_ecr_repository.content.repository_url}:1.0; \
        sudo docker push ${aws_ecr_repository.content.repository_url}:1.0;
        
    EOF
  }
}
resource "null_resource" "user-ECR-push" {
  provisioner "local-exec" {
    command = <<EOF
        aws ecr get-login-password --region ap-northeast-2 | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.user.repository_url}; \
        cd ${path.module}/../../app/user; \
        sudo docker build -t ${aws_ecr_repository.user.name}:1.0 .; \
        sudo docker tag ${aws_ecr_repository.user.name}:1.0 ${aws_ecr_repository.user.repository_url}:1.0; \
        sudo docker push ${aws_ecr_repository.user.repository_url}:1.0;
        
    EOF
  }
}
resource "null_resource" "course-ECR-push" {
  provisioner "local-exec" {
    command = <<EOF
        aws ecr get-login-password --region ap-northeast-2 | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.course.repository_url}; \
        cd ${path.module}/../../app/course; \
        sudo docker build -t ${aws_ecr_repository.course.name}:1.0 .; \
        sudo docker tag ${aws_ecr_repository.course.name}:1.0 ${aws_ecr_repository.course.repository_url}:1.0; \
        sudo docker push ${aws_ecr_repository.course.repository_url}:1.0;
        
    EOF
  }
}



resource "aws_ecs_task_definition" "content" {
  family = "tf-bighead-content-was"
  count = 2
  cpu = 512
  memory = 1024
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  task_role_arn = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  container_definitions = templatefile("${path.module}/task-definitions.json", {
    image_url        = "${aws_ecr_repository.content.repository_url}:1.0"
    container_name   = "content-was"
    AWS_PROMETHEUS_ENDPOINT = var.AWS_PROMETHEUS_ENDPOINT
    AOT_CONFIG_CONTENT = var.AOT_CONFIG_CONTENT_arn
    region = "ap-northeast-2"
    aws-otel-collector_image = var.aws-otel-collector_image
  })
}

resource "aws_ecs_task_definition" "user" {
  family = "tf-bighead-user-was"
  count = 2
  cpu = 512
  memory = 1024
  network_mode = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  task_role_arn = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  container_definitions = templatefile("${path.module}/task-definitions.json", {
    image_url        = "${aws_ecr_repository.user.repository_url}:1.0"
    container_name   = "user-was"
    AWS_PROMETHEUS_ENDPOINT = var.AWS_PROMETHEUS_ENDPOINT
    AOT_CONFIG_CONTENT = var.AOT_CONFIG_CONTENT_arn
    region = "ap-northeast-2"
    aws-otel-collector_image = var.aws-otel-collector_image
  })
}

resource "aws_ecs_task_definition" "course" {
  family = "tf-bighead-course-was"
  count = 2
  cpu = 512
  memory = 1024
  network_mode = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  task_role_arn = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  container_definitions = templatefile("${path.module}/task-definitions.json", {
    image_url        = "${aws_ecr_repository.course.repository_url}:1.0"
    container_name   = "course-was"
    AWS_PROMETHEUS_ENDPOINT = var.AWS_PROMETHEUS_ENDPOINT
    AOT_CONFIG_CONTENT = var.AOT_CONFIG_CONTENT_arn
    region = "ap-northeast-2"
    aws-otel-collector_image = var.aws-otel-collector_image
  })
}

resource "aws_ecs_cluster" "tf-bighead-cluster" {
  name = "tf-bighead-cluster"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
  }
}

resource "aws_ecs_service" "content" {
  name            = "content-service"
  cluster         = aws_ecs_cluster.tf-bighead-cluster.id
  task_definition = aws_ecs_task_definition.content[0].arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.content-tg.arn
    container_name   = "content-was"
    container_port   = "8080"
  }
  network_configuration {
    security_groups = [aws_security_group.was-sg.id]
    subnets         = ["${aws_subnet.public_subnet-1.id}", "${aws_subnet.public_subnet-2.id}"]
    assign_public_ip = true
  }

  depends_on = [
    aws_lb_listener.was-listener
  ]
}

resource "aws_ecs_service" "user" {
  name            = "user-service"
  cluster         = aws_ecs_cluster.tf-bighead-cluster.id
  task_definition = aws_ecs_task_definition.user[0].arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.user-tg.arn
    container_name   = "user-was"
    container_port   = "8080"
  }
  network_configuration {
    security_groups = [aws_security_group.was-sg.id]
    subnets         = ["${aws_subnet.public_subnet-1.id}", "${aws_subnet.public_subnet-2.id}"]
    assign_public_ip = true
  }
  depends_on = [
    aws_lb_listener.was-listener
  ]
}

resource "aws_ecs_service" "course" {
  name            = "course-service"
  cluster         = aws_ecs_cluster.tf-bighead-cluster.id
  task_definition = aws_ecs_task_definition.course[0].arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.course-tg.arn
    container_name   = "course-was"
    container_port   = "8080"
  }
  network_configuration {
    security_groups = [aws_security_group.was-sg.id]
    subnets         = ["${aws_subnet.public_subnet-1.id}", "${aws_subnet.public_subnet-2.id}"]
    assign_public_ip = true
  }
  depends_on = [
    aws_lb_listener.was-listener
  ]
}

output "ecs-container-id" {
    value = aws_ecs_service.content
}

output "ecs-cluster-arn" {
  value = aws_ecs_cluster.tf-bighead-cluster.arn
}