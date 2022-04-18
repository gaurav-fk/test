resource "aws_codebuild_project" "test_codebuild" {
  name          = "test-build"
  description   = "test-build"
  build_timeout = "60"
  service_role  = "arn:aws:iam::556070338223:role/codebuild"

  artifacts {
    type = "NO_ARTIFACTS"
  }


   environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"


    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "556070338223"
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-south-1"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "test"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "test"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild"
      stream_name = "test-build"
    }
  }

  source {
    buildspec       = "src/buildspec.yml"
    type            = "GITHUB"
    location        = "https://github.com/gaurav-fk/test.git"
    git_clone_depth = 0

  }


  source_version = "main"
}


resource "aws_codebuild_webhook" "test_webhook" {
  project_name = aws_codebuild_project.test_codebuild.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
   filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/main"
    }
    filter {
      type    = "FILE_PATH"
      pattern = "^src/.*"
    }
  }
}
