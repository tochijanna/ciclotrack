pipeline {
    agent any

    environment {
        FLUTTER_HOME = "${env.FLUTTER_HOME}"
        ANDROID_HOME = "${env.ANDROID_HOME}"
        ANDROID_SDK_ROOT = "${env.ANDROID_SDK_ROOT}"
        PATH = "${env.FLUTTER_HOME}/bin:${env.ANDROID_HOME}/cmdline-tools/latest/bin:${env.ANDROID_HOME}/platform-tools:${env.PATH}"
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Info') {
            steps {
                sh '''
                    git --version
                    java -version
                    flutter --version
                    flutter doctor -v
                '''
            }
        }

        stage('Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Analyze') {
            steps {
                sh 'flutter analyze'
            }
        }

        stage('Test') {
            steps {
                sh 'flutter test'
            }
        }

        stage('Build APK Debug') {
            steps {
                sh 'flutter build apk --debug'
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk', fingerprint: true
        }
    }
}
