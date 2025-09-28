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
                bat 'python -m venv venv'
                bat 'venv\\Scripts\\pip install -r requirements.txt'
                echo 'Build stage completed successfully!'
            }
        }

        stage('Test') {
            steps {
                echo 'Running automated tests...'
                bat 'venv\\Scripts\\python test_app.py'
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
                    bat 'sonar-scanner -Dsonar.projectKey=SIT753-7.3HD ' +
                        '-Dsonar.sources=. ' +
                        '-Dsonar.host.url=http://localhost:9000 ' +
                        "-Dsonar.login=${env.SONAR_QUBE_TOKEN}"
                }
            }
        }

        stage('Security') {
            steps {
                echo 'Running security analysis with Bandit...'
                bat 'venv\\Scripts\\pip install bandit'
                bat(script: 'venv\\Scripts\\bandit -r . -f html -o security_report.html', returnStatus: true)
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
                    def branch = env.BRANCH_NAME ?: bat(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    echo "Current branch: ${branch}"

                    if (branch == 'main') {
                        echo 'Deploying application to staging environment...'
                        bat 'docker compose -f docker-compose.staging.yml up -d --build'
                        echo 'Deployment completed successfully!'
                    } else {
                        echo "Skipping deployment: not on main branch."
                    }
                }
            }
        }
    }
}