############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("datamodule")
#endregion

############################################################
import dayjs from "dayjs"

############################################################
import * as utl from "./datautils.js"
import * as S from "./statemodule.js"

############################################################
import { requestSharesURL, dataLoadPageSize } from "./configmodule.js"
# import { ownSampleData } from "./sampledata.js"

############################################################
minDate = null
minDateFormatted  = null
patientAuth = null

############################################################
allDataPromise = null
patientDataPromise = null

############################################################
dataToShare = null

############################################################
retrieveData = ->
    log "retrieveData"
    try
        pageSize = dataLoadPageSize
        page = 1
        
        receivedCount = 0
        allData = []

        loop
            requestData = {page, pageSize}
            log "requesting -> "
            olog requestData

            rawData = await utl.postRequest(requestSharesURL, requestData)
            allData.push(rawData.shareSummary)
            # receivedCount = allData.length  
            receivedCount += rawData.currentSharesCount
            if receivedCount == rawData.totalSharesCount then break
            if receivedCount <  pageSize then break
            page++
        
        return utl.groupAndSort(allData)

    catch err
        log err
        # return utl.groupAndSort(ownSampleData)
        return []

        
############################################################
export getAllData = ->
    if !allDataPromise? then allDataPromise = retrieveData()
    return allDataPromise
