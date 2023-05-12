module "template_files" {
  source   = "hashicorp/dir/template"
  version  = "1.0.2"
  base_dir = var.website_root
}

resource "aws_s3_object" "static_files" {
  for_each = module.template_files.files

  bucket       = var.s3_bucket_id
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
  etag         = each.value.digests.md5
}