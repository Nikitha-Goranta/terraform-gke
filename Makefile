# Makefile for GKE Terraform project

.PHONY: help init plan apply destroy validate fmt clean get-credentials

# Default target
help: ## Display this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Terraform commands
init: ## Initialize Terraform
	terraform init

validate: ## Validate Terraform configuration
	terraform validate

fmt: ## Format Terraform files
	terraform fmt -recursive

plan: ## Plan Terraform deployment
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy Terraform infrastructure
	terraform destroy

# Utility commands
clean: ## Clean Terraform files
	rm -rf .terraform/
	rm -f terraform.tfstate*
	rm -f .terraform.lock.hcl

get-credentials: ## Get GKE cluster credentials
	@echo "Getting cluster credentials..."
	@PROJECT_ID=$$(terraform output -raw project_id 2>/dev/null || echo "your-project-id"); \
	CLUSTER_NAME=$$(terraform output -raw cluster_name 2>/dev/null || echo "my-gke-cluster"); \
	CLUSTER_LOCATION=$$(terraform output -raw cluster_location 2>/dev/null || echo "us-central1"); \
	gcloud container clusters get-credentials $$CLUSTER_NAME --location=$$CLUSTER_LOCATION --project=$$PROJECT_ID

check-cluster: ## Check cluster status
	kubectl get nodes
	kubectl get pods --all-namespaces

# Setup commands
setup-gcp: ## Setup GCP project and APIs
	@read -p "Enter your GCP Project ID: " PROJECT_ID; \
	gcloud config set project $$PROJECT_ID; \
	gcloud services enable container.googleapis.com compute.googleapis.com servicenetworking.googleapis.com

create-tfvars: ## Create terraform.tfvars from example
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "Created terraform.tfvars from example. Please edit it with your values."; \
	else \
		echo "terraform.tfvars already exists."; \
	fi