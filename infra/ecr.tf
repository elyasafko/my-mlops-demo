# infra/ecr.tf
resource "aws_ecr_repository" "infer_repo" {
  name = "${var.project}-infer"        # e.g. mlops-demo-infer
  image_scanning_configuration { scan_on_push = true }
  lifecycle { prevent_destroy = false } # OK to destroy in demos
}

output "ecr_repo_url" {
  value = aws_ecr_repository.infer_repo.repository_url
}
