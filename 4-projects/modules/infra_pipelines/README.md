<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_infra\_repos | A list of Cloud Source Repos to be created to hold app infra Terraform configs | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | `string` | n/a | yes |
| bucket\_region | Region to create GCS buckets for tfstate and Cloud Build artifacts | `string` | `"us-central1"` | no |
| cloudbuild\_apply\_filename | Path and name of Cloud Build YAML definition used for terraform apply. | `string` | `"cloudbuild-tf-apply.yaml"` | no |
| cloudbuild\_plan\_filename | Path and name of Cloud Build YAML definition used for terraform plan. | `string` | `"cloudbuild-tf-plan.yaml"` | no |
| cloudbuild\_project\_id | The project id where the pipelines and repos should be created | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| folders\_to\_grant\_browser\_role | List of folders to grant browser role to the cloud build service account. Used by terraform validator to able to load IAM policies. | `list(string)` | `[]` | no |
| gar\_repo\_name | Custom name to use for GAR repo. | `string` | `""` | no |
| gcloud\_version | Default gcloud image version. | `string` | `"393.0.0-slim"` | no |
| impersonate\_service\_account | Service account email of the account to impersonate to run gcloud build submit | `string` | n/a | yes |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| terraform\_apply\_branches | List of git branches configured to run terraform apply Cloud Build trigger. All other branches will run plan by default. | `list(string)` | <pre>[<br>  "development",<br>  "non-production",<br>  "production"<br>]</pre> | no |
| terraform\_version | Default terraform version. | `string` | `"1.3.0"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | `string` | `"380ca822883176af928c80e5771d1c0ac9d69b13c6d746e6202482aedde7d457"` | no |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| cloudbuild\_sa | Cloud Build service account |
| default\_region | Default region to create resources where applicable. |
| gar\_name | GAR Repo name created to store runner images |
| log\_buckets | GCS Buckets to store Cloud Build logs |
| plan\_triggers | CB plan triggers |
| repos | CSRs to store source code |
| state\_buckets | GCS Buckets to store TF state |
| tf\_runner\_artifact\_repo | GAR Repo created to store runner images |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
