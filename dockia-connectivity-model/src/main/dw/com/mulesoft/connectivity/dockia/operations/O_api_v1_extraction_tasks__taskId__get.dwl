%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import Result, ResultFailure, UnexpectedError, success, unexpectedFailure from com::mulesoft::connectivity::Model

import Int64 from com::mulesoft::connectivity::Types

import T_ApiResponseExtractionTaskDetailResponse from com::mulesoft::connectivity::dockia::types::Types

import HttpConnection, HttpRequestType, HttpResponse from com::mulesoft::connectivity::transport::Http

import serializeCookies, serializeHeaders, serializeUriParams, withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

type O_api_v1_extraction_tasks__taskId__get_Type = {
  "200": HttpResponse<T_ApiResponseExtractionTaskDetailResponse>,
  errorResponse: ResultFailure<HttpResponse<Any>, UnexpectedError>,
  request: HttpRequestType<{| uri: {| taskId: Int64 |}, query: Object, headers: Object, cookie: Object |}>,
  response: O_api_v1_extraction_tasks__taskId__get_Type."200"
}

@OperationElement()
var O_api_v1_extraction_tasks__taskId__get = {
  name: "getTaskById",
  displayName: "getTaskById",
  executor: (parameter: O_api_v1_extraction_tasks__taskId__get_Type.request, connection: HttpConnection): Result<O_api_v1_extraction_tasks__taskId__get_Type.response, O_api_v1_extraction_tasks__taskId__get_Type.errorResponse> -> do {
      var uri = serializeUriParams(parameter.uri, {})
      var query = parameter.query default {} withSerializationConfig {}
      var headers = serializeHeaders(parameter.headers default {}, {})
      var cookie = serializeCookies(parameter.cookie default {}, {})
      var response = connection({
        method: "GET",
        path: "/api/v1/extraction-tasks/$(uri.taskId)",
        queryParams: query,
        headers: headers,
        cookie: cookie,
        (body: parameter.body) if (parameter.body?)
      })
      var statusCode = response.status as String
      ---
      if (response.status == 200 and response is O_api_v1_extraction_tasks__taskId__get_Type."200")
        success(response)
      else
        unexpectedFailure(response, {
          kind: statusCode,
          categories: []
        })
    }
}

