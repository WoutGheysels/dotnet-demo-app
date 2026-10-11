pipeline {
    agent any
    options {
        timeout(time: 15, unit: 'MINUTES')
    }
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
            // volume blijft bewaard, enkel de containers worden vervangen
            steps { sh '"$COMPOSE" down || true' }
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
                            // herstel: verse volume bij een mislukte start
                            sh '"$COMPOSE" down -v || true'
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