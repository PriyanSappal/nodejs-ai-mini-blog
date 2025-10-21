
output "ecr_repo" {
  value = module.ecr.repository_url
}


output "ecs_service" {
  value = module.ecs.service_name
}