# Public Gatling Max-Limit Graph Explanation

Source: Jenkins `MeTA/meta-ci-cd` build `#249`.

The public max-limit run tested the EC2 Tomcat URL from `8100` to `12000` virtual users in `20`-user steps, with `10` seconds per level. The highest tested level with `KO=0` was `8280` virtual users. The next tested level, `8300`, produced `47` failed requests from connection timeouts, so the public tested max limit is `8280` virtual users under the project `KO=0` rule.

In the Gatling report graphs, active users rise sharply to the tested level. The final failing-level report has `33200` total requests, `33153 OK`, and `47 KO`. The response-time graph degrades heavily at the failing level, and the errors graph shows the connection-timeout failures that make `8300` fail.
