# 04 - Tomcat Container Deployment

## Goal
Deploy the Maven WAR into the Tomcat 8.5.x container under `webapps`.

## Deliverables
- Deployment script, for example `scripts/deploy-war`.
- Tomcat webapps volume or bind mount.
- Working local app URL.

## Implementation
- Build the WAR with Maven.
- Copy the WAR to the Tomcat webapps mount as `meta.war`.
- Let Tomcat expand/deploy the WAR.
- Keep the public context path stable: `/meta/`.
- Do not use host `/usr/local/tomcat8` unless the container path is blocked.

## Validation
- `docker compose ps tomcat` shows Tomcat running.
- `curl -f http://localhost:8080/meta/` succeeds.
- Browser screenshot shows `http://localhost:8080/meta/` in the address bar.

## Human Configuration Needed
- None after `meta` is confirmed as the final context path.
