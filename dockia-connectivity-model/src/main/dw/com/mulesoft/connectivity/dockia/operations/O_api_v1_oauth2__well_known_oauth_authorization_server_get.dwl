%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import Result, ResultFailure, UnexpectedError, success, unexpectedFailure from com::mulesoft::connectivity::Model

import HttpConnection, HttpRequestType, HttpResponse from com::mulesoft::connectivity::transport::Http

import serializeCookies, serializeHeaders, withSerializationConfig from com::mulesoft::connectivity::transport::Serialization

type O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type = {
  "200": HttpResponse<{ _?: Object }>,
  errorResponse: ResultFailure<HttpResponse<Any>, UnexpectedError>,
  request: HttpRequestType<{| query: Object, headers: Object, cookie: Object |}>,
  response: O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type."200"
}

@OperationElement()
var O_api_v1_oauth2__well_known_oauth_authorization_server_get = {
  name: "discoveryMetadata",
  displayName: "discoveryMetadata",
  executor: (parameter: O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type.request, connection: HttpConnection): Result<O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type.response, O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type.errorResponse> -> do {
      var query = parameter.query default {} withSerializationConfig {}
      var headers = serializeHeaders(parameter.headers default {}, {})
      var cookie = serializeCookies(parameter.cookie default {}, {})
      var response = connection({
        method: "GET",
        path: "/api/v1/oauth2/.well-known/oauth-authorization-server",
        queryParams: query,
        headers: headers,
        cookie: cookie,
        (body: parameter.body) if (parameter.body?)
      })
      var statusCode = response.status as String
      ---
      if (response.status == 200 and response is O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type."200")
        success(response)
      else
        unexpectedFailure(response, {
          kind: statusCode,
          categories: []
        })
    }
}

