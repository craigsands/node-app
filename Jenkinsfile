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
      steps {
        //sh 'git clone https://github.com/craigsands/node-app'
        sh 'ls -l'
        checkout scm
        sh 'ls -l'
        stash includes: '**', name: 'node-app-dir'
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
          stash includes: 'terraform.tfstate', name: 'tfstate'
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
          unstash 'tfstate'
          sh '''
            mv terraform.tfstate node-app/config/backend/terraform.tfstate
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
}