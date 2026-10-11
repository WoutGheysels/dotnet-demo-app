pipeline {
    agent any
    environment {
        COMPOSE = '/var/jenkins_home/bin/docker-compose'
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Tools') {
            steps {
                sh '''
                    if [ ! -x "$COMPOSE" ]; then
                        mkdir -p "$(dirname "$COMPOSE")"
                        curl -sSL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o "$COMPOSE"
                        chmod +x "$COMPOSE"
                    fi
                '''
            }
        }
        stage('Preparation') {
            steps { sh '"$COMPOSE" down -v || true' }
        }
        stage('Build') {
            steps {
                sh '''
                    "$COMPOSE" up -d --build todoappdb
                    bash init-db.sh
                    "$COMPOSE" up -d --build todoapp
                    docker ps
                '''
            }
        }
        stage('Test') {
            steps { sh 'bash run-tests.sh' }
        }
    }
}