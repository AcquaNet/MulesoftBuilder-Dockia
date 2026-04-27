%dw 2.8
// Nivel B — Executor de conectividad: GET /api/v1/extraction-tasks/{taskId}, query/headers/cookie serializados.
import * from dw::test::Tests
import * from dw::test::Asserts

import fail from dw::Runtime

import serializeCookies, serializeHeaders, serializeUriParams, withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

import O_api_v1_extraction_tasks__taskId__get from com::mulesoft::connectivity::dockia::operations::O_api_v1_extraction_tasks__taskId__get

var taskId = 4242

var uriSerialized = serializeUriParams({ taskId: taskId }, {})

var expectedPath = "/api/v1/extraction-tasks/$(uriSerialized.taskId)"

var baseParam = {
  uri: { taskId: taskId },
  query: {},
  headers: {},
  cookie: {}
}

var paramWithQuery = {
  uri: { taskId: taskId },
  query: { trace: "t1", verbose: "true" },
  headers: {},
  cookie: {}
}

var paramWithHeaders = {
  uri: { taskId: taskId },
  query: {},
  headers: { "X-Dockia-Test": "gd-h1" },
  cookie: {}
}

var paramWithCookie = {
  uri: { taskId: taskId },
  query: {},
  headers: {},
  cookie: { sid: "ck-gd-1" }
}

var sampleOk = {
  success: true,
  correlationId: "gd-exec-ok",
  data: { id: taskId, status: "RUNNING" }
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
  body: { error: "not found" }
}

var bodyBadIdType = {
  success: true,
  correlationId: "gd-bad-type",
  data: { id: "not-int64", status: "X" }
}

var http200BadType = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: bodyBadIdType
}

fun queryParamsContainExpected(req, expectedQuery: Object): Boolean =
  isEmpty(
    (keysOf(expectedQuery) as Array<String>) filter (k) ->
      (req.queryParams[k] default null) != expectedQuery[k]
  )

fun headersContainExpected(req, expectedHeaders: Object): Boolean =
  isEmpty(
    (keysOf(expectedHeaders) as Array<String>) filter (k) ->
      (req.headers[k] default null) != expectedHeaders[k]
  )

fun cookiesContainExpected(req, expectedCookies: Object): Boolean =
  isEmpty(
    (keysOf(expectedCookies) as Array<String>) filter (k) ->
      (req.cookie[k] default null) != expectedCookies[k]
  )

fun mockGetDoc(resp, path: String) =
  (req) ->
    if (req.method != "GET")
      fail("Get Document must use GET, got: " ++ write(req.method))
    else if (req.path != path)
      fail("Get Document path expected " ++ path ++ ", got: " ++ (req.path default ""))
    else
      resp

fun mockGetDocFull(resp, path: String, expectedQuery: Object, expectedHeaders: Object, expectedCookies: Object) =
  (req) ->
    if (req.method != "GET")
      fail("Get Document must use GET, got: " ++ write(req.method))
    else if (req.path != path)
      fail("path mismatch: " ++ (req.path default ""))
    else if (not queryParamsContainExpected(req, expectedQuery))
      fail("queryParams: " ++ write(req.queryParams default {}))
    else if (not headersContainExpected(req, expectedHeaders))
      fail("headers: " ++ write(req.headers default {}))
    else if (not cookiesContainExpected(req, expectedCookies))
      fail("cookie: " ++ write(req.cookie default {}))
    else
      resp

var mock200 = mockGetDoc(http200, expectedPath)

var mock200Query =
  mockGetDocFull(
    http200,
    expectedPath,
    paramWithQuery.query withSerializationConfig {},
    serializeHeaders(paramWithQuery.headers, {}),
    serializeCookies(paramWithQuery.cookie, {})
  )

var mock200Headers =
  mockGetDocFull(
    http200,
    expectedPath,
    baseParam.query withSerializationConfig {},
    serializeHeaders(paramWithHeaders.headers, {}),
    serializeCookies(paramWithHeaders.cookie, {})
  )

var mock200Cookie =
  mockGetDocFull(
    http200,
    expectedPath,
    baseParam.query withSerializationConfig {},
    serializeHeaders(paramWithCookie.headers, {}),
    serializeCookies(paramWithCookie.cookie, {})
  )

var mock404 = mockGetDoc(http404, expectedPath)

var mock200BadType = mockGetDoc(http200BadType, expectedPath)

---
"Get Document — executor (O_api_v1_extraction_tasks__taskId__get)" describedBy [

  "Success path" describedBy [

    "GET with serialized taskId in path and 200 typed body → ResultSuccess" in do {
      var result = O_api_v1_extraction_tasks__taskId__get.executor(baseParam, mock200)
      ---
      [
        result.success must equalTo(true),
        result.value.status must equalTo(200),
        result.value.body.data.id must equalTo(taskId),
        result.value.body.correlationId must equalTo(sampleOk.correlationId)
      ]
    }

  ],

  "Query, header and cookie forwarding" describedBy [

    "forwards parameter.query to queryParams" in do {
      var result = O_api_v1_extraction_tasks__taskId__get.executor(paramWithQuery, mock200Query)
      ---
      [ result.success must equalTo(true), result.value.body.success must equalTo(true) ]
    },

    "forwards parameter.headers via serializeHeaders" in do {
      var result = O_api_v1_extraction_tasks__taskId__get.executor(paramWithHeaders, mock200Headers)
      ---
      [ result.success must equalTo(true) ]
    },

    "forwards parameter.cookie via serializeCookies" in do {
      var result = O_api_v1_extraction_tasks__taskId__get.executor(paramWithCookie, mock200Cookie)
      ---
      [ result.success must equalTo(true) ]
    }

  ],

  "HTTP 200 but body fails typed envelope" describedBy [

    "unexpectedFailure when 200 but data.id is not Int64" in do {
      var result = O_api_v1_extraction_tasks__taskId__get.executor(baseParam, mock200BadType)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(200),
        result.error.value.body.data.id must equalTo(bodyBadIdType.data.id)
      ]
    }

  ],

  "Non-200 HTTP" describedBy [

    "unexpectedFailure preserves HttpResponse on error.value (e.g. 404)" in do {
      var result = O_api_v1_extraction_tasks__taskId__get.executor(baseParam, mock404)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(404),
        result.error.value.body.error must equalTo("not found")
      ]
    }

  ]

]
