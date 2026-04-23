%dw 2.8

import OperationElement from com::mulesoft::connectivity::Metadata

import alwaysMapsTo, extractRequestBody, fromMapping, mapsTo, withTransformer from com::mulesoft::connectivity::codegen::Transformation

import Label from com::mulesoft::connectivity::decorator::Annotations

import O_api_v1_extract_upload_post, O_api_v1_extract_upload_post_Type from com::mulesoft::connectivity::dockia::operations::O_api_v1_extract_upload_post

type anypoint_O_api_v1_extract_upload_post_request = {
  source: O_api_v1_extract_upload_post_Type.request.query.source,
  subject?: O_api_v1_extract_upload_post_Type.request.query.subject,
  "upload-uid"?: O_api_v1_extract_upload_post_Type.request.query."upload-uid",
  reprocess?: O_api_v1_extract_upload_post_Type.request.query.reprocess,
  "uploadPdf--body"?: @Label(value = "File (PDF as Base64 String)")
  String
}

var anypoint_O_api_v1_extract_upload_post_mapping = [
  "source" mapsTo "query.source",
  "subject" mapsTo "query.subject",
  "upload-uid" mapsTo "query.upload-uid",
  "reprocess" mapsTo "query.reprocess",
  {} alwaysMapsTo "headers",
  {} alwaysMapsTo "cookie",
  "uploadPdf--body" mapsTo "body.file"
]

@OperationElement()
var anypoint_O_api_v1_extract_upload_post = O_api_v1_extract_upload_post withTransformer {
  in: fromMapping<anypoint_O_api_v1_extract_upload_post_request, O_api_v1_extract_upload_post_Type.request>(anypoint_O_api_v1_extract_upload_post_mapping),
  out: extractRequestBody
}

