%dw 2.8

import anypoint_O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_auth_me_get

import anypoint_O_api_v1_extract_upload_post from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_extract_upload_post

import anypoint_O_api_v1_extraction_tasks__taskId__get from com::mulesoft::connectivity::dockia::anypoint::operations::O_api_v1_extraction_tasks__taskId__get

import oauth2, test from com::mulesoft::connectivity::dockia::connections::Connections

import MuleConnectorElement from com::mulesoft::connectivity::mule::Metadata

@MuleConnectorElement()
var connector = {
  name: "dockia",
  displayName: "dockia",
  version: "0.0.1-SNAPSHOT",
  releaseStatus: "PILOT",
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
  category: "SELECT",
  connections: {
    oauth2: oauth2
  },
  testConnection: test,
  operations: {
    getUserInfo: anypoint_O_api_v1_auth_me_get,
    processDocument: anypoint_O_api_v1_extract_upload_post,
    getDocument: anypoint_O_api_v1_extraction_tasks__taskId__get
  },
  valueProviders: {},
  metadataProviders: {}
}

