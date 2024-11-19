
import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = {
    configmodule: true
    datamodule: true
    datautils: true
    loadcontrolsmodule: true
    modecontrolsmodule: true
    overviewtablemodule: true
    tableutils: true
    patientapprovalmodule: true
    userprocessmodule: true
}

addModulesToDebug(modulesToDebug)