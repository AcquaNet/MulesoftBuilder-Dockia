%dw 2.8

import Int32, Int64, LWDateTime from com::mulesoft::connectivity::Types

type T_ApiResponseMapStringObject = {
  success?: Boolean,
  data?: {
    _?: Object
  },
  error?: String,
  correlationId?: String,
  timestamp?: LWDateTime,
  duration?: Int64
}

type T_ProcessDocumentData = {
  uid?: String,
  message?: String,
  task_id?: Int64
}

type T_ProcessDocumentResponse = {
  success?: Boolean,
  data?: T_ProcessDocumentData,
  error?: String,
  correlationId?: String,
  timestamp?: String,
  duration?: Int64
}

type T_ApiResponseExtractionTaskDetailResponse = {
  success?: Boolean,
  data?: T_ExtractionTaskDetailResponse,
  error?: String,
  correlationId?: String,
  timestamp?: LWDateTime,
  duration?: Int64
}

type T_ApiResponseLoginResponse = {
  success?: Boolean,
  data?: T_LoginResponse,
  error?: String,
  correlationId?: String,
  timestamp?: LWDateTime,
  duration?: Int64
}

type T_ExtractionTaskDetailResponse = {
  id?: Int64,
  correlationId?: String,
  source?: String,
  status?: String,
  priority?: Int32,
  attempts?: Int32,
  maxAttempts?: Int32,
  errorMessage?: String,
  referencia?: String,
  pdfPath?: String,
  resultPath?: String,
  rawResult?: String,
  manuallyEdited?: Boolean,
  promptTokens?: Int64,
  completionTokens?: Int64,
  totalTokens?: Int64,
  llmProvider?: String,
  llmModel?: String,
  createdAt?: LWDateTime,
  startedAt?: LWDateTime,
  completedAt?: LWDateTime,
  nextRetryAt?: LWDateTime,
  statusHistory?: Array<T_ExtractionTaskStatusHistoryResponse>,
  webhookEvent?: T_WebhookEventDetailResponse
}

type T_LoginResponse = {
  token?: String,
  expiresAt?: LWDateTime,
  username?: String,
  fullName?: String,
  email?: String,
  role?: String,
  tenant?: T_TenantInfo
}

type T_ExtractionTaskStatusHistoryResponse = {
  fromStatus?: String,
  toStatus?: String,
  correlationId?: String,
  source?: String,
  errorMessage?: String,
  rawResult?: String,
  promptTokens?: Int64,
  completionTokens?: Int64,
  llmProvider?: String,
  llmModel?: String,
  createdAt?: LWDateTime
}

type T_WebhookEventDetailResponse = {
  id?: Int64,
  correlationId?: String,
  eventType?: String,
  entityType?: String,
  entityId?: Int64,
  status?: String,
  attempts?: Int32,
  maxAttempts?: Int32,
  lastError?: String,
  payload?: String,
  createdAt?: LWDateTime,
  lastAttemptAt?: LWDateTime,
  nextRetryAt?: LWDateTime,
  sentAt?: LWDateTime,
  attemptHistory?: Array<T_WebhookEventAttemptHistoryResponse>,
  callbackResponse?: T_WebhookCallbackResponseData
}

type T_TenantInfo = {
  id?: Int64,
  code?: String,
  name?: String,
  subscriptionTier?: String,
  maxApiCallsPerMonth?: Int64,
  enabled?: Boolean
}

type T_WebhookEventAttemptHistoryResponse = {
  attemptNumber?: Int32,
  correlationId?: String,
  fromStatus?: String,
  toStatus?: String,
  httpStatusCode?: Int32,
  errorMessage?: String,
  durationMs?: Int64,
  createdAt?: LWDateTime
}

type T_WebhookCallbackResponseData = {
  status?: String,
  reference?: String,
  message?: String,
  receivedAt?: LWDateTime
}

