%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import alwaysMapsTo, extractRequestBody, fromMapping, mapsTo, withTransformer from com::mulesoft::connectivity::codegen::Transformation

import Label from com::mulesoft::connectivity::decorator::Annotations

import O_api_v1_extract_upload_post, O_api_v1_extract_upload_post_Type from com::mulesoft::connectivity::dockia::operations::O_api_v1_extract_upload_post

import T_uploadPdfResponse from com::mulesoft::connectivity::dockia::flow::types::Types

type flow_O_api_v1_extract_upload_post_request = {
  source: O_api_v1_extract_upload_post_Type.request.query.source,
  subject?: O_api_v1_extract_upload_post_Type.request.query.subject,
  "upload-uid"?: O_api_v1_extract_upload_post_Type.request.query."upload-uid",
  reprocess?: O_api_v1_extract_upload_post_Type.request.query.reprocess,
  file?: @Label(value = "File (PDF as Base64 String)")
  String
}

var flow_O_api_v1_extract_upload_post_mapping = [
  "source" mapsTo "query.source",
  "subject" mapsTo "query.subject",
  "upload-uid" mapsTo "query.upload-uid",
  "reprocess" mapsTo "query.reprocess",
  {} alwaysMapsTo "headers",
  {} alwaysMapsTo "cookie",
  "file" mapsTo "body.file"
]

@OperationElement()
var flow_O_api_v1_extract_upload_post = withTransformer(O_api_v1_extract_upload_post, {
  in: fromMapping<flow_O_api_v1_extract_upload_post_request, O_api_v1_extract_upload_post_Type.request>(flow_O_api_v1_extract_upload_post_mapping),
  out: extractRequestBody<T_uploadPdfResponse>()
})

