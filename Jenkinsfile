pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
  }

  triggers {
    cron('H/5 * * * *')
  }

  environment {
    APP_BASE_URL = 'http://tomcat:8080/meta/'
    DEPLOY_CHECK_URL = 'http://tomcat:8080/meta/'
    TOMCAT_CONTEXT = 'meta'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build WAR') {
      steps {
        sh 'mvn -B clean package'
        archiveArtifacts artifacts: 'target/meta.war', fingerprint: true
      }
    }

    stage('Deploy Tomcat') {
      steps {
        sh 'SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL="$DEPLOY_CHECK_URL" ./scripts/deploy-war'
      }
    }

    stage('Verify Tomcat') {
      steps {
        sh 'curl -fsS "$APP_BASE_URL" >/dev/null'
      }
    }

    stage('Availability Check') {
      steps {
        sh 'curl -fsS "$APP_BASE_URL" >/dev/null'
      }
    }

    stage('Playwright Functional Test') {
      when {
        expression { fileExists('scripts/run-playwright-container') }
      }
      steps {
        sh './scripts/run-playwright-container'
      }
    }

    stage('Gatling Load Test') {
      when {
        expression { fileExists('scripts/run-gatling-load-5m') }
      }
      steps {
        sh './scripts/run-gatling-load-5m'
      }
    }

    stage('Gatling Stress Test') {
      when {
        expression { fileExists('scripts/run-gatling-stress-5m') }
      }
      steps {
        sh './scripts/run-gatling-stress-5m'
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'output/**/*', allowEmptyArchive: true
    }
  }
}
