pipeline {
  agent any

  environment {
    NODE_ENV = "test"
  }

  stages {
    stage('Unit Tests') {
      when {
        expression {
          return fileExists('package.json') &&
                 bat(script: 'ls **/*.test.js > /dev/null 2>&1', returnStatus: true) == 0
        }
      }
      steps {
        echo "Installing dependencies for unit tests..."
        bat 'npm ci'
        echo "Running unit tests..."
        bat 'npm test -- --watchAll=false'
      }
    }

    stage('Integration Tests') {
      when {
        expression {
          return fileExists('package.json') &&
                 bat(script: 'ls **/*.integration.test.js > /dev/null 2>&1', returnStatus: true) == 0
        }
      }
      steps {
        echo "Installing dependencies for integration tests..."
        bat 'npm ci'
        echo "Running integration tests..."
        bat 'npm run test:integration'
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "Build step here"
        // example: bat 'docker build -t myimage .'
      }
    }

    stage('Push to Docker Hub') {
      steps {
        echo "Push step here"
        // example: bat 'docker push myimage'
      }
    }
  }

  post {
    failure {
      echo "❌ Pipeline failed."
    }
  }
}
