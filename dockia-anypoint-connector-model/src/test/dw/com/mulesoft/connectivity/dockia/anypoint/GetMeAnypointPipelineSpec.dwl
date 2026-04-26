%dw 2.8
import * from dw::test::Tests
import * from dw::test::Asserts

import fail from dw::Runtime

import anypoint_O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_auth_me_get

var anypointStudioInputEmpty = {}

var sampleLoginBody = {
  success: true,
  correlationId: "pipeline-corr-1",
  data: {
    username: "pipeline-user",
    email: "pipe@tenant.com",
    role: "ADMIN",
    token: "pipeline-tok"
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

var sampleLoginBodyWrongNestedType = {
  success: true,
  correlationId: "pipeline-type-mismatch",
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
      fail("Get Me must use GET, got: " ++ write(req.method))
    else if (req.path != "/api/v1/auth/me")
      fail("Get Me path must be /api/v1/auth/me, got: " ++ (req.path default ""))
    else
      resp

var mockConnection200 = mockGetMeConnection(http200)

var mockConnection401 = mockGetMeConnection(http401)

var mockConnection200BodyFailsTypeCheck = mockGetMeConnection(http200BodyFailsTypeCheck)

---
"Get Me — Anypoint pipeline (withTransformer + extractRequestBody)" describedBy [

  "Success path" describedBy [

    "maps empty Studio input, calls GET /auth/me, returns extracted envelope (not HttpResponse)" in do {
      var result = anypoint_O_api_v1_auth_me_get.executor(anypointStudioInputEmpty, mockConnection200)
      ---
      [
        result.success must equalTo(true),
        result.value.success must equalTo(true),
        result.value.correlationId must equalTo(sampleLoginBody.correlationId),
        result.value.data.username must equalTo(sampleLoginBody.data.username),
        result.value.data.role must equalTo(sampleLoginBody.data.role),
        result.value.^transportAttributes.kind must equalTo("http"),
        result.value.^transportAttributes.statusCode must equalTo(200)
      ]
    },

    "ignores extra fields on Studio input object" in do {
      var result = anypoint_O_api_v1_auth_me_get.executor({ traceId: "abc", foo: 1 }, mockConnection200)
      ---
      [
        result.success must equalTo(true),
        result.value.data.email must equalTo(sampleLoginBody.data.email)
      ]
    }

  ],

  "Failure path" describedBy [

    "does not apply extractRequestBody to errors; error.value remains HttpResponse" in do {
      var result = anypoint_O_api_v1_auth_me_get.executor(anypointStudioInputEmpty, mockConnection401)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(401),
        result.error.value.body.error must equalTo("Unauthorized")
      ]
    },

    "HTTP 200 with body that fails typed 200: still failure, full HttpResponse on error.value" in do {
      var result = anypoint_O_api_v1_auth_me_get.executor(anypointStudioInputEmpty, mockConnection200BodyFailsTypeCheck)
      ---
      [
        result.success must equalTo(false),
        result.error.value.status must equalTo(200),
        result.error.value.body.correlationId must equalTo(sampleLoginBodyWrongNestedType.correlationId),
        result.error.value.body.data.tenant must equalTo(sampleLoginBodyWrongNestedType.data.tenant)
      ]
    }

  ]

]
