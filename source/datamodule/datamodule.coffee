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
import { requestSharesURL } from "./configmodule.js"
import { ownSampleData, patientSampleData, doctorsSampleData } from "./sampledata.js"

import { dataLoadPageSize } from "./configmodule.js"

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
retrieveData = (minDate, patientId) ->
    log "retrieveData #{minDate},#{patientId}"
    try
        pageSize = dataLoadPageSize
        page = 1
        
        receivedCount = 0
        allData = []

        loop
            requestData = {minDate, patientId, page, pageSize}
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
        return utl.groupAndSort(ownSampleData)


############################################################
export setMinDateDaysBack = (daysCount) ->
    log "setMinDateDaysBack #{daysCount}"
    dateObj = dayjs().subtract(daysCount, "day")
    minDate = dateObj.toJSON()
    minDateFormatted = dateObj.format("DD.MM.YYYY")

    allDataPromise = null
    return

export setMinDateMonthsBack = (monthsCount) ->
    log "setMinDateMonthsBack #{monthsCount}"
    dateObj = dayjs().subtract(monthsCount, "month")
    minDate = dateObj.toJSON()
    minDateFormatted = dateObj.format("DD.MM.YYYY")

    allDataPromise = null
    return

export setMinDateYearsBack = (yearsCount) ->
    log "setMinDateYearsBack #{yearsCount}"
    dateObj = dayjs().subtract(yearsCount, "year")
    minDate = dateObj.toJSON()
    minDateFormatted = dateObj.format("DD.MM.YYYY")

    allDataPromise = null
    return

############################################################
export getAllData = ->
    if !allDataPromise? then allDataPromise = retrieveData(minDate, undefined)
    return allDataPromise

export getDataForPatientId = (patientId) ->
    if !patientDataPromise? then patientDataPromise = retrieveData(undefined, patientId)
    return patientDataPromise

############################################################
export invalidatePatientData = ->
    patientDataPromise = null
    return

############################################################
export getMinDate = -> minDateFormatted