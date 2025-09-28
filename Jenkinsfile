pipeline {
    agent any

    environment {
        SONAR_QUBE_TOKEN = credentials('SONAR_QUBE_TOKEN')
        FLASK_PORT = '8081'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/NaveenSukhavasi/SIT753-7.3HD.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Build') {
            steps {
                echo 'Setting up Python environment and installing dependencies...'
                bat 'python -m venv venv'
                bat 'venv\\Scripts\\python -m pip install --upgrade pip'
                bat 'venv\\Scripts\\pip install -r requirements.txt'
                echo 'Build stage completed successfully!'
            }
        }

        stage('Test') {
            steps {
                echo 'Starting Flask app in background for integration tests...'
                bat 'start /B venv\\Scripts\\python app.py'
                echo 'Running unit tests with coverage...'
                bat 'venv\\Scripts\\pytest --cov=app --cov-report xml:coverage.xml test_app.py'
            }
        }

        stage('Hello') {
            steps {
                echo 'Jenkins is connected to GitHub successfully!'
            }
        }

        stage('Code Quality') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat """
                        sonar-scanner ^
                            -Dsonar.projectKey=SIT753-7.3HD ^
                            -Dsonar.sources=. ^
                            -Dsonar.host.url=http://localhost:9000 ^
                            -Dsonar.login=%SONAR_QUBE_TOKEN% ^
                            -Dsonar.python.coverage.reportPaths=coverage.xml
                    """
                }
            }
        }

        stage('Security') {
            steps {
                echo 'Running security analysis with Bandit...'
                bat 'venv\\Scripts\\pip install bandit'
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    bat 'venv\\Scripts\\bandit -r . -f html -o security_report.html'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'security_report.html', fingerprint: true
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                expression { env.BRANCH_NAME == 'main' || !env.BRANCH_NAME }
            }
            steps {
                echo 'Deploying application to staging environment...'
                bat 'docker compose -f docker-compose.staging.yml up -d --build'
                echo 'Staging deployment completed successfully!'
            }
        }

        stage('Release to Production') {
            when {
                expression { env.BRANCH_NAME == 'main' || !env.BRANCH_NAME }
            }
            steps {
                echo 'Promoting application to production...'
                bat 'docker compose -f docker-compose.prod.yml up -d --build'
                echo 'Production deployment completed successfully!'
            }
        }

        stage('Monitoring & Alerting') {
            steps {
                script {
                    echo 'Checking if production app is running...'
                    def response = bat(script: "curl -s -o NUL -w \"%{http_code}\" http://localhost:%FLASK_PORT%", returnStdout: true).trim().replaceAll("\\r","")
                    if (response != '200') {
                        error "ALERT: Production application is NOT responding! HTTP status: ${response}"
                    } else {
                        echo 'Production application is healthy. HTTP 200 OK.'
                    }
                }
            }
        }

    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        cleanup {
            echo 'Stopping background Flask app if running...'
            bat 'taskkill /F /IM python.exe || echo Flask app not running'
        }
    }
}