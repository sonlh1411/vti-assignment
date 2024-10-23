resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-app-repo"
  image_tag_mutability = "IMMUTABLE"
  tags = {
    Name = "${var.project_name}-app-repo"
  }
}
