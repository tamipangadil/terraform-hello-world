# terraform-hello-world

This is a simple hello world project to demonstrate how to use Terraform to deploy a Cloud Run service.

## Prerequisites

- Google Cloud SDK (version 443.0.0)
- Terraform CLI (version 1+)

## tl;dr

Assuming that you have already authenticated yourself with `gcloud auth login` and `gcloud auth application-default login`, you can run the following commands to deploy the hello world service:

```sh
make init
cat > terraform.tfvars <<EOF
project_id = "$(gcloud config get-value project)"
region     = "$(gcloud config get-value compute/region)"
domain     = "hello-world.tamipangadil.com"
lb_name    = "terraform-hello-lb"
EOF
make apply-without-ssl
```

- `make init` will create a new project and set a region for the project.
- `cat > terraform.tfvars <<EOF ...` will generate a global `terraform.tfvars` file for all the terraform modules.
- `make apply-without-ssl` will deploy the hello world service and the load balancer without SSL.

## Manual setup

### Create a new project

```sh
gcloud projects create "terraform-hello-world-1" --name="Terraform Hello World 1"
```

### Configure the project

```sh
gcloud config set project terraform-hello-world-1
gcloud config set compute/region europe-west2
```

### Generate your global terraform.tfvars file

```sh
cat > terraform.tfvars <<EOF
project_id = "$(gcloud config get-value project)"
region     = "$(gcloud config get-value compute/region)"
# ssl        = "false" --> you can enable SSL later, or during terraform apply -var ssl=true
domain     = "hello-world.tamipangadil.com"
lb_name    = "terraform-hello-lb"
EOF
```

### Create the Cloud Run service

```sh
workdir=$(pwd)
cd gcp/run/public-private
terraform init
terraform apply -var ssl=false -var-file=$(workdir)/terraform.tfvars -auto-approve
```

### Create the Load Balancer without SSL

```sh
workdir=$(pwd)
cd gcp/lb/example
terraform init
terraform apply -var ssl=false -var-file=$(workdir)/terraform.tfvars
```
