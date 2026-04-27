%dw 2.8
// Nivel A — Mapeo Studio → request interno y extractRequestBody (sin executor ni HTTP simulado como función).
import * from dw::test::Tests
import * from dw::test::Asserts

import fromMapping, extractRequestBody from com::mulesoft::connectivity::codegen::Transformation

import anypoint_O_api_v1_extraction_tasks__taskId__get_mapping from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_extraction_tasks__taskId__get

var toRequest = fromMapping(anypoint_O_api_v1_extraction_tasks__taskId__get_mapping)

var sampleTaskEnvelope = {
  success: true,
  correlationId: "gd-spec-1",
  data: {
    id: 500,
    status: "COMPLETED",
    correlationId: "inner-corr-1",
    source: "api"
  }
}

var mockHttp200 = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleTaskEnvelope
}

---
"Get Document (getDocument)" describedBy [

  "Input — Anypoint → connectivity request" describedBy [

    "maps taskId into uri.taskId; query, headers and cookie empty" in do {
      var r = toRequest({ taskId: 42 })
      ---
      [
        r.uri.taskId must equalTo(42),
        r.query must equalTo({}),
        r.headers must equalTo({}),
        r.cookie must equalTo({})
      ]
    },

    "maps another numeric taskId to uri.taskId" in do {
      var r = toRequest({ taskId: 999 })
      ---
      [ r.uri.taskId must equalTo(999) ]
    }

  ],

  "Output — extractRequestBody" describedBy [

    "exposes task detail fields and transport metadata on 200" in do {
      var out = extractRequestBody(mockHttp200)
      var ta = out.^transportAttributes
      ---
      [
        out.success must equalTo(sampleTaskEnvelope.success),
        out.correlationId must equalTo(sampleTaskEnvelope.correlationId),
        out.data.id must equalTo(sampleTaskEnvelope.data.id),
        out.data.status must equalTo(sampleTaskEnvelope.data.status),
        ta.kind must equalTo("http"),
        ta.statusCode must equalTo(200),
        ta.headers must equalTo(mockHttp200.headers),
        ta.cookies must equalTo(mockHttp200.cookies)
      ]
    }

  ]

]
