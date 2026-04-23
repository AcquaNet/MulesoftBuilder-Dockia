%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import Result, ResultFailure, UnexpectedError, success, unexpectedFailure from com::mulesoft::connectivity::Model

import T_ApiResponseMapStringObject from com::mulesoft::connectivity::dockia::types::Types

import HttpConnection, HttpRequestType, HttpResponse from com::mulesoft::connectivity::transport::Http

import serializeCookies, serializeHeaders, withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

import fromBase64 from dw::core::Binaries

type O_api_v1_extract_upload_post_Type = {
  "200": HttpResponse<T_ApiResponseMapStringObject>,
  errorResponse: ResultFailure<HttpResponse<Any>, UnexpectedError>,
  request: HttpRequestType<{| query: { source: String, subject?: String, "upload-uid"?: String, reprocess?: Boolean }, headers: Object, cookie: Object, body?: { file: String } |}>,
  response: O_api_v1_extract_upload_post_Type."200"
}

@OperationElement()
var O_api_v1_extract_upload_post = {
  name: "processDocument",
  displayName: "Process Document",
  description: "Uploads a PDF document to Dockia for AI-powered data extraction. Returns a task identifier to track the processing status and retrieve results.",
  executor: (parameter: O_api_v1_extract_upload_post_Type.request, connection: HttpConnection): Result<O_api_v1_extract_upload_post_Type.response, O_api_v1_extract_upload_post_Type.errorResponse> -> do {
      var query = parameter.query default {} withSerializationConfig {}
      var headers = serializeHeaders(parameter.headers default {}, {})
      var cookie = serializeCookies(parameter.cookie default {}, {})
      var fileBytes = if (parameter.body? and parameter.body.file?) fromBase64(parameter.body.file as String) else null
      var response = connection({
        method: "POST",
        path: "/api/v1/extract/upload",
        queryParams: query,
        headers: headers,
        config: {
          contentType: "multipart/form-data"
        },
        cookie: cookie,
        (body: {
          parts: {
            file: {
              headers: {
                "Content-Disposition": {
                  name: "file",
                  filename: "document.pdf"
                },
                "Content-Type": "application/pdf"
              },
              content: fileBytes
            }
          }
        }) if (fileBytes != null)
      })
      var statusCode = response.status as String
      var parsedBody = (read(response.body as String, "application/json") default {}) as T_ApiResponseMapStringObject
      var typedResponse = response update { case .body! -> parsedBody }
      ---
      if (response.status == 200)
        success(typedResponse)
      else
        unexpectedFailure(
          typedResponse,
          { kind: statusCode, categories: [] }
        )
    }
}

