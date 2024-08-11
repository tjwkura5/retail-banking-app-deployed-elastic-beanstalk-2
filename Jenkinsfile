pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''#!/bin/bash
                python3.7 -m venv venv
                source venv/bin/activate
                pip install pip --upgrade
                pip install -r requirements.txt
                export FLASK_APP=application
                flask run &
                '''
            }
        }
        stage('Clear Cache') {
            steps {
                sh '''#!/bin/bash
                sync
                echo 3 > /proc/sys/vm/drop_caches
                echo "Cache and unused objects cleared from memory."
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''#!/bin/bash
                ps aux --sort=-%cpu -h | head -n 10
                chmod +x system_resources_test.sh
                ./system_resources_test.sh
                '''
            }
        }
    }
}

