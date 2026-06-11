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

  private def doubleEnv(name: String, defaultValue: Double): Double = {
    val value = sys.env.get(name).map(_.trim).filter(_.nonEmpty).map(_.toDouble).getOrElse(defaultValue)
    if (value <= 0.0) {
      throw new IllegalArgumentException(s"$name must be greater than 0")
    }
    value
  }

  private val httpProtocol = http
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    .userAgentHeader("meta-final-project-gatling")

  private val scn = scenario("Meta JSP flow")
    .exec(
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

  runType match {
    case "load-5m" =>
      setUp(
        scn.inject(
          constantUsersPerSec(doubleEnv("GATLING_LOAD_USERS_PER_SEC", 5.0)).during(300.seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.percent.lt(5),
          global.responseTime.percentile3.lte(2000)
        )

    case "stress-5m" =>
      setUp(
        scn.inject(
          rampUsersPerSec(doubleEnv("GATLING_STRESS_START_USERS_PER_SEC", 5.0))
            .to(doubleEnv("GATLING_STRESS_TARGET_USERS_PER_SEC", 50.0))
            .during(300.seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.percent.lt(5),
          global.responseTime.percentile3.lte(2000)
        )

    case "max-limit" =>
      setUp(
        scn.inject(
          incrementUsersPerSec(doubleEnv("GATLING_MAX_STEP_USERS_PER_SEC", 5.0))
            .times(intEnv("GATLING_MAX_LEVEL_COUNT", 10))
            .eachLevelLasting(intEnv("GATLING_MAX_LEVEL_SECONDS", 30).seconds)
            .separatedByRampsLasting(intEnv("GATLING_MAX_RAMP_SECONDS", 10).seconds)
            .startingFrom(doubleEnv("GATLING_MAX_START_USERS_PER_SEC", 5.0))
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.percent.lt(5),
          global.responseTime.percentile3.lte(2000)
        )
  }
}
