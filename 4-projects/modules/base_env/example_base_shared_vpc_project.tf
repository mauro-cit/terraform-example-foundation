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

module "base_shared_vpc_project" {
  source = "../single_project"

  org_id                     = local.org_id
  billing_account            = local.billing_account
  folder_id                  = local.env_folder_name
  environment                = var.env
  vpc_type                   = "base"
  shared_vpc_host_project_id = local.base_host_project_id
  shared_vpc_subnets         = local.base_subnets_self_links
  alert_spent_percents       = var.alert_spent_percents
  alert_pubsub_topic         = var.alert_pubsub_topic
  budget_amount              = var.budget_amount
  project_prefix             = local.project_prefix
  enable_cloudbuild_deploy   = true

  sa_roles = [
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
  ]
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]

  # Metadata
  project_suffix    = "sample-base"
  application_name  = "${var.business_code}-sample-application"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = google-beta
  count    = length(local.base_subnets_self_links)

  subnetwork = element(
    split("/", local.base_subnets_self_links[count.index]),
    index(
      split("/", local.base_subnets_self_links[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", local.base_subnets_self_links[count.index]),
    index(split("/", local.base_subnets_self_links[count.index]), "regions") + 1,
  )
  project = local.base_host_project_id
  member  = "serviceAccount:${local.app_infra_pipeline_service_accounts[0]}"
}
