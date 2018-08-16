pipeline {
  agent {
    docker {
      image 'goforgold/build-container:latest'
      args '-v /aws/credentials:/root/aws/credentials'
    }

  }
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
        sh 'packer validate node-app/ami.json'
        sh 'packer build node-app/ami.json'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying'
      }
    }
  }
}