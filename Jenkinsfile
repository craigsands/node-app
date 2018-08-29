pipeline {
  agent {
    dockerfile true
  }
  environment {
    AWS_REGION = 'us-east-1'
    S3_BUCKET_NAME  = 'node-app-tf-state-nm1ruznhbx2l'
    LOCK_TABLE_NAME = 'tf-state-lock'
  }
  stages {
    stage('Clone') {
      node() {
        steps {
          sh 'rm -rf node-app'
          sh 'git clone https://github.com/craigsands/node-app'
        }
      }
    }
    stage('Deploy-TF-Backend') {
      node() {
        steps {
          // https://jenkins.io/doc/pipeline/steps/credentials-binding/
          withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'node-app-aws-credentials'
          ]]) {
            sh '''
              cd node-app/config/backend
              terraform init
              terraform apply \
                -auto-approve \
                -var "aws_region=${AWS_REGION}" \
                -var "lock_table_name=${LOCK_TABLE_NAME}" \
                -var "s3_bucket_name=${S3_BUCKET_NAME}"
            '''
          }
          //stash {
          //  includes: 'dist/**/*',
          //  name: 'builtSources'
          //}
        }
      }
    }
    stage('Commit-TF-Backend-State') {
      node() {
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
    }
    stage('Build-Node-App') {
      node() {
        steps {
          // https://jenkins.io/doc/pipeline/steps/credentials-binding/
          withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'node-app-aws-credentials'
          ]]) {
            sh '''
              packer validate \
                -var "aws_region=${AWS_REGION}" \
                node-app/ami.json
            '''
            sh '''
              packer build \
                -var "aws_region=${AWS_REGION}" \
                node-app/ami.json
            '''
          }
        }
      }
    }
    stage('Deploy-Node-App') {
      node() {
        steps {
          // https://jenkins.io/doc/pipeline/steps/credentials-binding/
          withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'node-app-aws-credentials'
          ]]) {
            sh '''
              cd node-app/config/node-app
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
    }
  }
}