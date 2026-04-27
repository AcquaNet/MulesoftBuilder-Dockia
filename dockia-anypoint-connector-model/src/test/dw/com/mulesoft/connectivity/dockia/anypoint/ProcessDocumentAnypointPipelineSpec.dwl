%dw 2.8
// Nivel C — Operación Anypoint completa: mismo executor que Studio (mapping + extractRequestBody).
import * from dw::test::Tests
import * from dw::test::Asserts

import fail from dw::Runtime

import fromBase64 from dw::core::Binaries

import withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

import anypoint_O_api_v1_extract_upload_post from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_extract_upload_post

var tinyPdfBase64 = "QQ=="

var fileBytes = fromBase64(tinyPdfBase64)

var studioInputFull = {
  source: "pipe-src",
  subject: "pipe-sub",
  "uploadPdf--body": tinyPdfBase64
}

var connectivityFromStudio = {
  query: { source: "pipe-src", subject: "pipe-sub" },
  headers: {},
  cookie: {},
  body: { file: tinyPdfBase64 }
}

var sampleOkBody = {
  success: true,
  correlationId: "pipe-corr-pd",
  data: { uid: "pu1", message: "queued", task_id: 9 }
}

var http200 = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleOkBody
}

var http400 = {
  status: 400,
  headers: {},
  cookies: {},
  body: { error: "reject" }
}

var bodyWrongType = {
  success: true,
  correlationId: "pipe-bad-type",
  data: { task_id: "x" }
}

var http200BadType = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: bodyWrongType
}

fun queryParamsContainExpected(req, expectedQuery: Object): Boolean =
  isEmpty(
    (keysOf(expectedQuery) as Array<String>) filter (k) ->
      (req.queryParams[k] default null) != expectedQuery[k]
  )

fun multipartFileContentMatches(req, expected: Binary): Boolean =
  (req.body.parts.file.content default null) == expected

fun mockUploadExpectQueryAndMultipart(resp, expectedQuery: Object, expectFile: Boolean) =
  (req) ->
    if (req.method != "POST")
      fail("Process Document must use POST, got: " ++ write(req.method))
    else if (req.path != "/api/v1/extract/upload")
      fail("path must be /api/v1/extract/upload, got: " ++ (req.path default ""))
    else if (not queryParamsContainExpected(req, expectedQuery))
      fail("queryParams mismatch: " ++ write(req.queryParams default {}))
    else if ((req.config.contentType default "") != "multipart/form-data" and expectFile)
      fail("expected multipart when file present")
    else if (expectFile and not multipartFileContentMatches(req, fileBytes))
      fail("multipart content mismatch")
    else
      resp

fun mockUpload(resp) =
  (req) ->
    if (req.method != "POST")
      fail("POST expected")
    else if (req.path != "/api/v1/extract/upload")
      fail("path expected")
    else
      resp

var mock200Pipeline =
  mockUploadExpectQueryAndMultipart(http200, connectivityFromStudio.query withSerializationConfig {}, true)

var mock400 = (req) ->
  if (req.method != "POST")
    fail("POST expected")
  else if (req.path != "/api/v1/extract/upload")
    fail("path expected")
  else
    http400

var mock200BadType = mockUpload(http200BadType)

---
"Process Document — Anypoint pipeline (withTransformer + extractRequestBody)" describedBy [

  "Success path" describedBy [

    "maps Studio fields, POST multipart, returns extracted envelope (not raw HttpResponse)" in do {
      var result = anypoint_O_api_v1_extract_upload_post.executor(studioInputFull, mock200Pipeline)
      ---
      [
        result.success must equalTo(true),
        result.value.success must equalTo(true),
        result.value.correlationId must equalTo(sampleOkBody.correlationId),
        result.value.data.uid must equalTo(sampleOkBody.data.uid),
        result.value.data.task_id must equalTo(sampleOkBody.data.task_id),
        result.value.^transportAttributes.statusCode must equalTo(200)
      ]
    }

  ],

  "Failure path" describedBy [

    "4xx: error.value is full HttpResponse; description from API error string" in do {
      var result = anypoint_O_api_v1_extract_upload_post.executor(studioInputFull, mock400)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(400),
        result.error.value.body.error must equalTo("reject"),
        result.error.kind must equalTo("400"),
        result.error.categories must equalTo(["CLIENT_ERROR"])
      ]
    },

    "200 with invalid typed body: failure, HttpResponse on error.value" in do {
      var result = anypoint_O_api_v1_extract_upload_post.executor(studioInputFull, mock200BadType)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(200),
        result.error.value.body.data.task_id must equalTo(bodyWrongType.data.task_id)
      ]
    }

  ]

]
