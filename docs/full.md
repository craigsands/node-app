# node-app

This repository demonstrates the pipeline to deploy a simple web application.

Using Jenkins, an open source automation server, application code can be committed to a git repository and then a deployed to AWS using Hashicorp's Packer and Terraform. Since Terraform creates a CloudFormation stack in AWS, additional commits to modify the application will trigger rolling updates and automatically update the instances in the stack.

<img src="docs/static/overview.png" width="800">

#### Prerequisites

- [docker](https://www.docker.com/)

Everything required to deploy this application is contained in this repository. Any steps requiring external applications other than Docker (i.e., Jenkins, Packer, Ansible, Terraform) have been configured to use containerized versions for convenience.

## Overview

1. Fork this repository
2. [Configure Jenkins](docs/jenkins.md)
3. [Create a pipeline](docs/pipeline.md)
    1. Import a [Jenkinsfile](docs/jenkinsfile.md) if present, or
    2. Add steps using the Blue Ocean UI
        1. Build the container agent from a [Dockerfile](Dockerfile)
        2. Clone this repository
        3. Deploy the [Terraform S3 Backend](https://www.terraform.io/docs/backends/types/s3.html)
        4. Commit the backend to the repository
        5. Build the app with [Packer](https://www.packer.io/)
            1. Provision with [Ansible](https://www.ansible.com/)
        6. Deploy the app with [Terraform](https://www.terraform.io/)

## Result

<img src="docs/static/node-app.png" width="800">

# Configure Jenkins

This guide uses the docker container for Jenkins' [Blue Ocean](https://jenkins.io/projects/blueocean/), specifically designed as a simplified GUI for the Jenkins Pipeline.

## Installation

[Jenkins](https://jenkins.io/) can be run as a remote server, or in this case, locally using [docker](https://www.docker.com/).

### Start the container

The following command runs the Jenkins server in the background with the name `docker-jenkins` for easy access. On the first run, a docker [volume](https://docs.docker.com/storage/volumes/) called `jenkins-data` is created and mounted as the Jenkins home directory.

##### Linux

```bash
docker run \
  -d \
  --name docker-jenkins \
  -u root \
  -p 8080:8080 \
  -v jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean
```


##### Windows

```cmd
docker run ^
  -d ^
  --name docker-jenkins ^
  -u root ^
  -p 8080:8080 ^
  -v jenkins-data:/var/jenkins_home ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  jenkinsci/blueocean
```

After startup, the server's web portal can be accessed via [http://localhost:8080](http://localhost:8080).

Note: Since Jenkins will be running in docker, and docker will also be utilized within the Jenkins pipeline to run [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/), it is also important to mount `docker.sock` from the host. That way, the docker controller in Jenkins uses the host's docker daemon to run its containers.

### Get the admin password

<img src="static/unlock.jpg" width="400">

The admin password for Jenkins is created when the container is started with a new volume. If running Jenkins in the foreground, you'll get the following message toward the end of the output:

```bash
Please use the following password to proceed to installation:

(redacted)

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

If running Jenkins in the background, you can access the admin password with this command:

##### Linux

```bash
docker exec -it docker-jenkins \
  /bin/bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
```

##### Windows

```cmd
docker exec -it docker-jenkins ^
  /bin/bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
```

### Install default plugins

Selecting the default plugins is fine for now, only one other plugin is required, which will be installed later.

<img src="static/customize.jpg" width="400">

<img src="static/default-plugins.jpg" width="400">

### Finish installation

Create a user account for Jenkins, or 'Continue as admin' (bottom right) with the admin password from earlier.

<img src="static/continue-as-admin.jpg" width="400">

Since Jenkins is running in a container with port 8080 mapped, the URL [http://localhost:8080](http://localhost:8080) is fine.

<img src="static/url.jpg" width="400">

<img src="static/jenkins-home.jpg" width="400">

### Install CloudBees AWS Credentials plugin

The only required plugin, CloudBees AWS Credentials will allow binding AWS credentials to steps in the pipeline so that Packer and Terraform can access AWS as an IAM user. In the Jenkins side menu, click 'Manage Jenkins', scroll down halfway, and click 'Manage Plugins'.

<img src="static/manage-plugins.jpg" width="400">

Select the available tab, and enable the [CloudBees Amazon Web Services Credentials](https://plugins.jenkins.io/aws-credentials) plugin. Then click 'Install without restart'.

<img src="static/cloudbees-aws-credentials-plugin.jpg" width="400">

### Add credentials to Jenkins

In the credentials section, you can click the down arrow next to the Jenkins Provider's (global) store.

<img src="static/credentials-home.jpg" width="400">

Or click directly on the Jenkins Provider, and there is a option to 'Add Credentials' in the left menu. 

<img src="static/credentials-global.jpg" width="400">

#### Github

To allow Jenkins (and the build-container agent) access to checkout this repository from Github, enter a Github username and personal access token for the password. Use 'node-app-git-credentials' as the ID, as it is referenced in the [Jenkinsfile](../Jenkinsfile).

<img src="static/git-credentials.jpg" width="400">

#### AWS

Follow the same steps above, then select 'AWS Credentials' from the 'Kind' dropdown. Use 'node-app-aws-credentials' as the ID, as it is referenced in the [Jenkinsfile](../Jenkinsfile). Note: No modifications to 'Advanced...' settings or 'IAM Role Support' are required.

<img src="static/aws-credentials.jpg" width="400">

# Create a pipeline

A pipeline is the CI/CD component of Jenkins. Jenkins' Blue Ocean makes creating pipelines (and their Jenkinsfile representations) simple. User's can create a pipeline from a straightforward UI, and then export that pipeline as a [Jenkinsfile](jenkinsfile.md).

<img src="static/jenkins-home.jpg" width="400">

From the Jenkins home screen, click 'Blue Ocean' in the left menu or use the URL [http://localhost:8080/blue/organizations/jenkins](http://localhost:8080/blue/organizations/jenkins).

<img src="static/blue-ocean-home.jpg" width="400">

Click 'Create a new Pipeline' and select from a list of Git providers. For this repository, select 'Github'.

<img src="static/hosting-provider.jpg" width="400">

Jenkins needs access to the Github repository via an access token. Clicking on 'Create an access token here', will take you to the personal access token page in Github, and pre-select the specific permissions required for working with Jenkins. 

<img src="static/github-token.jpg" width="400">

After importing a Github personal access token, select the appropriate organization and repository containing the application when prompted.

<img src="static/organization.jpg" width="400">

<img src="static/repository.jpg" width="400">

Jenkins then searches the repository for an existing Jenkinsfile. If none exist in the repository selected, Jenkins will start a new one. (In the below screenshot, a separate project, 'docker-jenkins', did not contain a Jenkinsfile.)

<img src="static/new-pipeline.jpg" width="400">

Otherwise, the pipeline will be built from the Jenkinsfile. (This repository, 'node-app' has one in the project root.)

<img src="static/creating-pipeline.jpg" width="400">

Once the pipeline is created, Jenkins will start the pipeline.

<img src="static/first-pipeline.jpg" width="400">

You can then click on it to view the status step-by-step.

<img src="static/pipeline-in-progress.jpg" width="400">

<img src="static/pipeline-complete.jpg" width="400">

Following a successful deployment, the node-app can be accessed by its AWS ELB (Elastic Load Balancer).

<img src="static/deployed-app.jpg" width="400">

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
