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
                bat 'venv\\Scripts\\python -m pip install -r requirements.txt'
                echo 'Build stage completed successfully!'
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests with coverage...'
                bat 'venv\\Scripts\\python -m pip install pytest pytest-cov'
                bat 'venv\\Scripts\\python -m pytest --cov=app --cov-report xml:coverage.xml test_app.py'
            }
        }

        stage('Hello') {
            steps { echo 'Jenkins is connected to GitHub successfully!' }
        }

        stage('Code Quality') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat """
                        sonar-scanner ^
                            -Dsonar.projectKey=SIT753-7.3HD ^
                            -Dsonar.sources=. ^
                            -Dsonar.host.url=http://localhost:9000 ^
                            -Dsonar.token=%SONAR_QUBE_TOKEN% ^
                            -Dsonar.python.coverage.reportPaths=coverage.xml
                    """
                }
            }
        }

        stage('Security') {
            steps {
                echo 'Installing and running Bandit (report will be archived).'
                bat 'venv\\Scripts\\python -m pip install --upgrade pip'
                bat 'venv\\Scripts\\python -m pip install bandit'

                script {
                                        def banditStatus = bat(script: 'venv\\Scripts\\python -m bandit -r . -f html -o security_report.html', returnStatus: true)

                    if (banditStatus == 0) {
                        echo "Bandit finished with exit code 0 (no issues found)."
                    } else {
                        echo "Bandit finished with exit code ${banditStatus}. Issues were found and the report is saved, but the pipeline will remain SUCCESS."
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'security_report.html', fingerprint: true
                }
            }
        }

        stage('Deploy to Staging') {
            when { expression { env.BRANCH_NAME == 'main' || !env.BRANCH_NAME } }
            steps {
                echo 'Deploying application to staging environment...'
                bat 'docker compose -f docker-compose.staging.yml up -d --build'
                echo 'Staging deployment completed successfully!'
            }
        }

        stage('Release to Production') {
            when { expression { env.BRANCH_NAME == 'main' || !env.BRANCH_NAME } }
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
                    def raw = bat(
                        script: '@curl -s -o NUL -w "%%{http_code}" http://localhost:%FLASK_PORT%',
                        returnStdout: true
                    )

                    def lastLine = raw.readLines().collect { it.trim() }.findAll { it }.last()
                    echo "raw curl output lines: ${raw.readLines().collect { it.trim() }.findAll { it }}"

                    def m = (lastLine =~ /(\d{3})$/)
                    def responseCode = m ? m[0][1] : lastLine

                    echo "Parsed HTTP status: ${responseCode}"

                    if (responseCode != '200') {
                        error "ALERT: Production application is NOT responding! HTTP status: ${responseCode}"
                    } else {
                        echo 'Production application is healthy. HTTP 200 OK.'
                    }
                }
            }
        }

    }

    post {
        always { echo 'Pipeline finished.' }
    }
}
