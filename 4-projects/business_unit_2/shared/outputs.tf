/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "default_region" {
  description = "Default region to create resources where applicable."
  value       = module.infra_pipelines.default_region
}

output "cloudbuild_project_id" {
  value = module.app_infra_cloudbuild_project.project_id
}

output "terraform_service_accounts" {
  description = "APP Infra Pipeline Terraform Accounts."
  value       = module.infra_pipelines.terraform_service_accounts
}

output "repos" {
  description = "CSRs to store source code"
  value       = module.infra_pipelines.repos
}

output "sa_roles" {
  description = "A list of roles to give the Service Accounts from App Infra Pipeline by workspace repository."
  value       = local.sa_roles
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts"
  value       = module.infra_pipelines.artifact_buckets
}

output "state_buckets" {
  description = "GCS Buckets to store TF state"
  value       = module.infra_pipelines.state_buckets
}

output "plan_triggers_id" {
  description = "CB plan triggers"
  value       = module.infra_pipelines.plan_triggers_id
}

output "apply_triggers_id" {
  description = "CB apply triggers"
  value       = module.infra_pipelines.apply_triggers_id
}
