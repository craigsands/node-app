pipeline {
  agent {
    dockerfile true
  }
  environment {
    AWS_REGION = 'us-east-1'
    S3_BUCKET_NAME  = 'node-app-tf-state-nm1ruznhbx2l'
    LOCK_TABLE_NAME = 'tf-state-lock'
    TF_LOG = 'DEBUG'
  }
  stages {
    stage('Clone') {
      steps {
        checkout scm
      }
    }
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
  }
}