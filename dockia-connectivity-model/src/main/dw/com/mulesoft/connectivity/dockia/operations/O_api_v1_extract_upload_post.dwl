%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import Result, ResultFailure, UnexpectedError, success, unexpectedFailure from com::mulesoft::connectivity::Model

import T_ApiResponseMapStringObject from com::mulesoft::connectivity::dockia::types::Types

import HttpConnection, HttpRequestType, HttpResponse from com::mulesoft::connectivity::transport::Http

import serializeCookies, serializeHeaders, withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

type O_api_v1_extract_upload_post_Type = {
  "200": HttpResponse<T_ApiResponseMapStringObject>,
  errorResponse: ResultFailure<HttpResponse<Any>, UnexpectedError>,
  request: HttpRequestType<{| query: { source: String, subject?: String, "upload-uid"?: String, reprocess?: Boolean }, headers: Object, cookie: Object, body?: { file: Binary } |}>,
  response: O_api_v1_extract_upload_post_Type."200"
}

@OperationElement()
var O_api_v1_extract_upload_post = {
  name: "uploadPdf",
  displayName: "uploadPdf",
  executor: (parameter: O_api_v1_extract_upload_post_Type.request, connection: HttpConnection): Result<O_api_v1_extract_upload_post_Type.response, O_api_v1_extract_upload_post_Type.errorResponse> -> do {
      var query = parameter.query default {} withSerializationConfig {}
      var headers = serializeHeaders(parameter.headers default {}, {})
      var cookie = serializeCookies(parameter.cookie default {}, {})
      var response = connection({
        method: "POST",
        path: "/api/v1/extract/upload",
        queryParams: query,
        headers: headers,
        config: {
          contentType: "multipart/form-data"
        },
        cookie: cookie,
        (body: parameter.body) if (parameter.body?)
      })
      var statusCode = response.status as String
      ---
      if (response.status == 200 and response is O_api_v1_extract_upload_post_Type."200")
        success(response)
      else
        unexpectedFailure(response, {
          kind: statusCode,
          categories: []
        })
    }
}

