# node-app

This repository demonstrates the pipeline to deploy a simple web application.

Using Jenkins, an open source automation server, application code can be committed to a git repository and then a deployed to AWS using Hashicorp's Packer and Terraform. Since Terraform creates a CloudFormation stack in AWS, additional commits to modify the application will trigger rolling updates and automatically update the instances in the stack.

Git -> Jenkins -> Packer -> Terraform -> Git

#### Prerequisites

- [docker](https://www.docker.com/)

Everything required to deploy this application is contained in this repository. Any steps requiring external applications other than Docker (i.e., Jenkins, Packer, Ansible, Terraform) have been configured to use containerized versions for convenience.

## Setup

1. Fork this repository
2. [Configure Jenkins](docs/jenkins.md)
3. [Create a pipeline](docs/pipeline.md)
    1. [Build the container](docs/container.md) agent
    2. Clone this repository
    3. [Build with Packer](docs/packer.md)
        1. [Provision with Ansible](docs/ansible.md)
    4. [Deploy with Terraform](docs/terraform.md)
    5. Push terraform.tfstate

## Removal

# Build the container that includes Terraform locally
docker build . -t build-container
docker run ??
docker cp terraform.tfstate build-container:/terraform.tfstate


### Create new branch
git branch {branchname}
git checkout {branchname}

Validate with git branch -a

git add .
git commit -m {message}
git push