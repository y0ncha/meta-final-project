pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
  }

  parameters {
    booleanParam(name: 'RUN_GATLING_MAX_LIMIT', defaultValue: false, description: 'Run Gatling max-limit discovery for performance evidence')
  }

  triggers {
    cron('H/5 * * * *')
    pollSCM('H/2 * * * *')
  }

  environment {
    APP_BASE_URL = 'http://tomcat:8080/meta/'
    DEPLOY_CHECK_URL = 'http://tomcat:8080/meta/'
    TOMCAT_CONTEXT = 'meta'
  }

  stages {
    stage('Checkout') {
      when {
        not {
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        checkout scm
      }
    }

    stage('Prepare Evidence Workspace') {
      when {
        not {
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh 'rm -rf output/gatling output/playwright output/har output/reports'
      }
    }

    stage('Build WAR') {
      when {
        not {
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh 'mvn -B clean package'
        archiveArtifacts artifacts: 'target/meta.war', fingerprint: true
      }
    }

    stage('Deploy Tomcat') {
      when {
        not {
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh 'SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL="$DEPLOY_CHECK_URL" ./scripts/deploy-war'
      }
    }

    stage('Verify Tomcat') {
      when {
        not {
          triggeredBy 'TimerTrigger'
        }
      }
      steps {
        sh 'curl -fsS "$APP_BASE_URL" >/dev/null'
      }
    }

    stage('Availability Check') {
      when {
        triggeredBy 'TimerTrigger'
      }
      steps {
        sh 'curl -fsS "$APP_BASE_URL" >/dev/null'
      }
    }

    stage('Playwright Functional Test') {
      when {
        allOf {
          not {
            triggeredBy 'TimerTrigger'
          }
          expression { fileExists('scripts/run-playwright-container') }
        }
      }
      steps {
        sh './scripts/run-playwright-container'
      }
    }

    stage('Gatling Max Limit') {
      when {
        allOf {
          not {
            triggeredBy 'TimerTrigger'
          }
          expression { params.RUN_GATLING_MAX_LIMIT }
          expression { fileExists('scripts/run-gatling-max-limit') }
        }
      }
      steps {
        sh './scripts/run-gatling-max-limit'
      }
    }

    stage('Gatling Load Test') {
      when {
        allOf {
          not {
            triggeredBy 'TimerTrigger'
          }
          expression { fileExists('scripts/run-gatling-load-5m') }
        }
      }
      steps {
        sh './scripts/run-gatling-load-5m'
      }
    }

    stage('Gatling Stress Test') {
      when {
        allOf {
          not {
            triggeredBy 'TimerTrigger'
          }
          expression { fileExists('scripts/run-gatling-stress-5m') }
        }
      }
      steps {
        sh './scripts/run-gatling-stress-5m'
      }
    }
  }

  post {
    always {
      script {
        if (
          fileExists('scripts/export-gatling-pdfs') &&
          (
            fileExists('output/gatling/max-limit/index.html') ||
            fileExists('output/gatling/load-5m/index.html') ||
            fileExists('output/gatling/stress-5m/index.html')
          )
        ) {
          sh 'GATLING_PDF_REQUIRE_ALL=false ./scripts/export-gatling-pdfs'
        }

        if (fileExists('scripts/generate-pipeline-report')) {
          sh './scripts/generate-pipeline-report'
        }
      }

      archiveArtifacts artifacts: 'output/**/*', allowEmptyArchive: true
      script {
        if (fileExists('output/reports/pipeline-report.html')) {
          publishHTML(target: [
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'output/reports',
            reportFiles: 'pipeline-report.html',
            reportName: 'Pipeline Final Report'
          ])
        }

        if (fileExists('output/playwright/junit.xml')) {
          junit testResults: 'output/playwright/junit.xml', allowEmptyResults: true
        }

        if (fileExists('output/playwright/playwright-report/index.html')) {
          publishHTML(target: [
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'output/playwright/playwright-report',
            reportFiles: 'index.html',
            reportName: 'Playwright Report'
          ])
        }

        [
          [name: 'Gatling Max Limit Report', dir: 'output/gatling/max-limit'],
          [name: 'Gatling Load 5m Report', dir: 'output/gatling/load-5m'],
          [name: 'Gatling Stress 5m Report', dir: 'output/gatling/stress-5m']
        ].each { report ->
          if (fileExists("${report.dir}/index.html")) {
            publishHTML(target: [
              allowMissing: true,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: report.dir,
              reportFiles: 'index.html,*.pdf',
              reportName: report.name
            ])
          }
        }
      }
    }
  }
}
