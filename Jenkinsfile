pipeline {
  agent any
  stages {
    stage('Clone') {
      steps {
        sh 'whoami'
        sh 'pwd'
        sh 'ls -l'
        sh 'rm -rf node-app'
        sh 'git clone https://github.com/craigsands/node-app'
      }
    }
    stage('Build') {
      agent {
        docker {
          image 'hashicorp/packer:light'
          args '-v /aws/credentials:/root/aws/credentials'
        }

      }
      steps {
        sh 'whoami'
        sh 'pwd'
        sh 'ls -l'
        sh 'packer validate ami.json'
        sh 'packer build ami.json'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying'
      }
    }
  }
}