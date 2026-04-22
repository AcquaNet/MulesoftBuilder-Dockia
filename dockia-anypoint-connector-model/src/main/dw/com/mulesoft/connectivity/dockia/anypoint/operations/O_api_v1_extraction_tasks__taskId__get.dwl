%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import alwaysMapsTo, extractRequestBody, fromMapping, mapsTo, withTransformer from com::mulesoft::connectivity::codegen::Transformation

import O_api_v1_extraction_tasks__taskId__get, O_api_v1_extraction_tasks__taskId__get_Type from com::mulesoft::connectivity::dockia::operations::O_api_v1_extraction_tasks__taskId__get

type anypoint_O_api_v1_extraction_tasks__taskId__get_request = {
  taskId: O_api_v1_extraction_tasks__taskId__get_Type.request.uri.taskId
}

var anypoint_O_api_v1_extraction_tasks__taskId__get_mapping = [
  "taskId" mapsTo "uri.taskId",
  {} alwaysMapsTo "query",
  {} alwaysMapsTo "headers",
  {} alwaysMapsTo "cookie"
]

@OperationElement()
var anypoint_O_api_v1_extraction_tasks__taskId__get = O_api_v1_extraction_tasks__taskId__get withTransformer {
  in: fromMapping<anypoint_O_api_v1_extraction_tasks__taskId__get_request, O_api_v1_extraction_tasks__taskId__get_Type.request>(anypoint_O_api_v1_extraction_tasks__taskId__get_mapping),
  out: extractRequestBody
}

