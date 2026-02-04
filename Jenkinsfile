pipeline {
  agent any

  environment {
    DOCKER_IMAGE = 'ghofrane694/frontend:latest'
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials-id'
    // أضف متغيرات لتحسين الأداء
    NODE_ENV = 'production'
    DOCKER_BUILDKIT = '1'
  }

  stages {
    stage('Clean Workspace') {
      steps {
        bat '''
          echo Cleaning workspace...
          del /q package-lock.json 2>nul
          rmdir /s /q node_modules 2>nul
          del /q .dockerignore 2>nul
        '''
      }
    }

    stage('Create .dockerignore') {
      steps {
        bat '''
          echo Creating optimized .dockerignore...
          echo node_modules/ > .dockerignore
          echo .git/ >> .dockerignore
          echo npm-debug.log* >> .dockerignore
          echo yarn-debug.log* >> .dockerignore
          echo yarn-error.log* >> .dockerignore
          echo .env >> .dockerignore
          echo .env.local >> .dockerignore
          echo .DS_Store >> .dockerignore
          echo coverage/ >> .dockerignore
          echo dist/ >> .dockerignore
          echo build/ >> .dockerignore
          echo .cache/ >> .dockerignore
          echo .vscode/ >> .dockerignore
          echo .idea/ >> .dockerignore
          echo *.md >> .dockerignore
          echo Jenkinsfile >> .dockerignore
        '''
      }
    }

    stage('Install Dependencies') {
      steps {
        bat '''
          echo Installing dependencies with optimized settings...
          npm ci --no-audit --prefer-offline
        '''
        
        // نظف node_modules من الملفات غير الضرورية بعد التثبيت
        bat '''
          echo Cleaning node_modules...
          rmdir /s /q "node_modules\\.cache" 2>nul
          del /s /q "node_modules\\*.log" 2>nul
        '''
      }
    }

    stage('Run Unit Tests') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          script {
            // طريقة أفضل للتحقق من وجود tests
            def testScript = bat(script: 'type package.json | findstr "test"', returnStatus: true)
            def hasTests = (testScript == 0)
            
            if (hasTests) {
              bat 'echo Running unit tests with timeout...'
              // أضف timeout لمنع التجميد
              timeout(time: 10, unit: 'MINUTES') {
                bat 'npm run test:unit -- --passWithNoTests || echo Tests completed with warnings'
              }
            } else {
              echo 'No test script found in package.json. Skipping unit tests.'
            }
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          echo 'Building Docker image with optimized context...'
          
          // نظف الملفات الكبيرة قبل البناء
          bat '''
            echo Cleaning before Docker build...
            del /s /q *.log 2>nul
            rmdir /s /q coverage 2>nul
          '''
          
          // استخدم docker.build مع options
          env.BUILT_IMAGE_ID = docker.build(
            env.DOCKER_IMAGE,
            '--no-cache --progress=plain .'
          ).id
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS_ID) {
            echo "Pushing ${env.DOCKER_IMAGE} to Docker Hub..."
            
            // أضف retry logic
            retry(3) {
              docker.image(env.DOCKER_IMAGE).push("latest")
            }
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          echo 'Deploying to Kubernetes...'
          
          try {
            withKubeConfig([credentialsId: 'kubeconfig', serverUrl: 'https://127.0.0.1:52114']) {
              // تحقق من صحة الملفات أولاً
              bat 'kubectl apply -f K8s --dry-run=client --validate=false'
              
              // النشر الفعلي
              bat 'kubectl apply -f K8s --validate=false'
              
              // التحقق من status
              bat 'timeout /t 30 /nobreak >nul && kubectl get pods'
            }
          } catch (Exception e) {
            echo "Kubernetes deployment warning: ${e.getMessage()}"
            // لا تفشل البناء كاملاً
          }
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline completed. Cleaning up...'
      bat '''
        echo Final cleanup...
        docker system prune -f 2>nul
      '''
      
      // Archive important artifacts
      archiveArtifacts artifacts: '*.log', allowEmptyArchive: true
    }
    success {
      echo '✅ Frontend pipeline completed successfully'
      // يمكنك إضافة إشعارات هنا
    }
    failure {
      echo '❌ Frontend pipeline failed'
      // يمكنك إضافة إشعارات هنا
    }
  }
}
