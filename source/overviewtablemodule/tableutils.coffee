############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("tableutils")
#endregion

############################################################
import { Grid, html} from "gridjs"
# import { RowSelection } from "gridjs/plugins/selection"
# import { RowSelection } from "gridjs-selection"

import dayjs from "dayjs"
# import { de } from "dayjs/locales"

############################################################
PATIENTID_CELL = 0
ISNEW_CELL = 1
DOBSTANDARD_CELL = 4

############################################################
#region germanLanguage
deDE = {
    search: {
        placeholder: 'Suche...'
    }
    sort: {
        sortAsc: 'Spalte aufsteigend sortieren'
        sortDesc: 'Spalte absteigend sortieren'
    }
    pagination: {
        previous: 'Vorherige'
        next: 'Nächste'
        navigate: (page, pages) -> "Seite #{page} von #{pages}"
        page: (page) -> "Seite #{page}"
        showing: ' '
        of: 'von'
        to: '-'
        results: 'Daten'
    }
    loading: 'Wird geladen...'
    noRecordsFound: 'Keine übereinstimmenden Aufzeichnungen gefunden'
    error: 'Beim Abrufen der Daten ist ein Fehler aufgetreten'
}

deDEPatientApproval = {
    search: {
        placeholder: 'Suche...'
    }
    sort: {
        sortAsc: 'Spalte aufsteigend sortieren'
        sortDesc: 'Spalte absteigend sortieren'
    }
    pagination: {
        previous: 'Vorherige'
        next: 'Nächste'
        navigate: (page, pages) -> "Seite #{page} von #{pages}"
        page: (page) -> "Seite #{page}"
        showing: ' '
        of: 'von'
        to: '-'
        results: 'Daten'
    }
    loading: 'Wird geladen...'
    noRecordsFound: 'Geben Sie die Authentifizierungsdaten für den Patienten ein.'
    error: 'Beim Abrufen der Daten ist ein Fehler aufgetreten'
}
#endregion

############################################################
entryBaseURL = "https://www.bilder-befunde.at/webview/index.php?value_dfpk="
messageTarget = null

## datamodel default entry
# | Bilder Button | Befunde Button | Untersuchungsdatum | Patienten Name (Fullname) | SSN (4 digits) | Geb.Datum | Untersuchungsbezeichnung | Radiologie | Zeitstempel (Datum + Uhrzeit) |

## datamodel checkbox entry
# | checkbox | hidden index | Untersuchungsdatum | Patienten Name (Fullname) | SSN (4 digits) | Geb.Datum | Untersuchungsbezeichnung | Radiologie | Zeitstempel (Datum + Uhrzeit) |

## datamodel doctor selection entry
# | checkbox | doctorName | 

############################################################
#region internalFunctions

############################################################
# onLinkClick = (el) ->
#     evnt = window.event
#     # console.log("I got called!")
#     # console.log(evnt)
#     evnt.preventDefault()
#     ## TODO send right message
#     href = el.getAttribute("href")
#     ## TODO send right message
#     # window.open("mainwindow.html", messageTarget.name)
#     if messageTarget.closed then messageTarget = window.open("mainwindow.html", messageTarget.name)
#     else window.open("", messageTarget.name)
#     messageTarget.postMessage(href)
#     # messageTarget.focus()
#     # window.blur()
#     return

############################################################
#region sort functions
dateCompare = (el1, el2) ->
    # date1 = dayjs(el1)
    # date2 = dayjs(el2)
    # return -date1.diff(date2)
    
    # here we already expect a dayjs object
    diff = el1.diff(el2)
    if diff > 0 then return 1
    if diff < 0 then return -1
    return 0

numberCompare = (el1, el2) ->
    number1 = parseInt(el1, 10)
    number2 = parseInt(el2, 10)

    if number1 > number2 then return 1
    if number2 > number1 then return -1
    return 0
    # log number1 - number2
    # return number1 - number2

#endregion

############################################################
#region cell formatter functions
isNewFormatter = (content, row) ->
    dotClass = "isNewDot"
    
    if content then dotClass = "isNewDot isNew" 

    innerHTML = "<div class='#{dotClass}'></div>"
    return  html(innerHTML)

bilderFormatter  = (content, row) ->
    return "" unless content?
    # log typeof content
    innerHTML = "<ul class='bilder'>"

    lines = content.split(" : ")
    for line in lines when line.length > 3
        params = line.split(" . ")
        if params.length != 3 then throw new Error("Error in Merged Bilder parameter! '#{content}'")
        # image = {
        #     description: params[0],
        #     url: params[1],
        #     isNew: params[2] == "1"
        # }

        if params[2] == "1"
            innerHTML += "<li><b><a href='#{params[1]}'> #{params[0]}</a></b></li>"
        else
            innerHTML += "<li><a href='#{params[1]}'> #{params[0]}</a></li>"    
        
    innerHTML += "</ul>"
    return html(innerHTML)

