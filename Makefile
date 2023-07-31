SHELL=/bin/bash
IMAGE_TAG=latest
PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
ifndef CI
DOCKER_IT=-it
endif

devops/terraform/fmt:
	terraform -chdir=terraform fmt -recursive -diff

devops/terraform/init:
	terraform -chdir=terraform/core init

devops/terraform/plan:
	terraform -chdir=terraform/core plan -out=tfplan

devops/terraform/apply:
	terraform -chdir=terraform/core apply -auto-approve

devops/terraform/redeploy/reth_archive_node_vm_datadir_disk/%:
	terraform -chdir=terraform/core apply \
	-replace=module.reth_archive_node_vm[\"$*\"].google_compute_disk.datadir \
	-target=module.reth_archive_node_vm[\"$*\"].google_compute_disk.datadir

devops/terraform/redeploy/reth_archive_node_vm/%:
	terraform -chdir=terraform/core apply \
	-replace=module.reth_archive_node_vm[\"$*\"].google_compute_instance.this \
	-replace=module.reth_archive_node_vm[\"$*\"].google_compute_disk.boot \
	-target=module.reth_archive_node_vm[\"$*\"].google_compute_instance.this \
	-target=module.reth_archive_node_vm[\"$*\"].google_compute_disk.boot \
	-target=module.reth_archive_node_vm[\"$*\"]

devops/terraform/redeploy/lighthouse_node_vm/%:
	terraform -chdir=terraform/core apply \
	-replace=module.lighthouse_node_vm[\"$*\"].google_compute_instance.this \
	-replace=module.lighthouse_node_vm[\"$*\"].google_compute_disk.boot \
	-target=module.lighthouse_node_vm[\"$*\"].google_compute_instance.this \
	-target=module.lighthouse_node_vm[\"$*\"].google_compute_disk.boot \
	-target=module.lighthouse_node_vm[\"$*\"]

devops/terraform/redeploy/nodes: devops/terraform/redeploy/reth_archive_node_vm/node1

devops/terraform/output:
	terraform -chdir=terraform/core output

lint/terraform:
	terraform -chdir=terraform fmt -recursive -check -diff

lint/node:
	npx prettier --check *.md

lint: lint/node lint/terraform

format/node:
	npx prettier --write *.md

format/terraform: devops/terraform/fmt

format: format/node format/terraform
