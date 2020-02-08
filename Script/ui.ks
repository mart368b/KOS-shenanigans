// Import the remote actions
import 0:/KOS-shenanigans/remote/invoce_remote.ks.

// Create a dropdown menu over all the files in the current directory
function createFileSelect {
    parameter ui.
    parameter on_change is {
        parameter item.
    }.
    parameter sub_directory is ".".

    local pop_up to ui:addpopupmenu().

    set pop_up:ONCHANGE to on_change.

    if not exists(sub_directory) {
        print("Failed to find sub directory").
    }else {
        
        local all_files to List().

        cd(sub_directory).
        list files in all_files.
        if not sub_directory = "." {
            cd("..").
        }

        for file in all_files {
            if file:EXTENSION = "ks" {
                pop_up:addOption(file:NAME).
            }
        }

    }
    return pop_up.
}

// Create the actual gui window
function createMainUi {
    local ui IS GUI(200).
    
    local selected to "".
    local pop_up to createFileSelect(ui, {
        parameter value.

        set selected to value.
    }).
    set selected to pop_up:value.

    local ok TO ui:ADDBUTTON("OK").
    ui:SHOW().
    local isDone is FALSE.
    function onClick {
        isDone ON.
    }

    set ok:ONCLICK to onClick@.
    until isDone. // Lock the thread until a response is given
    ui:HIDE().

    return selected.
}

remoteInvocation(
    "xml",
    "0:/out/xml.ks",
    List(
        "0:/ui/gui.xml"
    )
).

// Return the selected file 
//returnResult(
//    "ui",
//    List(
//        "Selected Item",
//        createMainUi():tostring()
//    )
//).