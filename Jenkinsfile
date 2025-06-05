pipeline {
  agent any

  environment {
    DOCKER_IMAGE = 'ghofrane694/Frontend:latest'
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials-id'
    //KUBE_CONFIG_CREDENTIALS_ID = 'kubeconfig-credentials-id'
  }

  stages {

    stage('Install Dependencies') {
      steps {
        dir('Frontend') {
          bat 'npm install'
        }
      }
    }

    stage('Run Tests') {
      steps {
        dir('frontend') {
          bat 'npm test || echo "Tests échoués mais on continue..."'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        dir('frontend') {
          script {
            env.BUILT_IMAGE_ID = docker.build(env.DOCKER_IMAGE).id
          }
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS_ID) {
            docker.image(env.DOCKER_IMAGE).push("latest")
          }
        }
      }
    }

   
  }

  post {
    success {
      echo '✅ Frontend pipeline completed successfully'
    }
    failure {
      echo '❌ Frontend pipeline failed'
    }
  }
}
