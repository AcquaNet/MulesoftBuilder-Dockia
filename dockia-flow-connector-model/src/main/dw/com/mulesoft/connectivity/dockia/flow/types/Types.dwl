%dw 2.8

import Int64, LWDateTime from com::mulesoft::connectivity::Types

type T_uploadPdfResponse = {
  success?: Boolean,
  data?: {
    uid?: String,
    message?: String,
    task_id?: Number
  },
  error?: String,
  correlationId?: String,
  timestamp?: String,
  duration?: Number
}

