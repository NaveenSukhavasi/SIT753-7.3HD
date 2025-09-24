pipeline {
    agent any

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
                
                // Windows commands
                bat 'python -m venv venv'
                bat 'venv\\Scripts\\pip install --upgrade pip'
                bat 'venv\\Scripts\\pip install -r requirements.txt'
                
                echo 'Build stage completed successfully!'
            }
        }

        stage('Hello') {
            steps {
                echo 'Jenkins is connected to GitHub successfully!'
            }
        }
    }
}