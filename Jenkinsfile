pipeline {
  agent any

  options {
    skipDefaultCheckout(true)
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 60, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
  }

  parameters {
    booleanParam(name: 'RUN_GATLING_MAX_LIMIT', defaultValue: false, description: 'Run Gatling max-limit discovery for performance evidence')
    string(name: 'APP_BASE_URL', defaultValue: 'http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/', description: 'Application base URL for Tomcat verification, Playwright, and Gatling')
    string(name: 'GATLING_MAX_BASE_USERS_PER_SEC', defaultValue: '200', description: 'First users/sec rate for Gatling max-limit discovery')
    string(name: 'GATLING_MAX_STEP_USERS_PER_SEC', defaultValue: '50', description: 'Users/sec increase between Gatling max-limit levels')
    string(name: 'GATLING_MAX_DURATION_SECONDS', defaultValue: '30', description: 'Seconds to hold each Gatling max-limit rate')
    string(name: 'GATLING_MAX_LIMIT_USERS_PER_SEC', defaultValue: '1050', description: 'Highest users/sec rate to test before reporting a lower bound')
  }

  triggers {
    pollSCM('* * * * *')
  }

  environment {
    APP_BASE_URL = "${params.APP_BASE_URL}"
    DEPLOY_CHECK_URL = "${params.APP_BASE_URL}"
    TOMCAT_CONTEXT = 'yonatan-csasznik-yoed-halberstam-niv-levin'
    PLAYWRIGHT_IMAGE = 'mcr.microsoft.com/playwright:v1.60.0-noble'
    GATLING_IMAGE = 'denvazh/gatling:3.2.1'
    GATLING_PLATFORM = 'linux/amd64'
    GATLING_LOAD_USERS_PER_SEC = '5'
    GATLING_STRESS_START_USERS_PER_SEC = '5'
    GATLING_STRESS_TARGET_USERS_PER_SEC = '50'
    GATLING_MAX_BASE_USERS_PER_SEC = "${params.GATLING_MAX_BASE_USERS_PER_SEC}"
    GATLING_MAX_STEP_USERS_PER_SEC = "${params.GATLING_MAX_STEP_USERS_PER_SEC}"
    GATLING_MAX_DURATION_SECONDS = "${params.GATLING_MAX_DURATION_SECONDS}"
    GATLING_MAX_LIMIT_USERS_PER_SEC = "${params.GATLING_MAX_LIMIT_USERS_PER_SEC}"
    GATLING_MAX_RAMP_SECONDS = '10'
  }

  stages {
    stage('Pre Actions') {
      steps {
        script {
          def scmVars = checkout scm
          env.CHECKED_OUT_COMMIT = scmVars.GIT_COMMIT ?: sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
        }
        sh 'rm -rf output/gatling output/playwright output/har output/reports'
        sh 'docker --version'
        sh 'docker compose version'
        sh 'docker info'
      }
    }

    stage('Build WAR') {
      steps {
        sh 'mvn -B clean package'
        archiveArtifacts artifacts: 'target/yonatan-csasznik-yoed-halberstam-niv-levin.war', fingerprint: true
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

    stage('Playwright Functional Test') {
      when {
        expression { fileExists('scripts/run-playwright-container') }
      }
      steps {
        script {
          def playwrightArgs = "--network meta --volumes-from meta-jenkins -w ${env.WORKSPACE} -e APP_BASE_URL=${env.APP_BASE_URL} -e WORKSPACE=${env.WORKSPACE} -e CHECKED_OUT_COMMIT=${env.CHECKED_OUT_COMMIT} -e CI=true"
          docker.image(env.PLAYWRIGHT_IMAGE).inside(playwrightArgs) {
            sh 'pwd'
            sh 'test "$PWD" = "$WORKSPACE"'
            sh 'git rev-parse --is-inside-work-tree'
            sh 'test "$(git rev-parse HEAD)" = "$CHECKED_OUT_COMMIT"'
            sh '''node <<'NODE'
const url = process.env.APP_BASE_URL;
const http = require('http');

http
  .get(url, (res) => {
    process.exit(res.statusCode >= 200 && res.statusCode < 400 ? 0 : 1);
  })
  .on('error', () => process.exit(1));
NODE'''
            sh 'PLAYWRIGHT_DOCKER_PIPELINE=1 ./scripts/run-playwright-container'
          }
        }
      }
    }

    stage('Gatling Max Limit') {
      when {
        allOf {
          expression { params.RUN_GATLING_MAX_LIMIT }
          expression { fileExists('scripts/run-gatling-max-limit') }
        }
      }
      steps {
        script {
          def gatlingArgs = "--platform ${env.GATLING_PLATFORM} --entrypoint= --network meta --volumes-from meta-jenkins -w ${env.WORKSPACE} -e WORKSPACE=${env.WORKSPACE} -e APP_BASE_URL=${env.APP_BASE_URL} -e GATLING_RUN_TYPE=max-limit -e GATLING_LOAD_USERS_PER_SEC=${env.GATLING_LOAD_USERS_PER_SEC} -e GATLING_STRESS_START_USERS_PER_SEC=${env.GATLING_STRESS_START_USERS_PER_SEC} -e GATLING_STRESS_TARGET_USERS_PER_SEC=${env.GATLING_STRESS_TARGET_USERS_PER_SEC} -e GATLING_MAX_BASE_USERS_PER_SEC=${env.GATLING_MAX_BASE_USERS_PER_SEC} -e GATLING_MAX_STEP_USERS_PER_SEC=${env.GATLING_MAX_STEP_USERS_PER_SEC} -e GATLING_MAX_DURATION_SECONDS=${env.GATLING_MAX_DURATION_SECONDS} -e GATLING_MAX_LIMIT_USERS_PER_SEC=${env.GATLING_MAX_LIMIT_USERS_PER_SEC} -e GATLING_MAX_RAMP_SECONDS=${env.GATLING_MAX_RAMP_SECONDS}"
          docker.image(env.GATLING_IMAGE).inside(gatlingArgs) {
            sh 'pwd'
            sh 'test "$PWD" = "$WORKSPACE"'
            sh 'test -d src/gatling/user-files/simulations'
            sh 'test -x scripts/run-gatling-max-limit'
            sh 'GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=max-limit ./scripts/run-gatling-max-limit'
          }
        }
      }
    }

    stage('Gatling Load Test') {
      when {
        expression { fileExists('scripts/run-gatling-load-5m') }
      }
      steps {
        script {
          def gatlingArgs = "--platform ${env.GATLING_PLATFORM} --entrypoint= --network meta --volumes-from meta-jenkins -w ${env.WORKSPACE} -e WORKSPACE=${env.WORKSPACE} -e APP_BASE_URL=${env.APP_BASE_URL} -e GATLING_RUN_TYPE=load-5m -e GATLING_LOAD_USERS_PER_SEC=${env.GATLING_LOAD_USERS_PER_SEC} -e GATLING_STRESS_START_USERS_PER_SEC=${env.GATLING_STRESS_START_USERS_PER_SEC} -e GATLING_STRESS_TARGET_USERS_PER_SEC=${env.GATLING_STRESS_TARGET_USERS_PER_SEC}"
          docker.image(env.GATLING_IMAGE).inside(gatlingArgs) {
            sh 'pwd'
            sh 'test "$PWD" = "$WORKSPACE"'
            sh 'test -d src/gatling/user-files/simulations'
            sh 'test -x scripts/run-gatling-container'
            sh 'GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=load-5m ./scripts/run-gatling-container'
          }
        }
      }
    }

    stage('Gatling Stress Test') {
      when {
        expression { fileExists('scripts/run-gatling-stress-5m') }
      }
      steps {
        script {
          def gatlingArgs = "--platform ${env.GATLING_PLATFORM} --entrypoint= --network meta --volumes-from meta-jenkins -w ${env.WORKSPACE} -e WORKSPACE=${env.WORKSPACE} -e APP_BASE_URL=${env.APP_BASE_URL} -e GATLING_RUN_TYPE=stress-5m -e GATLING_LOAD_USERS_PER_SEC=${env.GATLING_LOAD_USERS_PER_SEC} -e GATLING_STRESS_START_USERS_PER_SEC=${env.GATLING_STRESS_START_USERS_PER_SEC} -e GATLING_STRESS_TARGET_USERS_PER_SEC=${env.GATLING_STRESS_TARGET_USERS_PER_SEC}"
          docker.image(env.GATLING_IMAGE).inside(gatlingArgs) {
            sh 'pwd'
            sh 'test "$PWD" = "$WORKSPACE"'
            sh 'test -d src/gatling/user-files/simulations'
            sh 'test -x scripts/run-gatling-container'
            sh 'GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=stress-5m ./scripts/run-gatling-container'
          }
        }
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
          def pdfArgs = "--network meta --volumes-from meta-jenkins -w ${env.WORKSPACE} -e CI=true -e GATLING_PDF_REQUIRE_ALL=false"
          docker.image(env.PLAYWRIGHT_IMAGE).inside(pdfArgs) {
            sh 'GATLING_PDF_DOCKER_PIPELINE=1 GATLING_PDF_REQUIRE_ALL=false ./scripts/export-gatling-pdfs'
          }
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

        if (fileExists('scripts/generate-playwright-jenkins-report') && fileExists('output/playwright/junit.xml')) {
          sh './scripts/generate-playwright-jenkins-report'
        }

        if (fileExists('output/playwright/junit.xml')) {
          junit testResults: 'output/playwright/junit.xml', allowEmptyResults: true
        }

        if (fileExists('output/playwright/jenkins-report/index.html')) {
          publishHTML(target: [
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'output/playwright/jenkins-report',
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
