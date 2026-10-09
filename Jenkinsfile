pipeline {
    agent any

    environment {
        FLUTTER_HOME = "${env.FLUTTER_HOME ?: ''}"
        ANDROID_HOME = "${env.ANDROID_HOME ?: env.ANDROID_SDK_ROOT ?: ''}"
        ANDROID_SDK_ROOT = "${env.ANDROID_SDK_ROOT ?: env.ANDROID_HOME ?: ''}"
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
                    bash -n ci/build-signed-apk.sh
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

        stage('Build and verify signed APK') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'ciclotrack-android-release-keystore',
                        variable: 'ANDROID_KEYSTORE_FILE'
                    ),
                    string(
                        credentialsId: 'ciclotrack-android-release-password',
                        variable: 'ANDROID_KEYSTORE_PASSWORD'
                    )
                ]) {
                    sh 'bash ci/build-signed-apk.sh'
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts(
                artifacts: 'build/app/outputs/flutter-apk/app-release.apk',
                fingerprint: true,
                allowEmptyArchive: false
            )
        }
    }
}
