pipeline {
    agent any
    options {
        timeout(time: 15, unit: 'MINUTES')
    }
    environment {
        COMPOSE = '/var/jenkins_home/bin/docker-compose'
        COMPOSE_PROJECT_NAME = 'dotnetdemo'
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
            steps {
                sh '''
                    "$COMPOSE" down || true
                    docker rm -f todoapp todoappdb || true
                '''
            }
        }
        stage('Database') {
            steps {
                retry(3) {
                    script {
                        try {
                            sh '''
                                "$COMPOSE" up -d todoappdb
                                bash init-db.sh
                            '''
                        } catch (err) {
                            sh '''
                                "$COMPOSE" down -v || true
                                docker rm -f todoapp todoappdb || true
                            '''
                            throw err
                        }
                    }
                }
            }
        }
        stage('Build') {
            steps {
                sh '''
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