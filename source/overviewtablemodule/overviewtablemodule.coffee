############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("overviewtablemodule")
#endregion

############################################################
import { Grid, html} from "gridjs"
import dayjs from "dayjs"
# import { de } from "dayjs/locales"

############################################################
import { retrieveData } from "./datamodule.js"

############################################################
import * as S from "./statemodule.js"
import * as utl from "./tableutils.js"
import * as loadcontrols from "./loadcontrolsmodule.js"
import * as dataModule from "./datamodule.js"
import {tableRenderCycleMS} from "./configmodule.js"

############################################################
tableObj = null
currentTableHeight = 0
############################################################
updateLater = null
navigatingBack = false

############################################################
patientId = null

############################################################
gridJSSearch = null
rootStyle = null

############################################################
export initialize = ->
    log "initialize"
    window.addEventListener("resize", updateTableHeight)
    window.gridSearchByString = gridSearchByString
    window.selectPatient = selectPatient
    rootObj = document.querySelector(':root')
    rootStyle = rootObj.style
    return

############################################################
renderTable = (dataPromise) ->
    log "renderTable"
    
    columns = utl.getStandardColumnObjects()
    data = -> dataPromise
    language = utl.getLanguageObject()
    search = true

    pagination = { limit: 50 }
    # sort = { multiColumn: false }
    sort = false
    fixedHeader = true
    resizable = false
    # resizable = true
    height = "#{utl.getTableHeight()}px"
    rootStyle.setProperty("--table-max-height", height)
    width = "100%"
    
    autoWidth = false
    
    # gridJSOptions = { columns, data, language, search, pagination, sort, fixedHeader, resizable, height, width, autoWidth }
    ## Try without defining the height
    gridJSOptions = { columns, data, language, search, pagination, sort, fixedHeader, resizable,
    #  height, 
    #  width, 
    #  autoWidth 
     }
    
    if tableObj?
        tableObj = null
        gridjsFrame.innerHTML = ""  
        tableObj = new Grid(gridJSOptions)
        await tableObj.render(gridjsFrame).forceRender()
        # render alone does not work here - it seems the Old State still remains in the GridJS singleton thus a render here does not refresh the table at all
    else
        tableObj = new Grid(gridJSOptions)
        gridjsFrame.innerHTML = ""    
        await tableObj.render(gridjsFrame)
    
    return

############################################################
renderPatientTable = (dataPromise) ->
    log "renderPatientTable"
    
    columns = utl.getPatientsColumnObjects()
    data = -> dataPromise
    language = utl.getLanguageObject()
    search = true

    pagination = { limit: 50 }
    # sort = { multiColumn: false }
    sort = false
    fixedHeader = true
    resizable = false
    # resizable = true
    height = "#{utl.getTableHeight()}px"
    rootStyle.setProperty("--table-max-height", height)

    width = "100%"
    
    autoWidth = false
    
    # gridJSOptions = { columns, data, language, search, pagination, sort, fixedHeader, resizable, height, width, autoWidth }
    ## Try without defining the height
    gridJSOptions = { columns, data, language, search, pagination, sort, fixedHeader, resizable,
    #  height, 
    #  width, 
    #  autoWidth 
     }
    
    if tableObj?
        tableObj = null
        gridjsFrame.innerHTML = ""  
        tableObj = new Grid(gridJSOptions)
        await tableObj.render(gridjsFrame).forceRender()
        # render alone does not work here - it seems the Old State still remains in the GridJS singleton thus a render here does not refresh the table at all
    else
        tableObj = new Grid(gridJSOptions)
        gridjsFrame.innerHTML = ""    
        await tableObj.render(gridjsFrame)
    
    gridJSSearch = document.getElementsByClassName("gridjs-search")[0]
    gridJSSearch.addEventListener("animationend", searchPositionMoved)
    return

############################################################
updateTableHeight = (height) ->
    log "updateTableHeight"
    olog { height }

    if typeof height != "number" then height = utl.getTableHeight()
    if currentTableHeight == height then return
    currentTableHeight = height 
    height = height+"px"
    rootStyle.setProperty("--table-max-height", height)

    # #preserve input value if we have
    # searchInput = document.getElementsByClassName("gridjs-search-input")[0]
    # if searchInput? 
    #     searchValue = searchInput.value
    #     log searchValue    
    #     focusRange = getSearchFocusRange()
    #     search =
    #         enabled: true
    #         keyword: searchValue
    # else search = false
    
    # # await updateTable({height, search})
    # if focusRange? then setFocusRange(focusRange)
    return

############################################################
updateTable = (config) ->
    log "updateTable"
    olog {rendering, updateLater}
    if rendering  
        updateLater = () -> updateTable(config)
        return

    rendering = true
    try await tableObj.updateConfig(config).forceRender()
    catch err then log err
    rendering = false
    
    if updateLater?
        log "updateLater existed!"
        updateNow = updateLater
        updateLater = null
        updateNow()
    log "update done!"
    return

############################################################
getSearchFocusRange = ->
    searchInput = document.getElementsByClassName("gridjs-search-input")[0]
    return null unless searchInput? and searchInput == document.activeElement
    start = searchInput.selectionStart
    end = searchInput.selectionEnd
    return {start, end}

setFocusRange = (range) ->
    { start, end } = range
    searchInput = document.getElementsByClassName("gridjs-search-input")[0]
    return unless searchInput?
    searchInput.setSelectionRange(start, end)
    searchInput.focus()
    return


############################################################
searchPositionMoved = ->
    log "searchPositionMoved"
    if navigatingBack 
        navigatingBack = false
        setDefaultState()
    return


############################################################
gridSearchByString = (name) ->
    log "gridSearchByString #{name}"
    search = {keyword: name}
    updateTable({search})
    return

selectPatient = (selectedPatientId, selectedPatientName, selectedDateOfBirth) ->
    log "selectPatient #{selectedPatientId},#{selectedPatientName},#{selectedDateOfBirth}"
    patientId = selectedPatientId
    patientString = "#{selectedPatientName}, #{selectedDateOfBirth}"
    loadcontrols.setPatientString(patientString)
    setPatientSelectedState()
    return
    

############################################################
export refresh = ->
    log "refresh"
    setDefaultState()
    return 

export backFromPatientTable = ->
    log "backFromPatientTable"
    dataModule.invalidatePatientData()
    navigatingBack = true
    overviewtable.classList.add("go-back")
    return
############################################################
#region set to state Functions
export setDefaultState = ->
    log "setDefaultState"
    overviewtable.classList.remove("patient-table")
    overviewtable.classList.remove("go-back")

    dataPromise = dataModule.getAllData()
    # this is when we want to destroy the table completely
    renderTable(dataPromise) # we always want to do that :-)
    return

export setPatientSelectedState = ->
    log "setPatientSelectedState"
    overviewtable.classList.add("patient-table")

    dataPromise = dataModule.getDataForPatientId(patientId)
    renderPatientTable(dataPromise)
    return

#endregion