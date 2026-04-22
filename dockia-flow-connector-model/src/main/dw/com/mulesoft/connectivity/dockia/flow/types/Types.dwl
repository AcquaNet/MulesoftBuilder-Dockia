%dw 2.8

import Int64, LWDateTime from com::mulesoft::connectivity::Types

type T_uploadPdfResponse = {
  success?: Boolean,
  error?: String,
  correlationId?: String,
  timestamp?: LWDateTime,
  duration?: Int64
}

