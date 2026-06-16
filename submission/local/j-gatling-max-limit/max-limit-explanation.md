# Gatling Max-Limit Explanation

Current local max-limit value: `2340 active users` with `0 KO`.

- The local max-limit report in `builds/max-limit-local/` targeted `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- The report uses a `50-700 users/sec` generator sweep, step `50 users/sec`, `10s/level`, `1s` ramp.
- The report shows the full run eventually failed with `201304` total requests, `191872 OK`, and `9432 KO`.
- The error shown in the local report is `Address not available` against `tomcat:8080`.
- The `Number of responses per second` graph screenshot `max-limit-local.png` shows the selected zero-KO tooltip: `2340 active users`, `1399 OK`, `0 KO`.
- The submission max-limit value should therefore be written as `2340 active users` with `0 KO`.

Do not write this as `users/sec`. The users/sec sweep is only the Gatling generator input used to create the graph.
