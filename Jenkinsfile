pipeline {
  agent {
    docker {
      image 'goforgold/build-container'
    }

  }
  stages {
    stage('Clone') {
      steps {
        sh 'rm -rf node-app'
        sh 'git clone https://github.com/craigsands/node-app'
      }
    }
    stage('Build') {
      agent {
        docker {
          image 'hashicorp/packer:light'
          args '-i -t'
        }

      }
      steps {
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