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

locals {
  sa_roles = {
    "bu2-example-app" = [
      "roles/compute.instanceAdmin.v1",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
    ]
  }
  repo_names = ["bu2-example-app"]
}

module "app_infra_cloudbuild_project" {
  source          = "../../modules/single_project"
  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.common_folder_name
  environment     = "common"
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix
  activate_apis = [
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  # Metadata
  project_suffix    = "infra-pipeline"
  application_name  = "app-infra-pipelines"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu2"
}

module "infra_pipelines" {
  source = "../../modules/infra_pipelines"

  org_id                      = local.org_id
  cloudbuild_project_id       = module.app_infra_cloudbuild_project.project_id
  cloud_builder_artifact_repo = local.cloud_builder_artifact_repo
  remote_tfstate_bucket       = local.projects_remote_bucket_tfstate
  project_prefix              = local.project_prefix
  billing_account             = local.billing_account
  default_region              = var.default_region
  app_infra_repos             = local.repo_names
}

