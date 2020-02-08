// Import the remote actions
        // Clear the result associated with the specified namespace
        function clearResult {
            parameter name.
            local p to "0:/out/results/" + name + ".json".
            if not exists(p) {
                create(p).
            }
            open(p):clear().
        }
        
        // Get the result stored in the specified namespace
        function getResult {
            parameter name.
            local p to "0:/out/results/" + name + ".json".
            if open(p):size > 0 {
                return readJson(p).
            }
        }
        
        // Set the result stored in the specified namespace
        function returnResult {
            parameter name.
            parameter keyValues.
            local p to "0:/out/results/" + name + ".json".
            WRITEJSON(Lexicon(keyValues), p).
        }
        
        // Call another file as if it was a function
        // arguments are sent as a single list, 
        // and results are returned using the provided namespace
        function remoteInvocation {
            parameter name.
            parameter file.
            parameter args is List().
        
            clearResult(name).
            runPath(file, args).
            return getResult(name).
        }
        
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