%dw 2.8

import bearer_jwt, oauth2, test from com::mulesoft::connectivity::dockia::connections::Connections

import flow_O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::flow::operations::O_api_v1_auth_me_get

import flow_O_api_v1_extract_upload_post from com::mulesoft::connectivity::dockia::flow::operations::O_api_v1_extract_upload_post

import flow_O_api_v1_extraction_tasks__taskId__get from com::mulesoft::connectivity::dockia::flow::operations::O_api_v1_extraction_tasks__taskId__get

import flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get from com::mulesoft::connectivity::dockia::flow::operations::O_api_v1_oauth2__well_known_oauth_authorization_server_get

import FlowConnectorElement from com::mulesoft::connectivity::flow::Metadata

@FlowConnectorElement()
var connector = {
  name: "dockia",
  displayName: "dockia",
  version: "0.0.1-SNAPSHOT",
  since: "R258",
  description: "dockia",
  icons: [
    {
      name: "dockia",
      alternateText: "dockia",
      resource: "icon/icon.svg",
      size: 1,
      dimensions: "0x0"
    }
  ],
  vendor: "auto-generated",
  connections: {
    bearer_jwt: bearer_jwt,
    oauth2: oauth2
  },
  testConnection: test,
  operations: {
    discoveryMetadata: flow_O_api_v1_oauth2__well_known_oauth_authorization_server_get,
    getCurrentUser: flow_O_api_v1_auth_me_get,
    getTaskById: flow_O_api_v1_extraction_tasks__taskId__get
  },
  valueProviders: {},
  metadataProviders: {}
}

