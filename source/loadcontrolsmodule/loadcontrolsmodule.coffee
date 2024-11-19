############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("loadcontrolsmodule")
#endregion

############################################################
import * as table from "./overviewtablemodule.js"
import * as data from "./datamodule.js"
import * as S from "./statemodule.js"

############################################################
mindateDisplay = document.getElementById("mindate-display")
patientNameIndication = document.getElementById("patient-name-indication")

############################################################
export initialize = ->
    log "initialize"
    optionValue = S.load("minDateOptionValue")
    if optionValue? then switch optionValue
        when "1"
            chooseDateLimit.value = optionValue
            data.setMinDateDaysBack(30)
        when "2" 
            chooseDateLimit.value = optionValue
            data.setMinDateMonthsBack(3)
        when "3" 
            chooseDateLimit.value = optionValue
            data.setMinDateMonthsBack(6)
        when "4" 
            chooseDateLimit.value = optionValue
            data.setMinDateYearsBack(1)
        when "5" 
            chooseDateLimit.value = optionValue
            data.setMinDateYearsBack(2)
        else throw new Error("Error: optionValue was an unexpected value: #{optionValue}")
    else
        chooseDateLimit.value = "1"
        data.setMinDateDaysBack(30)

    minDate = data.getMinDate()
    log minDate
    mindateDisplay.textContent = data.getMinDate()

    refreshButton.addEventListener("click", refreshButtonClicked)
    chooseDateLimit.addEventListener("change", dateLimitChanged)
    backButton.addEventListener("click", backButtonClicked)
    return


############################################################
backButtonClicked = ->
    log "backButtonClicked"
    table.backFromPatientTable()
    return

############################################################
refreshButtonClicked = ->
    # "refreshButtonClicked"
    dateLimitChanged()
    return

dateLimitChanged = ->
    # log "dateLimitChanged"
    # log chooseDateLimit.value
    S.save("minDateOptionValue", chooseDateLimit.value)
    switch chooseDateLimit.value
        when "1" then data.setMinDateDaysBack(30)
        when "2" then data.setMinDateMonthsBack(3)
        when "3" then data.setMinDateMonthsBack(6)
        when "4" then data.setMinDateYearsBack(1)
        when "5" then data.setMinDateYearsBack(2)
        else log "unknown value: "+chooseDateLimit.value
    mindateDisplay.textContent = data.getMinDate()
    table.refresh()
    return

############################################################
export setPatientString = (patientString) ->
    patientNameIndication.textContent = patientString
    return
