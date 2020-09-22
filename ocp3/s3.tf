resource "aws_s3_bucket" "ocp3_registry_bucket" {
  bucket = var.s3_registry_storage_bucket_name

  tags = merge(
    var.tags,
    {
      "Name" = var.s3_registry_storage_bucket_name
    },
  )
}

resource "aws_s3_bucket_public_access_block" "ocp3_registry_bucket_access" {
  bucket              = aws_s3_bucket.ocp3_registry_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}
