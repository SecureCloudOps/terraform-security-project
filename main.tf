provider "aws" {
  region = "us-east-1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create a customer managed KMS key
resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = {
    Name        = "S3-Encryption-Key"
    Environment = "DevSecOps"
  }
}

# Create an alias for the KMS key
resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/s3-encryption-key"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

resource "aws_s3_bucket" "flask_logs" {
  bucket = "flask-app-logs-${random_string.suffix.result}"

  tags = {
    Name        = "Flask App Logs"
    Environment = "DevSecOps"
  }
}

resource "aws_s3_bucket" "log_storage" {
  bucket = "flask-app-log-storage-${random_string.suffix.result}"

  tags = {
    Name        = "Flask Log Storage"
    Environment = "DevSecOps"
  }
}

# Block Public Access for S3 Buckets
resource "aws_s3_bucket_public_access_block" "flask_logs_block" {
  bucket                  = aws_s3_bucket.flask_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "log_storage_block" {
  bucket                  = aws_s3_bucket.log_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Server-Side Encryption with KMS Customer Managed Key
resource "aws_s3_bucket_server_side_encryption_configuration" "flask_logs_encryption" {
  bucket = aws_s3_bucket.flask_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_storage_encryption" {
  bucket = aws_s3_bucket.log_storage.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable Versioning for S3 Buckets
resource "aws_s3_bucket_versioning" "flask_logs_versioning" {
  bucket = aws_s3_bucket.flask_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "log_storage_versioning" {
  bucket = aws_s3_bucket.log_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable S3 Bucket Logging
resource "aws_s3_bucket_logging" "flask_logs_logging" {
  bucket        = aws_s3_bucket.flask_logs.id
  target_bucket = aws_s3_bucket.log_storage.id
  target_prefix = "log/"
}

# Optional - Reciprocal logging if needed
resource "aws_s3_bucket_logging" "log_storage_logging" {
  bucket        = aws_s3_bucket.log_storage.id
  target_bucket = aws_s3_bucket.flask_logs.id
  target_prefix = "log/"
}