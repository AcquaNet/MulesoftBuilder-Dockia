%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import alwaysMapsTo, extractRequestBody, fromMapping, withTransformer from com::mulesoft::connectivity::codegen::Transformation

import O_api_v1_oauth2__well_known_oauth_authorization_server_get, O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type from com::mulesoft::connectivity::dockia::operations::O_api_v1_oauth2__well_known_oauth_authorization_server_get

type flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get_request = Object

var flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get_mapping = [
  {} alwaysMapsTo "query",
  {} alwaysMapsTo "headers",
  {} alwaysMapsTo "cookie"
]

@OperationElement()
var flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get = O_api_v1_oauth2__well_known_oauth_authorization_server_get withTransformer {
  in: fromMapping<flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get_request, O_api_v1_oauth2__well_known_oauth_authorization_server_get_Type.request>(flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get_mapping),
  out: extractRequestBody
}

