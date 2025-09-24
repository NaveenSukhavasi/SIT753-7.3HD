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
        stage('Hello') {
            steps {
                echo 'Jenkins is connected to GitHub successfully!'
            }
        }
    }
}