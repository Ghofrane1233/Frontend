pipeline {
  agent any

  environment {
    DOCKER_IMAGE = 'ghofrane694/frontend:latest'
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials-id'
  }

  stages {
    stage('Install Dependencies') {
      steps {
        bat 'npm install'
      }
    }

    stage('Run Unit Test: Login') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          bat 'npm test -- --testPathPattern=Login'
        }
      }
    }

    stage('Run Integration Test: Dashboard') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          bat 'npm test -- --testPathPattern=Dashboard.integration'
        }
      }
    }

    stage('Run All Other Tests') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          bat 'npm test'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          env.BUILT_IMAGE_ID = docker.build(env.DOCKER_IMAGE).id
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
