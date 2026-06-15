# Gatling Max-Limit Explanation

Pending refresh: the app's local tested max limit must be measured again as users/sec after the max-limit methodology refactor.

This is required because the previous packaged boundary was measured with concurrent virtual-user levels. The current max-limit method uses users/sec arrival-rate levels, so the old `8300` / `8350` concurrent-user result must not be reused as the users/sec answer.

The project pass rule remains `KO=0`: a tested users/sec level passes only when Gatling reports zero failed requests/checks/timeouts.

How it was found:

- Run Gatling max-limit discovery against the local Tomcat target after the refactor.
- Use a bounded users/sec range close to the expected failure region.
- Record the tested users/sec range, step size, hold duration, and optional ramp duration.

Result:

- Highest passing tested level: pending refresh.
- First failing tested level: pending refresh.
- Final users/sec conclusion: pending refresh.

After the refresh, the max limit is the highest tested users/sec level with `KO=0`; the next tested users/sec level with `KO>0` is the failure boundary.
