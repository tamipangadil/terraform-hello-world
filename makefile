# add run command to trigger Terraform to run

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

.PHONY: apply-without-ssl apply-with-ssl destroy

init:
	gcloud projects create "terraform-hello-world-1" --name="Terraform Hello World 1"
	gcloud config set project terraform-hello-world-1
	gcloud config set compute/region europe-west2

apply-without-ssl:
	cd $(mkfile_dir)gcp/run/public-private \
		&& terraform init \
		&& terraform apply -var-file="$(mkfile_dir)terraform.tfvars" -auto-approve
	cd $(mkfile_dir)gcp/lb/example \
		&& terraform init \
		&& terraform apply -var ssl="false" -var-file="$(mkfile_dir)terraform.tfvars" -auto-approve

apply-with-ssl:
	cd $(mkfile_dir)gcp/run/public-private \
		&& terraform init \
		&& terraform apply -var-file="$(mkfile_dir)terraform.tfvars" -auto-approve
	cd $(mkfile_dir)gcp/lb/example \
		&& terraform init \
		&& terraform apply -var ssl="true" -var-file="$(mkfile_dir)terraform.tfvars" -auto-approve

destroy:
	cd $(mkfile_dir)gcp/run/public-private \
		&& terraform init \
		&& terraform destroy -var-file="$(mkfile_dir)terraform.tfvars" -auto-approve
	cd $(mkfile_dir)gcp/lb/example \
		&& terraform init \
		&& terraform destroy -var-file="$(mkfile_dir)terraform.tfvars" -auto-approve
