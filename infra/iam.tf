# ── infra/iam.tf ───────────────────────────────────────────────
# Policy every ECS task role needs: allow the service to assume it
data "aws_iam_policy_document" "assume_ecs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# ── Execution role (pulls image + writes logs) ────────────────
resource "aws_iam_role" "task_exec" {
  name               = "${var.project}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json
}

resource "aws_iam_role_policy_attachment" "task_exec_ecr" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ── Task role (app’s own permissions) ─────────────────────────
resource "aws_iam_role" "task" {
  name               = "${var.project}-task"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json
}

# Read-only access to the model-registry bucket
resource "aws_iam_policy" "s3_read_model" {
  name        = "${var.project}-s3-read-model"
  description = "Allow task to read model from S3 registry bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.model_registry.id}",
        "arn:aws:s3:::${aws_s3_bucket.model_registry.id}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_s3_attach" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.s3_read_model.arn
}
