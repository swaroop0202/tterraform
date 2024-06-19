pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        // Timeout counter starts AFTER agent is allocated
        timeout(time: 60, unit: 'SECONDS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'ls -ltr '
                sh 'terraform init'
            }
        }
        stage('plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo this is deploy'
            }
        }    
        stage('output') {
            steps {
                echo "Hello ${params.PERSON}"

                echo "Biography: ${params.BIOGRAPHY}"

                echo "Toggle: ${params.TOGGLE}"

                echo "Choice: ${params.CHOICE}"

                echo "Password: ${params.PASSWORD}"
                echo "choices"
            }
        }
    }
}
