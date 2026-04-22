%dw 2.8

import ConnectionElement, TestConnectionElement from com::mulesoft::connectivity::Metadata

import defineTestConnection from com::mulesoft::connectivity::Model

import mapInputOperation from com::mulesoft::connectivity::decorator::Operation

import O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::operations::O_api_v1_auth_me_get

import doRequest, HttpRequester from com::mulesoft::connectivity::transport::Http

import SemanticTerms, Label from com::mulesoft::connectivity::decorator::Annotations

/**
 * Connection config for Dockia ROPC (Resource Owner Password Credentials) flow.
 *
 * Three user-facing fields:
 *   - baseUri:   Base URL of the Dockia API (e.g. https://dockia-api.dock-ia.com)
 *   - username:  Dockia user email — determines the user's role and permissions
 *   - password:  Dockia user password
 *
 * client_id ("atina-backend") and client_secret are fixed Keycloak application
 * credentials for this Dockia deployment and are hardcoded in the connect function.
 *
 * authenticationType "basic" causes the Mule runtime to use BasicConnectivityConnectionProvider,
 * which passes exactly {baseUri, username, password} to the DataWeave connect function.
 * The connect function performs the ROPC token exchange transparently on every API call.
 */
type DockiaConnectionConfig = {
  baseUri:  @Label(value = "Base URI") String,
  username: @SemanticTerms(value = ["username"]) @Label(value = "Username") String,
  password: @SemanticTerms(value = ["password"]) @Label(value = "Password") String
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
 * ROPC (Resource Owner Password Credentials) connection for Dockia.
 *
 * How it works:
 *   1. The Mule runtime uses BasicConnectivityConnectionProvider (authenticationType: "basic"),
 *      which passes {baseUri, username, password} to this DataWeave connect function.
 *   2. For every API operation the connect function calls the Dockia token endpoint:
 *        POST /api/v1/oauth2/token
 *        Content-Type: application/x-www-form-urlencoded
 *        grant_type=password & client_id=atina-backend & client_secret=... & username=... & password=...
 *   3. The obtained access_token is injected as "Authorization: Bearer <token>" into the request.
 *
 * Each Mule user/session can configure different username/password credentials, so each user
 * gets their own token with the correct role-based permissions from Keycloak.
 *
 * Token-per-call overhead is acceptable for connector use cases where connection pools are small.
 * If needed, token caching can be added at the Mule flow level using an Object Store.
 */
@ConnectionElement()
var oauth2 = {
  connect: (schema: DockiaConnectionConfig) ->
    (httpRequest: HttpRequester) -> do {
      var logAcquire = log("[Dockia] Acquiring ROPC token", {username: schema.username, path: httpRequest.path})
      var tokenResp = doRequest({
        method: "POST",
        baseUri: schema.baseUri,
        path: "/api/v1/oauth2/token",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          grant_type: "password",
          client_id: "atina-backend",
          client_secret: "backend-secret-change-me",
          username: schema.username,
          password: schema.password
        },
        config: {contentType: "application/x-www-form-urlencoded"}
      })
      var logExecuteResponse = log("[Dockia] Response from token endpoint", {
        path: httpRequest.path,
        tokenStatus: tokenResp.body
      })
      var accessToken = tokenResp.body.access_token as String
      var logExecute = log("[Dockia] Token acquired, executing API request", {
        path: httpRequest.path,
        tokenStatus: tokenResp.status
      })
      ---
      doRequest(
        httpRequest
          update { case .baseUri! -> schema.baseUri }
          update { case .headers.Authorization! -> "Bearer $(accessToken)" }
      )
    },
  authenticationType: {"type": "basic"}
}
