import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class MetaSimulation extends Simulation {
  private val appBaseUrl = sys.env.getOrElse("APP_BASE_URL", "http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/").stripSuffix("/")
  private val appRootUrl = appBaseUrl + "/"
  private val appSubmitUrl = appBaseUrl + "/index.jsp"
  private val runType = sys.env.getOrElse("GATLING_RUN_TYPE", "load-5m")

  if (!Set("max-limit", "load-5m", "stress-5m").contains(runType)) {
    throw new IllegalArgumentException("GATLING_RUN_TYPE must be max-limit, load-5m, or stress-5m")
  }

  private def intEnv(name: String, defaultValue: Int): Int = {
    val value = sys.env.get(name).map(_.trim).filter(_.nonEmpty).map(_.toInt).getOrElse(defaultValue)
    if (value <= 0) {
      throw new IllegalArgumentException(s"$name must be greater than 0")
    }
    value
  }

  private val httpProtocol = http
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    .userAgentHeader("meta-final-project-gatling")

  private val harDerivedFlow = exec(
      http("GET /yonatan-csasznik-yoed-halberstam-niv-levin/")
        .get(appRootUrl)
        .check(status.is(200), substring("MeTA"))
    )
    .pause(1.second)
    .exec(
      http("POST /yonatan-csasznik-yoed-halberstam-niv-levin/index.jsp submit name")
        .post(appSubmitUrl)
        .formParam("nameInput", "Yonatan")
        .check(status.is(200), substring("Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it."))
    )
    .exec(
      http("GET /yonatan-csasznik-yoed-halberstam-niv-levin/ reload before empty submit")
        .get(appRootUrl)
        .check(status.is(200), substring("MeTA"))
    )
    .pause(1.second)
    .exec(
      http("POST /yonatan-csasznik-yoed-halberstam-niv-levin/index.jsp submit empty name")
        .post(appSubmitUrl)
        .formParam("nameInput", "")
        .check(status.is(200), substring("Please enter a name before MeTA Corporate schedules a meeting about the empty box."))
    )

  private def scenarioFor(durationSeconds: Int) =
    scenario("Meta JSP HAR-derived flow")
      .during(durationSeconds.seconds) {
        harDerivedFlow
      }

  runType match {
    case "load-5m" =>
      setUp(
        scenarioFor(300).inject(
          constantConcurrentUsers(intEnv("GATLING_LOAD_USERS", 5)).during(300.seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.count.lt(1)
        )

    case "stress-5m" =>
      setUp(
        scenarioFor(300).inject(
          rampConcurrentUsers(intEnv("GATLING_STRESS_START_USERS", 5))
            .to(intEnv("GATLING_STRESS_TARGET_USERS", 50))
            .during(300.seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.count.lt(1)
        )

    case "max-limit" =>
      setUp(
        scenarioFor(intEnv("GATLING_MAX_DURATION_SECONDS", 30)).inject(
          constantConcurrentUsers(intEnv("GATLING_MAX_USERS", 5))
            .during(intEnv("GATLING_MAX_DURATION_SECONDS", 30).seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.count.lt(1)
        )
  }
}
