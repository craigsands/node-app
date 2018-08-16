pipeline {
  agent {
    docker {
      image 'goforgold/build-container:latest'
      args '-v /root/.aws:/root/.aws'
    }

  }
  stages {
    stage('test') {
      steps {
        withCredentials(bindings: [[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'node-app-aws-credentials']]) {
          sh 'env'
          sh 'aws s3 ls'
        }

      }
    }
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
        sh 'echo $AWS_ACCESS_KEY_ID'
        sh 'echo $AWS_SECRET_ACCESS_KEY'
        sh 'whoami'
        sh 'pwd'
        sh 'ls -l'
        sh 'packer validate node-app/ami.json'
        sh 'ls -la /'
        sh 'ls -la /root/'
        sh 'ls -la /root/.aws/'
        sh 'echo \'hi\' #cat /root/.aws/credentials'
        sh 'echo \'hi\' #packer build node-app/ami.json'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying'
      }
    }
  }
}