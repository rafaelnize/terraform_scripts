#!/bin/bash
cd modules/mongodb/
terraform get
terraform plan --var-file=/home/terraform/env_vars/secret.tfvars 
terraform apply --var-file=/home/terraform/env_vars/secret.tfvars
