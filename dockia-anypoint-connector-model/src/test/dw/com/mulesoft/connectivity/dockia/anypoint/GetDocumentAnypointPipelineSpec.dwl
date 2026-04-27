%dw 2.8
// Nivel C — Operación Anypoint getDocument (mapping + extractRequestBody + mismo executor que Studio).
import * from dw::test::Tests
import * from dw::test::Asserts

import fail from dw::Runtime

import serializeUriParams from com::mulesoft::connectivity::transport::Serialization

import anypoint_O_api_v1_extraction_tasks__taskId__get from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_extraction_tasks__taskId__get

var taskId = 7

var pathExpected = "/api/v1/extraction-tasks/$(serializeUriParams({ taskId: taskId }, {}).taskId)"

var studioIn = { taskId: taskId }

var sampleOk = {
  success: true,
  correlationId: "gd-pipe-1",
  data: { id: taskId, status: "COMPLETED", source: "test" }
}

var http200 = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleOk
}

var http404 = {
  status: 404,
  headers: {},
  cookies: {},
  body: { error: "missing" }
}

var bodyBad = {
  success: true,
  correlationId: "gd-pipe-bad",
  data: { id: "wrong-type" }
}

var http200Bad = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: bodyBad
}

fun mockGetDoc(resp) =
  (req) ->
    if (req.method != "GET")
      fail("GET expected")
    else if (req.path != pathExpected)
      fail("path expected " ++ pathExpected ++ " got " ++ (req.path default ""))
    else
      resp

var mock200 = mockGetDoc(http200)

var mock404 = mockGetDoc(http404)

var mock200Bad = mockGetDoc(http200Bad)

---
"Get Document — Anypoint pipeline (withTransformer + extractRequestBody)" describedBy [

  "Success path" describedBy [

    "returns extracted task envelope and transport metadata" in do {
      var result = anypoint_O_api_v1_extraction_tasks__taskId__get.executor(studioIn, mock200)
      ---
      [
        result.success must equalTo(true),
        result.value.success must equalTo(true),
        result.value.correlationId must equalTo(sampleOk.correlationId),
        result.value.data.status must equalTo(sampleOk.data.status),
        result.value.data.id must equalTo(taskId),
        result.value.^transportAttributes.statusCode must equalTo(200)
      ]
    }

  ],

  "Failure path" describedBy [

    "non-200: error.value is full HttpResponse (no extractRequestBody)" in do {
      var result = anypoint_O_api_v1_extraction_tasks__taskId__get.executor(studioIn, mock404)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(404),
        result.error.value.body.error must equalTo("missing")
      ]
    },

    "200 with invalid typed body: failure with HttpResponse on error.value" in do {
      var result = anypoint_O_api_v1_extraction_tasks__taskId__get.executor(studioIn, mock200Bad)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(200),
        result.error.value.body.data.id must equalTo(bodyBad.data.id)
      ]
    }

  ]

]
