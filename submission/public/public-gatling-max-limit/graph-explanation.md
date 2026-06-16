# Public Gatling Max-Limit Graph Explanation

The public max-limit run tested the EC2 Tomcat URL with a `50-700 users/sec` generator sweep in `50 users/sec` steps. Each level ran for `10` seconds with a `1` second ramp.

The Gatling graphs show active users rising cleanly at first, then failures appearing as the public host stops accepting or completing all requests. The run completed with `201518` total requests, `192205 OK`, and `9313 KO`.

Under the response-tooltip `KO=0` rule, the max-limit value is taken from the active-users graph at the selected zero-KO `Number of responses per second` point, not from the configured users/sec generator level. The graph screenshot `max-limit-public.png` shows `6718 active users`, `301 OK`, and `0 KO` at Tuesday, June 16, `03:38:22`.

Therefore, the public max limit to state is `6718 active users` with `0 KO`. Later failures included `ConnectTimeoutException` against `51.84.219.74:8080`, connection refused, and premature close.
