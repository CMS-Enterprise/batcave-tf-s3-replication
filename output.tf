output "source_s3_bucket" {
  value = module.source_s3_bucket.s3_buckets[var.source_bucket.name]
}

output "destination_s3_bucket" {
  value = module.destination_s3_bucket.s3_buckets[var.destination_bucket.name]
}
