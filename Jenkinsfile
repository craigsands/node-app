pipeline {
  agent {
    docker {
      image 'goforgold/build-container:latest'
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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'node-app-aws-credentials']]) {
          sh 'echo $AWS_ACCESS_KEY_ID'
          sh 'echo $AWS_SECRET_ACCESS_KEY'
          sh 'whoami'
          sh 'pwd'
          sh 'ls -l'
          sh 'packer validate node-app/ami.json'
          sh 'echo \'hi\' #packer build node-app/ami.json'
        }
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying'
      }
    }
  }
}