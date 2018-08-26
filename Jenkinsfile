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
    stage('Deploy') {
      steps {
        // https://jenkins.io/doc/pipeline/steps/credentials-binding/
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'node-app-aws-credentials'
        ]]) {
          sh 'pwd'
          sh 'cd node-app'
          sh 'terraform init config'
          sh 'terraform apply -auto-approve config'
        }
      }
    }
    stage('Commit') {
      steps {
        // https://jenkins.io/doc/pipeline/steps/credentials-binding/
        withCredentials([[
            $class: 'UsernamePasswordMultiBinding',
            credentialsId: 'node-app-git-credentials',
            usernameVariable: 'REPO_USER',
            passwordVariable: 'REPO_PASS'
        ]]) {
          sh 'pwd'
          sh 'cd node-app'
          sh 'git add terraform.tfstate'
          sh '''
            git \
              -c user.name="Craig Sands" \
              -c user.email="craigsands@gmail.com" \
              commit \
              -m "terraform state update from Jenkins"
          '''
          sh 'git push https://${REPO_USER}:${REPO_PASS}@github.com/craigsands/node-app.git master'
        }
      }
    }
  }
}