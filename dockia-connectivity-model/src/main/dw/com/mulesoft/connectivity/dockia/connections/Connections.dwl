%dw 2.8

import ConnectionElement, TestConnectionElement from com::mulesoft::connectivity::Metadata

import defineTestConnection from com::mulesoft::connectivity::Model

import mapInputOperation from com::mulesoft::connectivity::decorator::Operation

import O_api_v1_oauth2__well_known_oauth_authorization_server_get from com::mulesoft::connectivity::dockia::operations::O_api_v1_oauth2__well_known_oauth_authorization_server_get

import BearerAuthSchema, OAuth2AuthSchema, defineBearerHttpConnectionProvider, defineOAuth2Connection from com::mulesoft::connectivity::transport::Http

@TestConnectionElement()
var test = {
  validate: defineTestConnection(mapInputOperation(O_api_v1_oauth2__well_known_oauth_authorization_server_get, (param: {}) -> {
    query: {},
    headers: {},
    cookie: {}
  }), (response) -> {
    isValid: response.value.status == 200,
    message: 
      if (response.success is true)
        "Connection test succeeded"
      else if (response.error.value.status?)
        "Connection test failed - Http status code: " ++ response.error.value.status as String
      else
        "Connection test failed",
    (error: 
      if (isEmpty(response.error.value.body.^raw))
        write(response.error.value.body, "application/dw") as String
      else
        response.error.value.body.^raw as String) if (response.success is false and response.error.value.body?)
  })
}

@ConnectionElement()
var bearer_jwt = defineBearerHttpConnectionProvider<BearerAuthSchema & { baseUri: String }>((schema) -> {
  token: schema.token
}, (schema) -> {
  baseUri: schema.baseUri
})

@ConnectionElement()
var oauth2 = defineOAuth2Connection<OAuth2AuthSchema & { baseUri: String }>((schema) -> {
  accessToken: schema.accessToken
}, (schema) -> {
  baseUri: schema.baseUri
}, {
  grantType: "password",
  tokenUrl: "/api/v1/oauth2/token",
  scopes: []
})

