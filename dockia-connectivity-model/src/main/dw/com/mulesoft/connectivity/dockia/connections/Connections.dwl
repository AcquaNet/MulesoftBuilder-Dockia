%dw 2.8

import ConnectionElement, TestConnectionElement from com::mulesoft::connectivity::Metadata

import defineTestConnection from com::mulesoft::connectivity::Model

import mapInputOperation from com::mulesoft::connectivity::decorator::Operation

import O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::operations::O_api_v1_auth_me_get

import defineOAuth2Connection from com::mulesoft::connectivity::transport::Http

import SemanticTerms, Label from com::mulesoft::connectivity::decorator::Annotations

/**
 * Flat connection config for Dockia OAuth2 Resource Owner Password Credentials (ROPC) flow.
 * Declared as a concrete ObjectType (intersection types are not supported by the flow plugin).
 * Includes accessToken (internally used by the Mule runtime to store the obtained token)
 * plus the ROPC-specific fields required by the Dockia token endpoint.
 *
 * Token endpoint: POST /api/v1/oauth2/token
 * Form params: grant_type=password, client_id, client_secret, username, password
 */
type DockiaConnectionConfig = {
  accessToken: @SemanticTerms(value = ["password"])  String,
  baseUri:     @Label(value = "Base URI")            String,
  username:    @SemanticTerms(value = ["username"])  @Label(value = "Username") String,
  password:    @SemanticTerms(value = ["password"])  @Label(value = "Password") String
}

@TestConnectionElement()
var test = {
  validate: defineTestConnection(mapInputOperation(O_api_v1_auth_me_get, (param: {}) -> {
    query: {},
    headers: {},
    cookie: {}
  }), (response) -> do {
    var a_log = log("[Dockia] Test Connection - success: " ++ (response.success as String), {
      status:  response.value.status default response.error.value.status default "unknown",
      success: response.success
    })
    ---
    {
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
    }
  })
}

/**
 * OAuth2 connection using the native Resource Owner Password Credentials (ROPC) flow.
 * Used by the FLOW connector (dockia-flow-connector-model) which runs in the Mule runtime.
 * The connectivity-flow-maven-plugin does NOT validate grant types through
 * connectivity-mule-persistence, so "password" is accepted here without errors.
 *
 * The PasswordGrantType attributes only carry tokenUrl/grantType; the framework
 * does not automatically forward username and password to the token endpoint.
 * The inDance body extensions inject them explicitly so the Mule runtime sends:
 *   POST /api/v1/oauth2/token
 *   Content-Type: application/x-www-form-urlencoded
 *   Body: grant_type=password&client_id=...&client_secret=...&username=...&password=...
 */
@ConnectionElement()
var oauth2 = defineOAuth2Connection<DockiaConnectionConfig>((schema) -> {
  accessToken: schema.accessToken
}, (schema) -> {
  baseUri: schema.baseUri
}, {
  grantType: "password",
  tokenUrl: "/api/v1/oauth2/token",
  scopes: []
},
(schema) -> [
  { inDance: true, in: "body", name: "username", value: schema.username },
  { inDance: true, in: "body", name: "password", value: schema.password }
])
