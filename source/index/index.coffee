import Modules from "./allmodules.js"
import { changeLinksToMessageSent } from "./tableutils.js"
import domconnect from "./indexdomconnect.js"
domconnect.initialize()

global.allModules = Modules
window.name = "SusDoxTable"

############################################################
appStartup = ->
    # if window.opener? then changeLinksToMessageSent(window.opener)
    Modules.overviewtablemodule.setDefaultState()
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()