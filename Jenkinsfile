pipeline {
  agent any

  environment {
    DOCKER_IMAGE = 'ghofrane694/frontend:latest'
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials-id'
  }

  stages {
    stage('Install Dependencies') {
      steps {
        echo '📦 Installing dependencies...'
        bat 'npm ci'
      }
    }

    stage('Unit Tests') {
      when {
        expression {
          fileExists('package.json') && 
          findFiles(glob: '**/*.test.js').length > 0
        }
      }
      steps {
        echo '🧪 Running unit tests...'
        bat 'npm test -- --watchAll=false'
      }
    }

    stage('Integration Tests') {
      when {
        expression {
          fileExists('package.json') && 
          findFiles(glob: '**/*.integration.test.js').length > 0
        }
      }
      steps {
        echo '🔗 Running integration tests...'
        bat 'npm run test:integration'
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
      echo '✅ Pipeline completed successfully.'
    }
    failure {
      echo '❌ Pipeline failed.'
    }
  }
}
