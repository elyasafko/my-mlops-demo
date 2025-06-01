# Allow the task to pull from ECR and read the model bucket
data "aws_iam_policy_document" "task_exec_assume" {
  statement {
    principals { type = "Service" identifiers = ["ecs-tasks.amazonaws.com"] }
    actions    = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task_exec_role" {
  name               = "${var.project}-exec"
  assume_role_policy = data.aws_iam_policy_document.task_exec_assume.json
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  name               = "${var.project}-task"
  assume_role_policy = data.aws_iam_policy_document.task_exec_assume.json
}

resource "aws_iam_policy" "s3_read_model" {
  name        = "${var.project}-s3-read-model"
  description = "Allow task to read model from S3 registry bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["s3:GetObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.model_registry.id}",
        "arn:aws:s3:::${aws_s3_bucket.model_registry.id}/*"
      ],
      Effect   = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.s3_read_model.arn
}
