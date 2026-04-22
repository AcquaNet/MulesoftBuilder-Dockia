%dw 2.8

import ConnectionElement from com::mulesoft::connectivity::Metadata

import defineOAuth2Connection from com::mulesoft::connectivity::transport::Http

import DockiaConnectionConfig from com::mulesoft::connectivity::dockia::connections::Connections

/**
 * OAuth2 connection for Anypoint Studio (connectivity-mule-maven-plugin compatibility).
 *
 * The connectivity-mule-maven-plugin uses connectivity-mule-persistence whose GrantType
 * Java enum only accepts "authorizationCode" and "clientCredentials" — there is no
 * configuration option to enable "password".  This file declares "clientCredentials"
 * so the static Mule extension model generation succeeds and Anypoint Studio can display
 * the connector with the correct UI fields.
 *
 * The actual ROPC token exchange is performed by the FLOW connector at runtime
 * (dockia-flow-connector-model uses Connections.dwl with grantType: "password").
 * Configuration values (username, password, …) entered in Studio are stored in the
 * Mule application config and passed through to the flow connector at deploy time.
 *
 * inDance body extensions inject the ROPC parameters into the Studio test-connection
 * token request so that even the Anypoint connector validates correctly against the
 * Dockia token endpoint.
 */
@ConnectionElement()
var oauth2 = defineOAuth2Connection<DockiaConnectionConfig>((schema) -> {
  accessToken: schema.accessToken
}, (schema) -> {
  baseUri: schema.baseUri
}, {
  grantType: "clientCredentials",
  placement: "body",
  tokenUrl: "/api/v1/oauth2/token",
  scopes: []
},
(schema) -> [
  { inDance: true, in: "body", name: "grant_type", value: "password"      },
  { inDance: true, in: "body", name: "username",   value: schema.username },
  { inDance: true, in: "body", name: "password",   value: schema.password }
])
