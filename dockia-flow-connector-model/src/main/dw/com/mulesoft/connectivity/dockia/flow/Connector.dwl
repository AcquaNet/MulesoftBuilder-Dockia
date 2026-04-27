%dw 2.8

import oauth2, test from com::mulesoft::connectivity::dockia::connections::Connections

import flow_O_api_v1_auth_me_get from com::mulesoft::connectivity::dockia::flow::operations::O_api_v1_auth_me_get

import flow_O_api_v1_extraction_tasks__taskId__get from com::mulesoft::connectivity::dockia::flow::operations::O_api_v1_extraction_tasks__taskId__get

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
    oauth2: oauth2
  },
  testConnection: test,
  operations: {
    getUserInfo: flow_O_api_v1_auth_me_get,
    getDocument: flow_O_api_v1_extraction_tasks__taskId__get
  },
  valueProviders: {},
  metadataProviders: {}
}

