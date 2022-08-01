#!/bin/bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage:
# bash scripts/validate-requirements.sh "END_USER_EMAIL" "ORGANIZATION_ID" "BILLING_ACCOUNT_ID"

# -------------------------- Variables --------------------------
# Expected versions of the installers
TF_VERSION="1.2.1"
GCLOUD_SDK_VERSION="319.0.0"
GIT_VERSION="2.25.1"
# User Inputs
END_USER_CREDENTIAL="$1"
ORGANIZATION_ID="$2"
BILLING_ACCOUNT="$3"

ERRORS=""
# -------------------------- Funcions ---------------------------

# Compare two semantic versions
function compare_version(){
    # echo "comparing $1 and $2"
    if [[ "$1" == "$2" ]]; then
        return 0
    fi

    local IFS=.
    local i
    local version1=("$1")
    local version2=("$2")
    for ((i=${#version1[@]}; i<${#version2[@]}; i++))
    do
        version1[i]=0
    done
    for ((i=0; i<${#version1[@]}; i++))
    do
        if [[ -z ${version2[i]} ]]
        then
            version2[i]=0
        fi
        if [[ ${version1[i]} > ${version2[i]} ]]
        then
            return 1
        fi
        if [[ ${version1[i]} < ${version2[i]} ]]
        then
            return 2
        fi
    done
    return 0
}

# Validate the Terraform installation and version
function validate_terraform(){

    if [ ! "$(command -v terraform )" ]; then
        echo "Terraform not found."
        echo "Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and follow the instructions to install Terraform."
        ERRORS+=$'Terraform not found\n'
    else
        TERRAFORM_CURRENT_VERSION=$(terraform version -json | jq -r .terraform_version)
        compare_version "$TERRAFORM_CURRENT_VERSION" "$TF_VERSION"
        if [ $? -ne 0 ]; then
            echo "An incompatibly was found in Terraform version."
            echo "Terraform version $TF_VERSION is required."
            echo "Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and follow the instructions to install Terraform."
            ERRORS+=$'Terraform version is incompatible.\n'
        fi
    fi
}

# Validate the Google Cloud SDK installation and version
function validate_gcloud(){
    if [ ! "$(command -v gcloud)" ]; then
        echo "gcloud CLI not found."
        echo "Visit https://cloud.google.com/sdk/docs/install and follow the instructions to install gcloud CLI."
        ERRORS+=$'gcloud not found.\n'
    else
        GCLOUD_CURRENT_VERSION=$(gcloud version --format=json | jq -r '."Google Cloud SDK"')
        compare_version "$GCLOUD_CURRENT_VERSION" "$GCLOUD_SDK_VERSION"
        if [ $? -eq 2 ]; then
            echo "An incompatibly was found in gcloud version."
            echo "Version required is at least $GCLOUD_SDK_VERSION"
            echo "Visit https://cloud.google.com/sdk/docs/install and follow the instructions to install gcloud CLI."
            ERRORS+=$'gcloud version is incompatible.\n'
        fi
    fi
}

# Validate the Git installation and version
function validate_git(){
    if [ ! "$(command -v git)" ]; then
        echo "git not found."
        echo "Visit https://git-scm.com/book/en/v2/Getting-Started-Installing-Git and follow the instructions to install Git."
        ERRORS+=$'git not found.\n'
    else
        GIT_CURRENT_VERSION=$(git version | awk '{print $3}')
        compare_version "$GIT_CURRENT_VERSION" "$GIT_VERSION"
        if [ $? -eq 2 ]; then
            echo "An incompatibly was found in git version."
            echo "Version required is at least $GIT_VERSION"
            echo "Visit https://git-scm.com/book/en/v2/Getting-Started-Installing-Git and follow the instructions to install Git."
            ERRORS+=$'git version is incompatible.\n'
        fi
    fi

    if ! git config init.defaultBranch | grep "main" >/dev/null ; then
        echo "git defaul branch must be configured."
        echo "See the instructions at https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/TROUBLESHOOTING.md#default-branch-setting ."
        ERRORS+=$'git default branch must be configured.\n'
    fi
}

# Validate the Configuration of the Gcloud CLI
function validate_gcloud_configuration(){

    END_USER_CREDENTIAL_OUTPUT="$(gcloud config get-value account 2>&1 >/dev/null)"
    if [ "$(echo "$END_USER_CREDENTIAL_OUTPUT" | grep -c unset)" -eq 1 ]; then
        echo "You must configure an End User Credential."
        echo "Visit https://cloud.google.com/sdk/gcloud/reference/auth/login and follow the instructions to authorize gcloud to access the Cloud Platform with Google user credentials."
        ERRORS+=$'gcloud end user credential not configured.\n'
    fi

    APPLICATION_DEFAULT_CREDENTIAL_OUTPUT="$(gcloud auth application-default print-access-token 2>&1 >/dev/null)"
    if [ "$(echo "$APPLICATION_DEFAULT_CREDENTIAL_OUTPUT" | grep -c 'Could not automatically determine credentials')" -eq 1 ]; then
        echo "You must configure an Application Default Credential."
        echo "Visit https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login and follow the instructions to authorize gcloud to access the Cloud Platform with Google user credentials."
        ERRORS+=$'gcloud application default credential not configured.\n'
    fi
}

# Function to validate the Configuration of the Gcloud CLI
function validate_credential_roles(){
    check_org_level_roles "$END_USER_CREDENTIAL" "$ORGANIZATION_ID"
    check_billing_account_roles "$END_USER_CREDENTIAL" "$BILLING_ACCOUNT"
}

# Verifies wheter a user is assigned to the expected Orgzanization Level roles
function check_org_level_roles(){

    ORG_LEVEL_ROLES_OUTPUT=$(
        gcloud organizations get-iam-policy "$2" \
        --filter="bindings.members:$1" \
        --flatten="bindings[].members" \
        --format="table(bindings.role)" 2>/dev/null)

    lines=$(echo "$ORG_LEVEL_ROLES_OUTPUT" | grep -o -e roles/resourcemanager.folderCreator -e roles/resourcemanager.organizationAdmin | wc -l)

    if [ "$lines" -ne 2 ]; then
        echo "The User must have the Organization Roles resourcemanager.folderCreator and resourcemanager.organizationAdmin"
        ERRORS+=$'There are missing organization level roles on the Credential.\n'
    fi
}

# Verifies wheter a user is assigned to the expected Billing Level roles
function check_billing_account_roles(){

    BILLING_LEVEL_ROLES_OUTPUT=$(
        gcloud beta billing accounts get-iam-policy "$2" \
        --filter="bindings.members:$1" \
        --flatten="bindings[].members" \
        --format="table(bindings.role)" 2>/dev/null)

    lines=$(echo "$BILLING_LEVEL_ROLES_OUTPUT" | grep -o -e roles/billing.admin | wc -l)

    if [ "$lines" -ne 1 ]; then
        echo "The User must have the Billing Account Role billing.admin"
        ERRORS+=$'There are missing billing account level roles on the Credential.\n'
    fi
}

# Checks if initial config was done for 0-bootstrap step
function validate_bootstrap_step(){
    FILE=0-bootstrap/terraform.tfvars
    if [ ! -f "$FILE" ]; then
        echo "$FILE does not exists."
    else
        if [ "$(grep -c REPLACE_ME $FILE)" != 0 ]; then
            echo "$FILE must have required values fullfiled."
            ERRORS+=$'terraform.tfvars file must be correctly fullfiled for 0-bootstrap step.\n'
        fi
    fi
}

function main(){

    if [ -z "$END_USER_CREDENTIAL" ] || [ -z "$ORGANIZATION_ID" ] || [ -z "$BILLING_ACCOUNT" ]; then
        echo "Some parameter is missing."
        echo "To use the script correctly make sure to pass the varibles like the following:"
        echo "bash scripts/validate-requirements.sh END_USER_EMAIL ORGANIZATION_ID BILLING_ACCOUNT_ID"
        exit 1
    fi

    echo "Validating Terraform installation..."
    validate_terraform

    echo "Validating Google Cloud SDK installation..."
    validate_gcloud

    echo "Validating Git installation..."
    validate_git

    echo "Validating local gcloud configuration..."
    validate_gcloud_configuration

    echo "Validating roles assignement for current end user credential..."
    validate_credential_roles

    echo "Validating 0-bootstrap configuration..."
    validate_bootstrap_step

    echo "......................................."
    if [ -z "$ERRORS" ]; then
        echo "Validation successfull!"
        echo "No errors found."
    else
        echo "Validation failed!"
        echo "Errors found:"
        echo "$ERRORS"
    fi
}

main
