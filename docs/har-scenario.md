# HAR Scenario

The HAR records this browser scenario:

1. Open the MeTA web app:
   `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
2. Click `About this app`.
3. Type `Yonatan` in the name text box.
4. Click `Submit`.
5. Confirm the success message is shown.
6. Reload/open the app again.
7. Click `Submit` with the name text box empty.
8. Confirm the validation message is shown.

In short:

`open app -> click About -> type Yonatan -> click Submit -> see success -> reload -> click Submit empty -> see validation error`

This scenario covers the app page load, link navigation, positive form submission, and negative empty-input validation.

Gatling does not load this HAR at runtime.
