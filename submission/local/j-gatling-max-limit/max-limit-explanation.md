# Gatling Max-Limit Explanation

Our app's local tested max limit is `8440` virtual users on the local Jenkins/Tomcat Docker setup.

This is the limit because the project pass rule is `KO=0`: a tested level passes only when Gatling reports zero failed requests.

How it was found:

- Gatling max-limit discovery ran against the local Tomcat target.
- The tested range was `8100` to `12000` virtual users.
- The step size was `20` virtual users.
- Each level ran for `10` seconds.

Result:

- `8440` virtual users passed with `KO=0`.
- `8460` virtual users failed with `33` connection-timeout errors.

Therefore, `8460` is beyond the passing boundary, and the previous passing tested level, `8440`, is the max limit we found.
