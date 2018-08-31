# Understand the Jenkinsfile

The [Jenkinsfile](jenkinsfile.md) is the declarative representation of a pipeline, with the advantage that it can be checked into source control and tracked. See [https://jenkins.io/doc/book/pipeline/jenkinsfile/](https://jenkins.io/doc/book/pipeline/jenkinsfile/) for more information on creating a Jenkinsfile from scratch.

The Jenkinsfile included in this repository provisions an [AWS AMI (Amazon Machine Image)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) using [Packer](https://www.packer.io/) and deploys an [Auto Scaling Group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html) (managed by [CloudFormation](https://aws.amazon.com/cloudformation/)) with [Terraform](https://www.terraform.io/).

The Jenkinsfile included consists of the following structure:

```
pipeline {
  agent { dockerfile true }
  environment {}  // environment variables
  stages {
    stage('Clone') { steps {...} }
    stage('Deploy-TF-Backend') { steps {...} }
    stage('Commit-TF-Backend-State') { steps {...} }
    stage('Build-Node-App') { steps {...} }
    stage('Deploy-Node-App') { steps {...} }
  }
}
```

## Agent

An [agent](https://jenkins.io/doc/book/pipeline/syntax/#agent) at the top-level defines what environment the pipeline will run in. Specifying `dockerfile true` instructs Jenkins to build an image from the included [Dockerfile](../Dockerfile) in the root of the repository. Since deploying this application requires Git, Packer, [Ansible](https://www.ansible.com/), and Terraform, the Dockerfile includes the instructions for installing those prerequisites in the docker image.

The remainder of the Jenkinsfile contains the stages (with arbitrary names) and steps needed to complete the deployment process. These stages and steps are all completed within the docker image (agent) container.

## Clone

As this repository is the primary source for every component of the application, the first stage clones this repository in the build container.

```
stage('Clone') {
  steps {
    checkout scm
  }
}
```

## Deploy-TF-Backend

Terrafrom uses a `.tfstate` file for keeping track of the AWS resources that were created. By default, the `.tfstate` file is saved in the current working directory. However, Terraform allows for configuring 'backends' for keeping remote state. For this node-app, the state will be saved in an S3 bucket with versioning (as part of the node-app deployment, the final stage of this pipeline). Since the S3 bucket needs to be created, along with a DynamoDb table for locking while Terraform is running, Terraform can be used for that as well. For the S3 and DynamoDb table creation, Terraform will use the `.tf` files in [`config/backend`](../config/backend).

Since Terraform requires access to AWS, the Jenkinsfile includes a class `AmazonWebServicesCredentialsBinding` to bind the AWS credentials specified previously in the Jenkins Credentials section. The credentials are directly referenced by the ID `node-app-aws-credentials`, entered when specifying the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. The `AmazonWebServicesCredentialsBinding` class is provided by the [CloudBees Amazon Web Services Credentials](https://plugins.jenkins.io/aws-credentials) plugin, and automatically adds the credentials as environment variables.

Since the build container is built on demand, the `config/backend` directory is initialized with Terraform first, then applied.

```
stage('Deploy-TF-Backend') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'node-app-aws-credentials'
    ]]) {
      sh '''
        cd config/backend
        terraform init
        terraform apply \
          -auto-approve \
          -var "aws_region=${AWS_REGION}" \
          -var "lock_table_name=${LOCK_TABLE_NAME}" \
          -var "s3_bucket_name=${S3_BUCKET_NAME}"
      '''
    }
  }
}
```

## Commit-TF-Backend-State

After the S3 and DynamoDb deployment process is complete, Terraform wrote the state to a local `terraform.tfstate` file. S3 will be used for the backend state for the node-app, but this deployment's state file can be committed to the original (or another) repository for reference and version control. Since committing the file to Github, the `UsernamePasswordMultiBinding` class is used (directly referenced by the ID `node-app-git-credentials`) to allow the step to push the Terraform state file into the repository. Unlike the CloudBees AWS credentials plugin, variables for the username and password are explicitly defined (in this case `REPO_USER` and `REPO_PASS`), and then used in the following shell steps.

```
stage('Commit-TF-Backend-State') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'UsernamePasswordMultiBinding',
        credentialsId: 'node-app-git-credentials',
        usernameVariable: 'REPO_USER',
        passwordVariable: 'REPO_PASS'
    ]]) {
      sh '''
        git add config/backend/terraform.tfstate
        git \
          -c user.name="Craig Sands" \
          -c user.email="craigsands@gmail.com" \
          commit \
          -m "terraform backend state update from Jenkins"
        git push https://${REPO_USER}:${REPO_PASS}@github.com/craigsands/node-app.git master
      '''
    }
  }
}
```

## Build-Node-App

The fourth stage builds the AWS AMI using Packer. Packer also requires access to AWS, and uses the same CloudBees Amazon Web Services Credentials plugin as the previous Terraform stage. This step uses shell commands to validate the [template file](../ami.json) and build the AMI.

```
stage('Build-Node-App') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'node-app-aws-credentials'
    ]]) {
      sh '''
        packer validate \
          -var "aws_region=${AWS_REGION}" \
          ami.json
      '''
      sh '''
        packer build \
          -var "aws_region=${AWS_REGION}" \
          ami.json
      '''
    }
  }
}
```

## Deploy

The final stage again binds AWS credentials so that Terraform can build the appropriate resources in AWS. The [Terraform code](../config/node-app) references the AMI built in the previous step to use in the deployment. This stage deploys the resources necessary to create an Auto Scaling Group managed by CloudFormation.

```
stage('Deploy-Node-App') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'node-app-aws-credentials'
    ]]) {
      sh '''
        cd config/node-app
        terraform init \
          -backend-config="region=${AWS_REGION}" \
          -backend-config="bucket=${S3_BUCKET_NAME}" \
          -backend-config="dynamodb_table=${LOCK_TABLE_NAME}"
        terraform apply \
          -auto-approve \
          -var "aws_region=${AWS_REGION}"
      '''
    }
  }
}
```
