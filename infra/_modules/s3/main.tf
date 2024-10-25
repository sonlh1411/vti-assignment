resource "aws_s3_bucket" "static_website" {
  bucket = "${var.project_name}-static-web"

  tags = {
    Name = "${var.project_name}-static-web"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls  = true
  ignore_public_acls = true
}

resource "aws_s3_bucket_website_configuration" "static_website_config" {
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]

  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "static_website_policy" {
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
  bucket     = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static_website.arn}/*"
    }]
  })
}
