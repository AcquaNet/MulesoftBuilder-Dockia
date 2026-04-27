%dw 2.8
// Nivel B — Executor de conectividad O_api_v1_extract_upload_post + función que simula el HTTP.
// Comprueba método, path, query serializado, multipart (cuando hay archivo), y tipos de error (4xx vs resto).
import * from dw::test::Tests
import * from dw::test::Asserts

import fail from dw::Runtime

import fromBase64 from dw::core::Binaries

import withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

import O_api_v1_extract_upload_post from com::mulesoft::connectivity::dockia::operations::O_api_v1_extract_upload_post

var tinyPdfBase64 = "QQ=="

var fileBytes = fromBase64(tinyPdfBase64)

var connectivityMinimal = {
  query: { source: "exec-src" },
  headers: {},
  cookie: {},
  body: { file: tinyPdfBase64 }
}

var connectivityWithSubject = {
  query: { source: "exec-src", subject: "sub-x" },
  headers: {},
  cookie: {},
  body: { file: tinyPdfBase64 }
}

var connectivityNoFile = {
  query: { source: "no-file" },
  headers: {},
  cookie: {}
}

var sampleOkBody = {
  success: true,
  correlationId: "exec-corr-pd",
  data: { uid: "u1", message: "ok", task_id: 1 }
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
  body: { error: "Bad upload" }
}

var http500 = {
  status: 500,
  headers: {},
  cookies: {},
  body: { message: "internal" }
}

var bodyWrongTaskIdType = {
  success: true,
  correlationId: "type-bad",
  data: { uid: "u", task_id: "not-an-int64" }
}

var http200WrongType = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: bodyWrongTaskIdType
}

fun queryParamsContainExpected(req, expectedQuery: Object): Boolean =
  isEmpty(
    (keysOf(expectedQuery) as Array<String>) filter (k) ->
      (req.queryParams[k] default null) != expectedQuery[k]
  )

fun multipartFileContentMatches(req, expected: Binary): Boolean =
  (req.body.parts.file.content default null) == expected

fun mockUpload(resp) =
  (req) ->
    if (req.method != "POST")
      fail("Process Document must use POST, got: " ++ write(req.method))
    else if (req.path != "/api/v1/extract/upload")
      fail("path must be /api/v1/extract/upload, got: " ++ (req.path default ""))
    else
      resp

fun mockUploadExpectQueryAndMultipart(resp, expectedQuery: Object, expectFile: Boolean) =
  (req) ->
    if (req.method != "POST")
      fail("Process Document must use POST, got: " ++ write(req.method))
    else if (req.path != "/api/v1/extract/upload")
      fail("path must be /api/v1/extract/upload, got: " ++ (req.path default ""))
    else if (not queryParamsContainExpected(req, expectedQuery))
      fail(
        "queryParams mismatch. Expected: "
          ++ write(expectedQuery)
          ++ " actual: "
          ++ write(req.queryParams default {})
      )
    else if ((req.config.contentType default "") != "multipart/form-data")
      fail("config.contentType must be multipart/form-data, got: " ++ write(req.config default {}))
    else if (expectFile and not multipartFileContentMatches(req, fileBytes))
      fail(
        "multipart file content must match fromBase64(file). Expected bytes size "
          ++ (sizeOf(fileBytes) as String)
          ++ " actual: "
          ++ write(req.body.parts.file.content default null)
      )
    else
      resp

var mock200Multipart =
  mockUploadExpectQueryAndMultipart(http200, connectivityMinimal.query withSerializationConfig {}, true)

var mock200QuerySubject =
  mockUploadExpectQueryAndMultipart(http200, connectivityWithSubject.query withSerializationConfig {}, true)

var mock400 = mockUpload(http400)

var mock500 = mockUpload(http500)

var mock200BadType = mockUpload(http200WrongType)

var mock200NoFile =
  mockUploadExpectQueryAndMultipart(http200, connectivityNoFile.query withSerializationConfig {}, false)

---
"Process Document — executor (O_api_v1_extract_upload_post)" describedBy [

  "Success path" describedBy [

    "POST + multipart file + 200 typed body → ResultSuccess" in do {
      var result = O_api_v1_extract_upload_post.executor(connectivityMinimal, mock200Multipart)
      ---
      [
        result.success must equalTo(true),
        result.value.status must equalTo(200),
        result.value.body.data.uid must equalTo(sampleOkBody.data.uid),
        result.value.body.correlationId must equalTo(sampleOkBody.correlationId)
      ]
    },

    "forwards serialized query (e.g. subject) to queryParams" in do {
      var result = O_api_v1_extract_upload_post.executor(connectivityWithSubject, mock200QuerySubject)
      ---
      [
        result.success must equalTo(true),
        result.value.body.success must equalTo(true)
      ]
    },

    "when body.file is absent, sends POST without multipart body" in do {
      var result = O_api_v1_extract_upload_post.executor(connectivityNoFile, mock200NoFile)
      ---
      [
        result.success must equalTo(true),
        result.value.body.correlationId must equalTo(sampleOkBody.correlationId)
      ]
    }

  ],

  "HTTP 200 but body fails typed envelope" describedBy [

    "returns unexpectedFailure when status 200 but body is not T_ProcessDocumentResponse" in do {
      var result = O_api_v1_extract_upload_post.executor(connectivityMinimal, mock200BadType)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(200),
        result.error.value.body.data.task_id must equalTo(bodyWrongTaskIdType.data.task_id)
      ]
    }

  ],

  "Client error (4xx)" describedBy [

    "uses failure() with CLIENT_ERROR for HTTP 400" in do {
      var result = O_api_v1_extract_upload_post.executor(connectivityMinimal, mock400)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(400),
        result.error.kind must equalTo("400"),
        result.error.categories must equalTo(["CLIENT_ERROR"]),
        result.error.description must equalTo("Bad upload")
      ]
    }

  ],

  "Server / unexpected errors" describedBy [

    "uses unexpectedFailure for HTTP 500" in do {
      var result = O_api_v1_extract_upload_post.executor(connectivityMinimal, mock500)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(500)
      ]
    }

  ]

]