befundeFormatter = (content , row) ->
    return "" unless content?
    # log typeof content
    innerHTML = "<ul class='befunde'>"

    lines = content.split(" : ")
    for line in lines when line.length > 3
        params = line.split(" . ")
        if params.length != 3 then throw new Error("Error in Merged Bilder parameter! '#{content}'")
        # befund = {
        #     description: params[0],
        #     url: params[1],
        #     isNew: params[2] == "1"
        # }
        if params[2] == "1"
            innerHTML += "<li><b><a href='#{params[1]}'> #{params[0]}</a></b></li>"
        else
            innerHTML += "<li><a href='#{params[1]}'> #{params[0]}</a></li>"

    innerHTML += "</ul>"
    return html(innerHTML)

screeningDateFormatter = (content, row) ->
    return content.format("DD.MM.YYYY")

nameFormatter = (content, row) ->
    linkHTML = """
        <a onclick='selectPatient(#{row._cells[PATIENTID_CELL].data}, "#{content}", "#{row._cells[DOBSTANDARD_CELL].data}")'>#{content}</a>
    """
    if row._cells[ISNEW_CELL].data then return html("<b>#{linkHTML}</b>")
    else return html(linkHTML)

svnFormatter = (content, row) ->
    return content

birthdayFormatter = (content, row) ->
    return content
            
radiologistFormatter = (content, row) ->
    return content

sendingDateFormatter = (content, row) ->
    dateString = content.format("DD.MM.YYYY HH:mm")
    if row._cells[ISNEW_CELL].data then return html("<b>#{dateString}</b>")
    else return dateString 

#endregion

############################################################
#region exportedFunctions
export getTableHeight = ->
    log "getTableHeight"
    tableWrapper = document.getElementsByClassName("gridjs-wrapper")[0]
    gridJSFooter = document.getElementsByClassName("gridjs-footer")[0]
    
    fullHeight = window.innerHeight
    fullWidth = window.innerWidth
    
    outerPadding = 5

    # nonTableOffset = modecontrols.offsetHeight
    ## we removed the modecontrols
    nonTableOffset = 0
    if !tableWrapper? # table does not exist yet
        nonTableOffset += 114 # so take the height which should be enough
    else 
        nonTableOffset += tableWrapper.offsetTop
        nonTableOffset += gridJSFooter.offsetHeight
        nonTableOffset += outerPadding
        log nonTableOffset

    tableHeight = fullHeight - nonTableOffset
    # olog {tableHeight, fullHeight, nonTableOffset, approvalHeight}

    olog {tableHeight}
    return tableHeight

############################################################
#region Definition of columnHeadObjects
patientIdHeadObj = {
    name: ""
    id: "patientId"
    hidden: true
}

isNewHeadObj = {
    name: ""
    id: "isNew"
    formatter: isNewFormatter
    sort: false
}

bilderHeadObj = {
    name: "Bilder"
    id: "images"
    formatter: bilderFormatter
    sort: false
}

befundeHeadObj = {
    name: "Befunde"
    id: "befunde"
    formatter: befundeFormatter
    sort: false
}

screeningDateHeadObj = {
    name: "Unt.-Datum"
    id: "studyDate"
    formatter: screeningDateFormatter
    sort: false
}

nameHeadObj = {
    name: "Name"
    id: "patientFullName"
    formatter: nameFormatter
    sort: false
}

svnHeadObj = {
    name: "SVNR"
    id: "patientSsn"
    formatter: svnFormatter
    sort: false
}

birthdayHeadObj = {
    name: "Geb.-Datum"
    id: "patientDob"
    formatter: birthdayFormatter
    sort: false
}

radiologistHeadObj = {
    name: "Radiologie"
    id: "fromFullName"
    formatter: radiologistFormatter
    sort: false
}

sendingDateHeadObj = {
    name: "Zustellungsdatum"
    id: "createdAt"
    formatter: sendingDateFormatter
    sort: false
}

#endregion

export getPatientsColumnObjects = (state) ->
    return [patientIdHeadObj, isNewHeadObj, befundeHeadObj, bilderHeadObj, screeningDateHeadObj, radiologistHeadObj]

############################################################
export getLanguageObject = -> return deDE

# ############################################################
# export changeLinksToMessageSent = (target) ->
#     # console.log("I have a target opener!")
#     messageTarget = target
#     window.onLinkClick = onLinkClick
#     return

#endregion
