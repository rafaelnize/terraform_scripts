#!/bin/bash

cd modules/web_autoscaling/
terraform plan --var-file=/home/terraform/env_vars/secret.tfvars
terraform apply --var-file=/home/terraform/env_vars/secret.tfvars

