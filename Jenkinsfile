pipeline {
  agent {
    docker {
      image 'goforgold/build-container'
    }

  }
  stages {
    stage('Build') {
      steps {
        echo 'Building'
        sh 'terraform init'
      }
    }
    stage('Test') {
      steps {
        echo 'Testing'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying'
      }
    }
  }
}