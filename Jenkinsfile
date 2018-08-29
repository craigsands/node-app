pipeline {
  agent {
    dockerfile true
  }
  stages {
    stage('Clone') {
      steps {
        sh 'rm -rf node-app'
        sh 'git clone https://github.com/craigsands/node-app'
      }
    }
    stage('Deploy-TF-Backend') {
      steps {
        withCredentials(bindings: [[
                      $class: 'AmazonWebServicesCredentialsBinding',
                      credentialsId: 'node-app-aws-credentials'
                  ]]) {
            sh '''
            cd node-app/config/backend
            terraform init
            terraform apply               -auto-approve               -var "aws_region=${AWS_REGION}"               -var "lock_table_name=${LOCK_TABLE_NAME}"               -var "s3_bucket_name=${S3_BUCKET_NAME}"
          '''
          }

        }
      }
      stage('Build-Node-App') {
        steps {
          withCredentials(bindings: [[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'node-app-aws-credentials'
                    ]]) {
              sh '''
            packer validate               -var "aws_region=${AWS_REGION}"               node-app/ami.json
          '''
              sh '''
            packer build               -var "aws_region=${AWS_REGION}"               node-app/ami.json
          '''
            }

          }
        }
        stage('Deploy-Node-App') {
          steps {
            withCredentials(bindings: [[
                          $class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'node-app-aws-credentials'
                      ]]) {
                sh '''
            cd node-app/config/node-app
            terraform init
            terraform apply               -auto-approve               -var "aws_region=${AWS_REGION}"               -var "lock_table_name=${LOCK_TABLE_NAME}"               -var "s3_bucket_name=${S3_BUCKET_NAME}"
          '''
              }

            }
          }
          stage('Commit-TF-Backend-State') {
            steps {
              withCredentials(bindings: [[
                            $class: 'UsernamePasswordMultiBinding',
                            credentialsId: 'node-app-git-credentials',
                            usernameVariable: 'REPO_USER',
                            passwordVariable: 'REPO_PASS'
                        ]]) {
                  sh 'cd node-app'
                  sh 'git add node-app/config/backend/terraform.tfstate'
                  sh '''
            git               -c user.name="Craig Sands"               -c user.email="craigsands@gmail.com"               commit               -m "terraform backend state update from Jenkins"
          '''
                  sh 'git push https://${REPO_USER}:${REPO_PASS}@github.com/craigsands/node-app.git master'
                }

              }
            }
          }
          environment {
            AWS_REGION = 'us-east-1'
            S3_BUCKET_NAME = 'node-app-tf-state-nm1ruznhbx2l'
            LOCK_TABLE_NAME = 'tf-state-lock'
          }
        }