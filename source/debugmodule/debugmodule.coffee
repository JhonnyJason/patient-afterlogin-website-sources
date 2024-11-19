
import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = {
    configmodule: true
    datamodule: true
    datautils: true
    overviewtablemodule: true
    tableutils: true
}

addModulesToDebug(modulesToDebug)