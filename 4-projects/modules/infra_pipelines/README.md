<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_infra\_repos | A list of Cloud Source Repos to be created to hold app infra Terraform configs. | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with. | `string` | n/a | yes |
| cloud\_builder\_artifact\_repo | GAR Repo that stores TF Cloud Builder images. | `string` | n/a | yes |
| cloudbuild\_project\_id | The project id where the pipelines and repos should be created. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| remote\_tfstate\_bucket | Bucket with remote state data to be used by the pipeline. | `string` | n/a | yes |
| terraform\_docker\_tag\_version | TAG version of the terraform docker image. | `string` | `"v1"` | no |
| terraform\_apply\_branches | List of git branches configured to run terraform apply Cloud Build trigger. All other branches will run plan by default. | `list(string)` | <pre>[<br>  "development",<br>  "non-production",<br>  "production"<br>]</pre> | no |
| terraform\_version | Default terraform version. | `string` | `"1.3.0"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | `string` | `"380ca822883176af928c80e5771d1c0ac9d69b13c6d746e6202482aedde7d457"` | no |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers\_id | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| default\_region | Default region to create resources where applicable. |
| gar\_name | GAR Repo name created to store runner images |
| log\_buckets | GCS Buckets to store Cloud Build logs |
| plan\_triggers\_id | CB plan triggers |
| repos | CSRs to store source code |
| state\_buckets | GCS Buckets to store TF state |
| terraform\_service\_accounts | App Infra Pipeline Terraform SA mapped to source repos as keys |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
