# node-app

This repository demonstrates the pipeline to deploy a simple web application.

Using Jenkins, an open source automation server, application code can be committed to a git repository and then a deployed to AWS using Hashicorp's
Packer and Terraform. Since Terraform creates a CloudFormation stack in AWS, additional commits to modify the application will trigger rolling updates and automatically update the instances in the stack.

Git -> Jenkins -> Packer -> Terraform -> Git

![Packer](docs/static/Packer_PrimaryLogo_FullColor.png)

#### Prerequisites

- [docker]()

## Setup

1. [Start Jenkins](docs/jenkins.md)


### Create credential entries

AWS

**images

Github

**images

### Create pipeline from Github repo

**images

### Remove project

Get latest `terraform.tfstate` file

```git pull```

Destroy the deployment

```
terraform init config
terraform destroy -auto-approve config
```

(Don't forget to deregister the AMI)



### Create new branch
git branch {branchname}
git checkout {branchname}

Validate with git branch -a

git add .
git commit -m {message}
git push