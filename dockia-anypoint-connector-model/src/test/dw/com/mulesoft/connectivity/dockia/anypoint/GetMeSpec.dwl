%dw 2.8
import * from dw::test::Tests
import * from dw::test::Asserts

import fromMapping, extractRequestBody from com::mulesoft::connectivity::codegen::Transformation

import anypoint_O_api_v1_auth_me_get_mapping from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_auth_me_get

var getMeRequestMapper = fromMapping(anypoint_O_api_v1_auth_me_get_mapping)

var sampleLoginApiEnvelope = {
  success: true,
  correlationId: "corr-out-1",
  data: {
    username: "dockia-user",
    email: "user@tenant.com",
    role: "ADMIN",
    token: "opaque-token"
  }
}

var mockHttp200 = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleLoginApiEnvelope
}

---
"Get Me (getUserInfo)" describedBy [

  "Input — Anypoint → connectivity request" describedBy [

    "maps to empty query, headers and cookie (no connector input fields)" in do {
      var r = getMeRequestMapper({})
      ---
      [
        r.query must equalTo({}),
        r.headers must equalTo({}),
        r.cookie must equalTo({})
      ]
    },

    "ignores extra properties on input object" in do {
      var r = getMeRequestMapper({ foo: "bar", n: 1 })
      ---
      [
        r.query must equalTo({}),
        r.headers must equalTo({}),
        r.cookie must equalTo({})
      ]
    }

  ],

  "Output — extractRequestBody (HttpResponse → payload expuesto)" describedBy [

    "preserves API envelope fields from response.body" in do {
      var out = extractRequestBody(mockHttp200)
      ---
      [
        out.success must equalTo(sampleLoginApiEnvelope.success),
        out.correlationId must equalTo(sampleLoginApiEnvelope.correlationId),
        out.data.username must equalTo(sampleLoginApiEnvelope.data.username),
        out.data.email must equalTo(sampleLoginApiEnvelope.data.email),
        out.data.role must equalTo(sampleLoginApiEnvelope.data.role),
        out.data.token must equalTo(sampleLoginApiEnvelope.data.token)
      ]
    },

    "injects HTTP transport metadata (status, headers, cookies)" in do {
      var out = extractRequestBody(mockHttp200)
      var ta = out.^transportAttributes
      ---
      [
        ta.kind must equalTo("http"),
        ta.statusCode must equalTo(200),
        ta.headers must equalTo(mockHttp200.headers),
        ta.cookies must equalTo(mockHttp200.cookies)
      ]
    }

  ]

]
