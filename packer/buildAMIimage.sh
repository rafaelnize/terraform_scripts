#!/bin/bash
packer build -var-file=/home/terraform/env_vars/packer.tfvars ec2image.json
