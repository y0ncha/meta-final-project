# Gatling Max Limit explanation

Our app's local tested max limit is `~8400` virtual users on the local Jenkins/Tomcat Docker setup. This is the limit because the project pass rule is `KO=0`: a tested level passes only when Gatling reports zero failed requests. We tested from `8000` virtual users in `20`-user steps, running each level for `10` seconds. The `8400` virtual-user level passed with `KO=0` - the next tested level, `8420`, failed with `61` connection-timeout errors.

Therefore, `8420` is beyond the passing boundary, and the previous passing tested level, `8400`, is the max limit we found.
