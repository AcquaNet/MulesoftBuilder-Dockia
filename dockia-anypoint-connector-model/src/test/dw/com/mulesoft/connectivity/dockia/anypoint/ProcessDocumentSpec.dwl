%dw 2.8
// Nivel A — Solo transformaciones (sin ejecutar HTTP ni el executor).
// - Entrada: objeto tipo Studio → request interno (query, headers, cookie, body).
// - Salida: extractRequestBody sobre un HttpResponse de ejemplo.
import * from dw::test::Tests
import * from dw::test::Asserts

import fromMapping, extractRequestBody from com::mulesoft::connectivity::codegen::Transformation

import anypoint_O_api_v1_extract_upload_post_mapping from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_extract_upload_post

var toConnectivityRequest = fromMapping(anypoint_O_api_v1_extract_upload_post_mapping)

// Base64 mínimo (un byte); el executor lo decodifica para el multipart.
var tinyPdfBase64 = "QQ=="

var sampleProcessEnvelope = {
  success: true,
  correlationId: "spec-corr-1",
  data: {
    uid: "uid-spec",
    message: "queued",
    task_id: 42
  }
}

var mockHttp200 = {
  status: 200,
  headers: { "Content-Type": "application/json" },
  cookies: {},
  body: sampleProcessEnvelope
}

---
"Process Document (processDocument)" describedBy [

  "Input — Anypoint → connectivity request" describedBy [

    "maps source, optional query fields, Base64 file; headers and cookie empty" in do {
      var r = toConnectivityRequest({
        source: "src-main",
        subject: "sub-a",
        "upload-uid": "uid-7",
        reprocess: true,
        "uploadPdf--body": tinyPdfBase64
      })
      ---
      [
        r.query.source must equalTo("src-main"),
        r.query.subject must equalTo("sub-a"),
        r.query."upload-uid" must equalTo("uid-7"),
        r.query.reprocess must equalTo(true),
        r.body.file must equalTo(tinyPdfBase64),
        r.headers must equalTo({}),
        r.cookie must equalTo({})
      ]
    },

    "maps only required source and file when optional Studio fields are omitted" in do {
      var r = toConnectivityRequest({
        source: "minimal-src",
        "uploadPdf--body": tinyPdfBase64
      })
      ---
      [
        r.query.source must equalTo("minimal-src"),
        r.body.file must equalTo(tinyPdfBase64),
        r.headers must equalTo({}),
        r.cookie must equalTo({})
      ]
    }

  ],

  "Output — extractRequestBody (HttpResponse → payload)" describedBy [

    "exposes API body fields and HTTP transport metadata on success" in do {
      var out = extractRequestBody(mockHttp200)
      var ta = out.^transportAttributes
      ---
      [
        out.success must equalTo(sampleProcessEnvelope.success),
        out.correlationId must equalTo(sampleProcessEnvelope.correlationId),
        out.data.uid must equalTo(sampleProcessEnvelope.data.uid),
        out.data.task_id must equalTo(sampleProcessEnvelope.data.task_id),
        ta.kind must equalTo("http"),
        ta.statusCode must equalTo(200),
        ta.headers must equalTo(mockHttp200.headers),
        ta.cookies must equalTo(mockHttp200.cookies)
      ]
    }

  ]

]
