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
      steps {
        sh 'whoami'
        sh 'pwd'
        sh 'ls -l'
        sh 'docker run -i -t hashicorp/packer validate ami.json'
        sh 'docker run -i -t -v /aws/credentials:/root/aws/credentials hashicorp/packer build ami.json'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying'
      }
    }
  }
}