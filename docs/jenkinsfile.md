# Understand the Jenkinsfile

The [Jenkinsfile](jenkinsfile.md) is the declarative representation of a pipeline, with the advantage that it can be checked into source control and tracked. See [https://jenkins.io/doc/book/pipeline/jenkinsfile/](https://jenkins.io/doc/book/pipeline/jenkinsfile/) for more information on creating a Jenkinsfile from scratch.

The Jenkinsfile included in this repository provisions an [AWS AMI (Amazon Machine Image)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) using [Packer](https://www.packer.io/) and deploys an [Auto Scaling Group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html) (managed by [CloudFormation](https://aws.amazon.com/cloudformation/)) with [Terraform](https://www.terraform.io/).

The Jenkinsfile included consists of the following structure:

```
pipeline {
  agent { dockerfile true }
  stages {
    stage('Clone') { steps {...} }
    stage('Build') { steps {...} }
    stage('Deploy') { steps {...} }
    stage('Commit') { steps {...} }
  }
}
```

## Agent

An [agent](https://jenkins.io/doc/book/pipeline/syntax/#agent) at the top-level defines what environment the pipeline will run in. Specifying `dockerfile true` instructs Jenkins to build an image from the included [Dockerfile](../Dockerfile) in the root of the repository. Since deploying this application requires Git, Packer, [Ansible](https://www.ansible.com/), and Terraform, the Dockerfile includes the instructions for installing those prerequisites in the docker image.

The remainder of the Jenkinsfile contains the stages (with arbitrary names) and steps needed to complete the deployment process. These stages and steps are all completed within the docker image (agent) container that was built and started earlier.

## Clone

As this repository is the primary source for every component of the application, the first stage clones this repository in the build container (removing an existing clone if one exists).

```
stage('Clone') {
  steps {
    sh 'rm -rf node-app'
    sh 'git clone https://github.com/craigsands/node-app'
  }
}
```

## Build

The second stage builds the AWS AMI using Packer. Since Packer requires access to AWS, the Jenkinsfile includes a class `AmazonWebServicesCredentialsBinding` to bind the AWS credentials specified previously in the Jenkins Credentials section. The credentials are directly referenced by the ID `node-app-aws-credentials`, entered when specifying the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. The `AmazonWebServicesCredentialsBinding` class is provided by the [CloudBees Amazon Web Services Credentials](https://plugins.jenkins.io/aws-credentials) plugin.

With the credentials provided, this step uses shell commands to validate the [template file](../ami.json) and build the AMI.

```
stage('Build') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'node-app-aws-credentials'
    ]]) {
      sh 'packer validate node-app/ami.json'
      sh 'packer build node-app/ami.json'
    }
  }
}
```

## Deploy

```
stage('Deploy') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'node-app-aws-credentials'
    ]]) {
      sh 'cd node-app'
      sh 'terraform init config'
      sh 'terraform apply -auto-approve config'
    }
  }
}
```

## Commit

```
stage('Commit') {
  steps {
    // https://jenkins.io/doc/pipeline/steps/credentials-binding/
    withCredentials([[
        $class: 'UsernamePasswordMultiBinding',
        credentialsId: 'node-app-git-credentials',
        usernameVariable: 'REPO_USER',
        passwordVariable: 'REPO_PASS'
    ]]) {
      sh '''
        cd node-app
        git add terraform.tfstate
        git \
          -c user.name="Craig Sands" \
          -c user.email="craigsands@gmail.com" \
          commit \
          -m "terraform state update from Jenkins"
        git push https://${REPO_USER}:${REPO_PASS}@github.com/craigsands/node-app.git master
      '''
    }
  }
}
```