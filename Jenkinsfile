pipeline {
    agent any

    environment {
        SONAR_QUBE_TOKEN = credentials('SONAR_QUBE_TOKEN')
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
                sh 'python3 -m venv venv'
                sh 'venv/bin/python -m pip install --upgrade pip'
                sh 'venv/bin/pip install -r requirements.txt'
                echo 'Build stage completed successfully!'
            }
        }

        stage('Test') {
            steps {
                echo 'Running automated tests...'
                sh 'venv/bin/python test_app.py'
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
                    sh '''
                    sonar-scanner \
                        -Dsonar.projectKey=SIT753-7.3HD \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.token=${SONAR_QUBE_TOKEN}
                    '''
                }
            }
        }

        stage('Security') {
            steps {
                echo 'Running security analysis with Bandit...'
                sh 'venv/bin/pip install bandit'
                sh 'venv/bin/bandit -r . -f html -o security_report.html'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'security_report.html', fingerprint: true
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    echo "Current branch: ${branch}"

                    if (branch.equalsIgnoreCase('main')) {
                        echo 'Deploying application to staging environment...'
                        sh 'docker compose -f docker-compose.staging.yml up -d --build'
                        echo 'Staging deployment completed successfully!'
                    } else {
                        echo "Skipping staging deployment: not on main branch."
                    }
                }
            }
        }

        stage('Release') {
            steps {
                script {
                    echo 'Promoting application to production...'
                    sh 'docker compose -f docker-compose.prod.yml up -d --build'
                    echo 'Production deployment completed successfully!'
                }
            }
        }

        stage('Monitoring & Alerting') {
            steps {
                script {
                    echo 'Checking if production app is running...'
                    def response = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:8081', returnStdout: true).trim()

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
    }
}