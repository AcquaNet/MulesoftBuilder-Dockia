%dw 2.8
import * from dw::test::Tests
import * from dw::test::Asserts

import fail from dw::Runtime

import serializeCookies, serializeHeaders, withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

import O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::operations::O_api_v1_auth_me_get

var emptyConnectivityRequest = {
  query: {},
  headers: {},
  cookie: {}
}

var connectivityRequestWithQuery = {
  query: {
    marker: "forwarded",
    trace: "t-99"
  },
  headers: {},
  cookie: {}
}

var connectivityRequestHeadersOnly = {
  query: {},
  headers: { "X-Dockia-Forward": "hdr-forwarded-1" },
  cookie: {}
}

var connectivityRequestCookieOnly = {
  query: {},
  headers: {},
  cookie: { traceCk: "cookie-forwarded-1" }
}

var sampleLoginBody = {
  success: true,
  correlationId: "exec-corr-1",
  data: {
    username: "executor-user",
    email: "exec@tenant.com",
    role: "USER",
    token: "tok"
  }
}

var http200 = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleLoginBody
}

var http401 = {
  status: 401,
  headers: {},
  cookies: {},
  body: { success: false, error: "Unauthorized" }
}

// 200 + body where data.tenant is String; typed envelope expects T_TenantInfo.
var sampleLoginBodyWrongNestedType = {
  success: true,
  correlationId: "exec-type-mismatch",
  data: {
    username: "u",
    email: "e@x.com",
    role: "USER",
    token: "t",
    tenant: "not-a-tenant-object"
  }
}

var http200BodyFailsTypeCheck = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleLoginBodyWrongNestedType
}

fun mockGetMeConnection(resp) =
  (req) ->
    if (req.method != "GET")
      fail("Get Me executor must use GET, got: " ++ write(req.method))
    else if (req.path != "/api/v1/auth/me")
      fail("Get Me executor path must be /api/v1/auth/me, got: " ++ (req.path default ""))
    else
      resp

fun queryParamsContainExpected(req, expectedQuery: Object): Boolean =
  isEmpty(
    (keysOf(expectedQuery) as Array<String>) filter (k) ->
      (req.queryParams[k] default null) != expectedQuery[k]
  )

fun mockGetMeConnectionWithExpectedQuery(resp, expectedQuery: Object) =
  (req) ->
    if (req.method != "GET")
      fail("Get Me executor must use GET, got: " ++ write(req.method))
    else if (req.path != "/api/v1/auth/me")
      fail("Get Me executor path must be /api/v1/auth/me, got: " ++ (req.path default ""))
    else if (not queryParamsContainExpected(req, expectedQuery))
      fail(
        "queryParams must include serialized query. Expected keys: "
          ++ write(expectedQuery)
          ++ " — actual queryParams: "
          ++ write(req.queryParams)
      )
    else
      resp

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

fun mockGetMeConnectionWithExpectedQueryHeadersCookies(
  resp,
  expectedQuery: Object,
  expectedHeaders: Object,
  expectedCookies: Object
) =
  (req) ->
    if (req.method != "GET")
      fail("Get Me executor must use GET, got: " ++ write(req.method))
    else if (req.path != "/api/v1/auth/me")
      fail("Get Me executor path must be /api/v1/auth/me, got: " ++ (req.path default ""))
    else if (not queryParamsContainExpected(req, expectedQuery))
      fail(
        "queryParams must match serialized query. Expected: "
          ++ write(expectedQuery)
          ++ " — actual: "
          ++ write(req.queryParams default {})
      )
    else if (not headersContainExpected(req, expectedHeaders))
      fail(
        "headers must match serializeHeaders(parameter.headers). Expected: "
          ++ write(expectedHeaders)
          ++ " — actual: "
          ++ write(req.headers default {})
      )
    else if (not cookiesContainExpected(req, expectedCookies))
      fail(
        "cookie must match serializeCookies(parameter.cookie). Expected: "
          ++ write(expectedCookies)
          ++ " — actual: "
          ++ write(req.cookie default {})
      )
    else
      resp

