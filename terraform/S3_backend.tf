# Create S3 Backend
resource "aws_s3_bucket" "terraform_state" {
  bucket = "nofar-opsschool-state"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning for revision history 
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
