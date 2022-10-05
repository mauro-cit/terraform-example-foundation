# 2-environments

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a <a href="../docs/GLOSSARY.md#foundation-cicd-pipeline">CI/CD Pipeline</a> for foundations code in subsequent
stages.</td>
</tr>
<tr>
<td><a href="../1-org">1-org</a></td>
<td>Sets up top level shared folders, monitoring and networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><span style="white-space: nowrap;">2-environments</span> (this file)</td>
<td>Sets up development, non-production, and production environments within the
Google Cloud organization that you've created.</td>
</tr>
<tr>
<td><a href="../3-networks-dual-svpc">3-networks-dual-svpc</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect, and baseline firewall rules for each environment. It also sets
up the global DNS hub.</td>
</tr>
<tr>
<td><a href="../3-networks-hub-and-spoke">3-networks-hub-and-spoke</a></td>
<td>Sets up base and restricted shared VPCs with all the default configuration
found on step 3-networks-dual-svpc, but here the architecture will be based on the
Hub and Spoke network model. It also sets up the global DNS hub</td>
</tr>
</tr>
<tr>
<td><a href="../4-projects">4-projects</a></td>
<td>Sets up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td><a href="../5-app-infra">5-app-infra</a></td>
<td>Deploy a simple <a href="https://cloud.google.com/compute/">Compute Engine</a> instance in one of the business unit projects using the infra pipeline set up in 4-projects.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation).

## Purpose

The purpose of this step is to setup development, non-production, and production environments within the Google Cloud organization that you've created.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. Cloud Identity / Google Workspace group for monitoring admins.
1. Membership in the monitoring admins group for user running Terraform.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

### Deploying with Cloud Build

1. Clone repo.
   ```
   gcloud source repos clone gcp-environments --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Navigate into the repo and change to the non-main branch. All subsequent
   steps assume you are running them from the gcp-environments directory. If
   you run them from another directory, adjust your copy paths accordingly.

   ```
   cd gcp-environments
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/2-environments/ .
   ```
1. Copy cloud build configuration files for Terraform.
   ```
   cp ../terraform-example-foundation/build/cloudbuild-tf-* .
   ```
1. Copy Terraform wrapper script to the root of your new repository.
   ```
   cp ../terraform-example-foundation/build/tf-wrapper.sh .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment and bootstrap (you can re-run `terraform output` in the 0-bootstrap directory to find these values). See any of the envs folder [README.md](./envs/production/README.md#inputs) files for additional information on the values in the `terraform.tfvars` file.
1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to development branch. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. You can now move to the instructions in the step go to for the Dual Shared VPC mode [3-networks-dual-svpc](../3-networks-dual-svpc/README.md), or go to [3-networks-hub-and-spoke](../3-networks-hub-and-spoke/README.md) to use the Hub and Spoke network mode.

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-2-environments)

### Run Terraform locally

1. Change into `2-environments` folder, copy the Terraform wrapper script and ensure it can be executed.
   ```
   cd 2-environments
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `terraform.example.tfvars` to `terraform.tfvars`.
   ```
   mv terraform.example.tfvars terraform.tfvars
   ```
1. Update the file with values from your environment and 0-bootstrap output.See any of the envs folder [README.md](./envs/production/README.md#inputs) files for additional information on the values in the `terraform.tfvars` file.
1. Use `terraform output` to get the backend bucket value from 0-bootstrap output.
   ```
   export backend_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"
   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./terraform.tfvars
   ```
1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.
   ```
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch is the repository for 2-environments step and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build project ID and the environment step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.
   ```
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw environment_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```
1. Run `init` and `plan` and review output for environment development.
   ```
   ./tf-wrapper.sh init development
   ./tf-wrapper.sh plan development
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate development $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` development.
   ```
   ./tf-wrapper.sh apply development
   ```
1. Run `init` and `plan` and review output for environment non-production.
   ```
   ./tf-wrapper.sh init non-production
   ./tf-wrapper.sh plan non-production
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate non-production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` non-production.
   ```
   ./tf-wrapper.sh apply non-production
   ```
1. Run `init` and `plan` and review output for environment production.
   ```
   ./tf-wrapper.sh init production
   ./tf-wrapper.sh plan production
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate production $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` production.
   ```
   ./tf-wrapper.sh apply production
   ```

If you received any errors or made any changes to the Terraform config or `terraform.tfvars` you must re-run `./tf-wrapper.sh plan <env>` before running `./tf-wrapper.sh apply <env>`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.
```
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
