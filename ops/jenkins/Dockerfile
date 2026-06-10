ARG JENKINS_BASE_IMAGE=jenkins/jenkins:2.528.1-lts-jdk21
FROM ${JENKINS_BASE_IMAGE}

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl maven \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
