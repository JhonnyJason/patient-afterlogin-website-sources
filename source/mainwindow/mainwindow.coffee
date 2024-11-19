# import Modules from "./allmodules"
# import domconnect from "./mainwindowdomconnect"
# domconnect.initialize()

Modules = {}

global.allModules = Modules
window.name = "SusDoxMain"

############################################################
#region open/focus table
windowProxy = null

openTableWindowClicked = ->
    url = "index.html"
    target = "SusDoxTable" # "_self" "_blank" "_parent" "_top"
    # windowFeatures = "popup"
    windowFeatures = ""
    
    if windowProxy? and !windowProxy.closed then windowProxy.focus()
    else windowProxy = window.open(url, target, windowFeatures)
    return

onMessage = (evnt)->
    if evnt.source == windowProxy 
        # console.log("We got the right source!")
        console.log("received Message: "+evnt.data)
        # window.focus()

    else console.log("The source was not the right ProxyWindow Object!")
    return
#endregion

############################################################
appStartup = ->
    #for demologin and whole connection testing
    button = document.getElementById("open-table-window")
    button.addEventListener("click", openTableWindowClicked)
    
    addEventListener("message", onMessage)
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()