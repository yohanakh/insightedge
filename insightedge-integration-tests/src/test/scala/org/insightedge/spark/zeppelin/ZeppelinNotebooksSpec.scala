package org.insightedge.spark.zeppelin

import org.insightedge.spark.fixture.InsightedgeDemoModeDocker
import org.insightedge.spark.utils.RestUtils
import RestUtils._
import org.insightedge.spark.utils.RestUtils
import org.scalatest.FlatSpec
import org.scalatest.concurrent.Eventually._
import play.api.libs.json.{JsArray, JsObject, JsString}

import scala.concurrent.duration._

/**
  * Verifies that Zeppelin notebooks work in a demo mode
  *
  * @author Oleksiy_Dyagilev
  */
class ZeppelinNotebooksSpec extends FlatSpec with InsightedgeDemoModeDocker {

  val TutorialNotebookId = "INSIGHTEDGE-BASIC"
  val PythonNotebookId = "INSIGHTEDGE-PYTHON"
  val GeospatialNotebookId = "INSIGHTEDGE-GEOSPATIAL"

  "Zeppelin" should "have InsightEdge notebooks" in {
    val resp = wsClient.url(s"$zeppelinUrl/api/notebook").get()
    val notebookIds = jsonBody(resp) \\ "id"

    assert(notebookIds.contains(JsString(TutorialNotebookId)))
    assert(notebookIds.contains(JsString(PythonNotebookId)))
    assert(notebookIds.contains(JsString(GeospatialNotebookId)))
  }

  it should "be possible to run InsightEdge notebooks" in {
    runNotebook(TutorialNotebookId)
    runNotebook(PythonNotebookId)
    runNotebook(GeospatialNotebookId)
  }

  def runNotebook(notebookId: String) = {
    println(s"Running notebook $notebookId ...")

    def bindInterpreters() = {
      val bindUrl = s"$zeppelinUrl/api/notebook/interpreter/bind/$notebookId"
      val interpreters = wsClient.url(bindUrl).get()
      val interpreterIds = jsonBody(interpreters) \\ "id"
      val bindResp = wsClient.url(bindUrl).put(JsArray(interpreterIds))
      jsonBody(bindResp)
    }

    def restartInterpreters() = {
      val settingsUrl = s"$zeppelinUrl/api/interpreter/setting"
      val interpreterIds = (jsonBody(wsClient.url(settingsUrl).get()) \\ "id").map(value => value.toString().replace("\"", ""))
      interpreterIds.foreach { interpreterId =>
        val restartUrl = s"$zeppelinUrl/api/interpreter/setting/restart/$interpreterId"
        jsonBody(wsClient.url(restartUrl).withMethod("PUT").execute(), timeout = 1.minute)
      }
    }

    bindInterpreters()
    restartInterpreters()

    val notebookJobUrl = s"$zeppelinUrl/api/notebook/job/$notebookId"

    val notebookBeforeRun = jsonBody(
      wsClient.url(notebookJobUrl).get()
    )

    val paragraphsCount = (notebookBeforeRun \ "body" \\ "status").size
    println(s"paragraphsCount $paragraphsCount")

    assert((notebookBeforeRun \\ "status") contains JsString("READY"))

    // run notebook
    jsonBody(
      wsClient.url(notebookJobUrl).post(JsObject(Seq())), timeout = 5.seconds
    )

    // eventually all paragraphs should be in FINISHED status
    eventually(timeout(3.minutes), interval(5.second)) {
      val jobStatus = jsonBody(
        wsClient.url(notebookJobUrl).get()
      )
      val finished = (jobStatus \ "body" \\ "status").collect { case s@JsString("FINISHED") => s }
      val finishedCount = finished.size
      println(s"finished count $finishedCount/$paragraphsCount")
      assert(finishedCount == paragraphsCount)
    }
  }


}
