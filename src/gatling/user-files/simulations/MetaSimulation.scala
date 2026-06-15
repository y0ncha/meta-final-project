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

  private def intEnv(name: String, defaultValue: => Int): Int = {
    val value = sys.env.get(name).map(_.trim).filter(_.nonEmpty).map(_.toInt).getOrElse(defaultValue)
    if (value <= 0) {
      throw new IllegalArgumentException(s"$name must be greater than 0")
    }
    value
  }

  private def nonNegativeIntEnv(name: String, defaultValue: => Int): Int = {
    val value = sys.env.get(name).map(_.trim).filter(_.nonEmpty).map(_.toInt).getOrElse(defaultValue)
    if (value < 0) {
      throw new IllegalArgumentException(s"$name must be greater than or equal to 0")
    }
    value
  }

  private def staircaseLevels(startUsers: Int, targetUsers: Int, name: String): Seq[Int] = {
    if (targetUsers < startUsers) {
      throw new IllegalArgumentException(s"${name}_TARGET_USERS must be greater than or equal to ${name}_START_USERS")
    }
    (0 to 4).map { level =>
      startUsers + math.round((targetUsers - startUsers).toDouble * level / 4.0).toInt
    }
  }

  private def steppedLevels(baseUsers: Int, limitUsers: Int, stepUsers: Int): Seq[Int] = {
    if (limitUsers < baseUsers) {
      throw new IllegalArgumentException("GATLING_MAX_LIMIT_USERS must be greater than or equal to GATLING_MAX_BASE_USERS")
    }
    val stepped = baseUsers to limitUsers by stepUsers
    if (stepped.last == limitUsers) {
      stepped
    } else {
      stepped :+ limitUsers
    }
  }

  private val httpProtocol = http
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    .userAgentHeader("meta-final-project-gatling")

  private val harDerivedFlow = exec(
      http("GET /yonatan-csasznik-yoed-halberstam-niv-levin/")
        .get(appRootUrl)
        .check(status.is(200), substring("MeTA"))
    )
    .exitHereIfFailed
    .pause(1.second)
    .exec(
      http("POST /yonatan-csasznik-yoed-halberstam-niv-levin/index.jsp submit name")
        .post(appSubmitUrl)
        .formParam("nameInput", "Yonatan")
        .check(status.is(200), substring("Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it."))
    )
    .exitHereIfFailed
    .exec(
      http("GET /yonatan-csasznik-yoed-halberstam-niv-levin/ reload before empty submit")
        .get(appRootUrl)
        .check(status.is(200), substring("MeTA"))
    )
    .exitHereIfFailed
    .pause(1.second)
    .exec(
      http("POST /yonatan-csasznik-yoed-halberstam-niv-levin/index.jsp submit empty name")
        .post(appSubmitUrl)
        .formParam("nameInput", "")
        .check(status.is(200), substring("Please enter a name before MeTA Corporate schedules a meeting about the empty box."))
    )
    .exitHereIfFailed

  private val scn = scenario("Meta JSP HAR-derived flow")
    .exec(harDerivedFlow)

  runType match {
    case "load-5m" =>
      val loadUsers = intEnv("GATLING_LOAD_USERS", 5)

      setUp(
        scn.inject(
          rampUsersPerSec(0.0).to(loadUsers.toDouble).during(60.seconds),
          constantUsersPerSec(loadUsers.toDouble).during(180.seconds),
          rampUsersPerSec(loadUsers.toDouble).to(0.0).during(60.seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.count.lt(1)
        )

    case "stress-5m" =>
      val stressStartUsers = intEnv("GATLING_STRESS_START_USERS", 10)
      val stressTargetUsers = intEnv("GATLING_STRESS_TARGET_USERS", 50)
      val stressLevels = staircaseLevels(stressStartUsers, stressTargetUsers, "GATLING_STRESS")

      setUp(
        scn.inject(
          constantUsersPerSec(stressLevels(0).toDouble).during(60.seconds),
          constantUsersPerSec(stressLevels(1).toDouble).during(60.seconds),
          constantUsersPerSec(stressLevels(2).toDouble).during(60.seconds),
          constantUsersPerSec(stressLevels(3).toDouble).during(60.seconds),
          constantUsersPerSec(stressLevels(4).toDouble).during(60.seconds)
        )
      )
        .protocols(httpProtocol)
        .assertions(
          global.failedRequests.count.lt(1)
        )

    case "max-limit" =>
      val maxBaseUsers = intEnv("GATLING_MAX_BASE_USERS", intEnv("GATLING_MAX_USERS", 8250))
      val maxStepUsers = intEnv("GATLING_MAX_STEP_USERS", 50)
      val maxLimitUsers = intEnv("GATLING_MAX_LIMIT_USERS", 8350)
      val maxDurationSeconds = intEnv("GATLING_MAX_DURATION_SECONDS", 10)
      val maxRampSeconds = nonNegativeIntEnv("GATLING_MAX_RAMP_SECONDS", 0)
      val levels = steppedLevels(maxBaseUsers, maxLimitUsers, maxStepUsers)
      val maxScheduleSeconds = maxRampSeconds + (levels.size * maxDurationSeconds) + ((levels.size - 1) * maxRampSeconds)
      val maxRunSeconds = maxScheduleSeconds + 30
      val levelHolds = levels.zipWithIndex.flatMap { case (level, index) =>
        val hold = Seq(constantUsersPerSec(level.toDouble).during(maxDurationSeconds.seconds))
        val rampToNext = levels.lift(index + 1).toSeq.flatMap { nextLevel =>
          if (maxRampSeconds > 0) {
            Seq(rampUsersPerSec(level.toDouble).to(nextLevel.toDouble).during(maxRampSeconds.seconds))
          } else {
            Seq.empty
          }
        }
        hold ++ rampToNext
      }
      val staircaseProfile = {
        if (maxRampSeconds > 0) {
          Seq(rampUsersPerSec(0.0).to(levels.head.toDouble).during(maxRampSeconds.seconds)) ++ levelHolds
        } else {
          levelHolds
        }
      }

      setUp(
        scn.inject(staircaseProfile)
      )
        .protocols(httpProtocol)
        .maxDuration(maxRunSeconds.seconds)
        .assertions(
          global.failedRequests.count.lt(1)
        )
  }
}