var mockConnection200 = mockGetMeConnection(http200)

var mockConnection401 = mockGetMeConnection(http401)

var mockConnection200BodyFailsTypeCheck = mockGetMeConnection(http200BodyFailsTypeCheck)

var mockConnection200QueryForward =
  mockGetMeConnectionWithExpectedQuery(http200, connectivityRequestWithQuery.query)

var mockConnection200HeadersForward =
  mockGetMeConnectionWithExpectedQueryHeadersCookies(
    http200,
    connectivityRequestHeadersOnly.query withSerializationConfig {},
    serializeHeaders(connectivityRequestHeadersOnly.headers, {}),
    serializeCookies(connectivityRequestHeadersOnly.cookie, {})
  )

var mockConnection200CookieForward =
  mockGetMeConnectionWithExpectedQueryHeadersCookies(
    http200,
    connectivityRequestCookieOnly.query withSerializationConfig {},
    serializeHeaders(connectivityRequestCookieOnly.headers, {}),
    serializeCookies(connectivityRequestCookieOnly.cookie, {})
  )

---
"Get Me — executor (O_api_v1_auth_me_get)" describedBy [

  "Success path" describedBy [

    "returns ResultSuccess with HttpResponse when connection returns 200 + typed body" in do {
      var result = O_api_v1_auth_me_get.executor(emptyConnectivityRequest, mockConnection200)
      ---
      [
        result.success must equalTo(true),
        result.value.status must equalTo(200),
        result.value.body.success must equalTo(true),
        result.value.body.correlationId must equalTo(sampleLoginBody.correlationId),
        result.value.body.data.username must equalTo(sampleLoginBody.data.username)
      ]
    }

  ],

  "HTTP 200 but response body fails typed 200 envelope" describedBy [

    "returns ResultFailure (unexpectedFailure) when status is 200 but body is not T_ApiResponseLoginResponse" in do {
      var result = O_api_v1_auth_me_get.executor(emptyConnectivityRequest, mockConnection200BodyFailsTypeCheck)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(200),
        result.error.value.body.correlationId must equalTo(sampleLoginBodyWrongNestedType.correlationId),
        result.error.value.body.data.tenant must equalTo(sampleLoginBodyWrongNestedType.data.tenant)
      ]
    }

  ],

  "Query forwarding (connectivity request)" describedBy [

    "forwards parameter.query to connection queryParams (with empty serialization config)" in do {
      var result = O_api_v1_auth_me_get.executor(connectivityRequestWithQuery, mockConnection200QueryForward)
      ---
      [
        result.success must equalTo(true),
        result.value.body.correlationId must equalTo(sampleLoginBody.correlationId)
      ]
    }

  ],

  "Header and cookie forwarding (connectivity request)" describedBy [

    "forwards parameter.headers via serializeHeaders to connection request" in do {
      var result = O_api_v1_auth_me_get.executor(connectivityRequestHeadersOnly, mockConnection200HeadersForward)
      ---
      [
        result.success must equalTo(true),
        result.value.body.correlationId must equalTo(sampleLoginBody.correlationId)
      ]
    },

    "forwards parameter.cookie via serializeCookies to connection request" in do {
      var result = O_api_v1_auth_me_get.executor(connectivityRequestCookieOnly, mockConnection200CookieForward)
      ---
      [
        result.success must equalTo(true),
        result.value.body.correlationId must equalTo(sampleLoginBody.correlationId)
      ]
    }

  ],

  "Failure path" describedBy [

    "returns ResultFailure when HTTP status is not 200" in do {
      var result = O_api_v1_auth_me_get.executor(emptyConnectivityRequest, mockConnection401)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(401),
        result.error.value.body.error must equalTo("Unauthorized")
      ]
    }

  ]

]
