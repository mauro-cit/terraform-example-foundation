# 3-networks-dual-svpc

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
<td><a href="../2-environments"><span style="white-space: nowrap;">2-environments</span></a></td>
<td>Sets up development, non-production, and production environments within the
Google Cloud organization that you've created.</td>
</tr>
<tr>
<td><a>3-networks-dual-svpc (this file)</a></td>
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

The purpose of this step is to:

- Set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones).
- Set up base and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, on-premises Dedicated or Partner Interconnect, and baseline firewall rules for each environment.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running

   ```bash
   gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"
   ```

1. For the manual step described in this document, you need [Terraform](https://www.terraform.io/downloads.html) version 1.0.0 or later to be installed.

**Note:** Make sure that you use version 1.0.0 or later of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**Note:** If you are using MacOS, replace `cp -RT` with `cp -R` in the relevant
commands. The `-T` flag is needed for Linux, but causes problems for MacOS.

### Networking Architecture

This step makes use of the **Dual Shared VPC** architecture, and more details can be found described at the **Networking** section of the [Google cloud security foundations guide](https://cloud.google.com/architecture/security-foundations/networking). To see the version that makes use the Hub and Spoke mode, check the step [3-networks-hub-and-spoke](../3-networks-hub-and-spoke).


### Using Dedicated Interconnect

If you provisioned the prerequisites listed in the [Dedicated Interconnect README](./modules/dedicated_interconnect/README.md), follow these steps to enable Dedicated Interconnect to access on-premises resources.

1. Rename `interconnect.tf.example` to `interconnect.tf` in base_env folder in `3-networks-dual-svpc/modules/base_env`.
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. The candidate subnetworks and vlan_tag8021q variables can be set to `null` to allow the interconnect module to auto generate these values.

### Using Partner Interconnect

If you provisioned the prerequisites listed in the [Partner Interconnect README](./modules/partner_interconnect/README.md) follow this steps to enable Partner Interconnect to access on-premises resources.

1. Rename `partner_interconnect.tf.example` to `partner_interconnect.tf` in the base-env folder in `3-networks-dual-svpc/modules/base_env` .
1. Update the file `partner_interconnect.tf` with values that are valid for your environment for the VLAN attachments, locations, and candidate subnetworks.
1. The candidate subnetworks variable can be set to `null` to allow the interconnect module to auto generate this value.

### OPTIONAL - Using High Availability VPN

If you are not able to use Dedicated or Partner Interconnect, you can also use an HA Cloud VPN to access on-premises resources.

1. Rename `vpn.tf.example` to `vpn.tf` in base-env folder in `3-networks-dual-svpc/modules/base_env`.
1. Create secret for VPN private pre-shared key.
   ```
   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_PRIVATE_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-
   ```
1. Create secret for VPN restricted pre-shared key.
   ```
   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_RESTRICTED_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-
   ```
1. In the file `vpn.tf`, update the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.

### Deploying with Cloud Build

1. Clone repo.
   ```
   gcloud source repos clone gcp-networks --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Change to the freshly cloned repo and change to non-main branch.
   ```
   cd gcp-networks/
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.
   ```
   cp -RT ../terraform-example-foundation/3-networks-dual-svpc/ .
   ```
1. Copy Cloud Build configuration files for Terraform.
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
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars` and update the file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and update the file with the `target_name_server_addresses` (the list of target name servers for the DNS forwarding zone in the DNS Hub).
1. Rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars` and update the file with the `access_context_manager_policy_id`.
1. Commit changes
   ```
   git add .
   git commit -m 'Your message'
   ```
1. You must manually plan and apply the `shared` environment (only once) since the `development`, `non-production` and `production` environments depend on it.
    1. Run `cd ./envs/shared/`.
    1. Update `backend.tf` with your bucket name from the bootstrap step.
    1. Export the network (`terraform-net-sa`) service account for impersonation `export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="<IMPERSONATE_SERVICE_ACCOUNT>"`
    1. Run `terraform init`.
    1. Run `terraform plan` and review output.
    1. Run `terraform apply`.
    1. If you would like the bucket to be replaced by Cloud Build at run time, change the bucket name back to `UPDATE_ME`.
1. Push your plan branch to trigger a plan for all environments. Because the
   _plan_ branch is not a [named environment branch](../docs/FAQ.md#what-is-a-named-branch), pushing your _plan_
   branch triggers _terraform plan_ but not _terraform apply_.
   ```
   cd ../../
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b production
   git push origin production
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After production has been applied, apply development.
1. Merge changes to development. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. After development has been applied, apply non-production.
1. Merge changes to non-production. Because this is a [named environment branch](../docs/FAQ.md#what-is-a-named-branch),
   pushing to this branch triggers both _terraform plan_ and _terraform apply_.
   ```
   git checkout -b non-production
   git push origin non-production
   ```
1. Review the apply output in your Cloud Build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. You can now move to the instructions in the step [4-projects](../4-projects/README.md).

### Deploying with Jenkins

See `0-bootstrap` [README-Jenkins.md](../0-bootstrap/README-Jenkins.md#deploying-step-3-networks-dual-svpc)

### Run Terraform locally

1. Change into `3-networks-dual-svpc` folder, copy the Terraform wrapper script and ensure it can be executed.
   ```
   cd 3-networks-dual-svpc
   cp ../build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```
1. Rename `common.auto.example.tfvars` to `common.auto.tfvars`, rename `shared.auto.example.tfvars` to `shared.auto.tfvars` and rename `access_context.auto.example.tfvars` to `access_context.auto.tfvars`.
   ```
   mv common.auto.example.tfvars common.auto.tfvars
   mv shared.auto.example.tfvars shared.auto.tfvars
   mv access_context.auto.example.tfvars access_context.auto.tfvars
   ```
1. Update `common.auto.tfvars` file with values from your environment and bootstrap. See any of the envs folder [README.md](./envs/production/README.md) files for additional information on the values in the `common.auto.tfvars` file.
1. Update `shared.auto.tfvars` file with the `target_name_server_addresses`.
1. Update `access_context.auto.tfvars` file with the `access_context_manager_policy_id`.
1. Use `terraform output` to get the backend bucket and networks step Terraform Service Account values from 0-bootstrap output.
   ```
   export ORGANIZATION_ID=$(terraform -chdir="../0-bootstrap/" output -json common_config | jq '.org_id' | tr -d '"')
   export ACCESS_CONTEXT_MANAGER_ID=$(gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format="value(name)")
   echo "access_context_manager_policy_id = ${ACCESS_CONTEXT_MANAGER_ID}"
   sed -i "s/ACCESS_CONTEXT_MANAGER_ID/${ACCESS_CONTEXT_MANAGER_ID}/" ./access_context.auto.tfvars

   export backend_bucket=$(terraform -chdir="../0-bootstrap/" output -raw gcs_bucket_tfstate)
   echo "remote_state_bucket = ${backend_bucket}"
   sed -i "s/REMOTE_STATE_BUCKET/${backend_bucket}/" ./common.auto.tfvars

   export NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL=$(terraform -chdir="../0-bootstrap/" output -raw networks_step_terraform_service_account_email)
   echo "terraform_service_account = ${NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL}"
   sed -i "s/NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL/${NETWORKS_STEP_TERRAFORM_SERVICE_ACCOUNT_EMAIL}/" ./common.auto.tfvars
   ```
1. Also update `backend.tf` with your backend bucket from 0-bootstrap output.
   ```
   for i in `find -name 'backend.tf'`; do sed -i "s/UPDATE_ME/${backend_bucket}/" $i; done
   ```

We will now deploy each of our environments(development/production/non-production) using this script.
When using Cloud Build or Jenkins as your CI/CD tool each environment corresponds to a branch in the repository for 3-networks-dual-svpc step
and only the corresponding environment is applied.

To use the `validate` option of the `tf-wrapper.sh` script, please follow the [instructions](https://cloud.google.com/docs/terraform/policy-validation/validate-policies#install) to install the terraform-tools component.

1. Use `terraform output` to get the Cloud Build project ID and the environment step Terraform Service Account from 0-bootstrap output. An environment variable `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` will be set using the Terraform Service Account to enable impersonation.
   ```
   export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../0-bootstrap/" output -raw cloudbuild_project_id)
   echo ${CLOUD_BUILD_PROJECT_ID}

   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../0-bootstrap/" output -raw networks_step_terraform_service_account_email)
   echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
   ```
1. Run `init` and `plan` and review output for environment shared.
   ```
   ./tf-wrapper.sh init shared
   ./tf-wrapper.sh plan shared
   ```
1. Run `validate` and check for violations.
   ```
   ./tf-wrapper.sh validate shared $(pwd)/../policy-library ${CLOUD_BUILD_PROJECT_ID}
   ```
1. Run `apply` shared.
   ```
   ./tf-wrapper.sh apply shared
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

If you received any errors or made any changes to the Terraform config or any `.tfvars`, you must re-run `./tf-wrapper.sh plan <env>` before run `./tf-wrapper.sh apply <env>`.

Before executing the next stages, unset the `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT` environment variable.
```
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```
