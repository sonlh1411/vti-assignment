# Config infra
1. Update s3 info to save tfstate (backend.tf)

2. Update tfvars file

3. Update command variable
    - TFVAR_FILE=

4. Run command
    - terraform init
    - terraform plan -var-file=$TFVAR_FILE
    - terraform apply -var-file=$TFVAR_FILE -auto-approve