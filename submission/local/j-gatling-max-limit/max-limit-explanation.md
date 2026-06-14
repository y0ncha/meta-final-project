# Gatling Max-Limit Explanation

Our app's local tested max limit is `8300` virtual users on the local Jenkins/Tomcat Docker setup.

This is the limit because the project pass rule is `KO=0`: a tested level passes only when Gatling reports zero failed requests.

How it was found:

- Gatling max-limit discovery ran against the local Tomcat target.
- The tested range was `8100` to `12000` virtual users.
- The step size was `50` virtual users.
- Each level ran for `10` seconds.

Result:

- `8300` virtual users passed with `KO=0`.
- `8350` virtual users was the first failing tested level.
- The final staircase report shows `1,621,128` total requests, `1,029,510 OK`, and `591,618 KO`; the failures were `Address not available` socket errors against the local Tomcat container.

Therefore, `8350` is beyond the passing boundary, and the previous passing tested level, `8300`, is the max limit we found.
