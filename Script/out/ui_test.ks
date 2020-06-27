// Get the library
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
        // Crash the application allowing for a error message to be displayed
        function crash {
            parameter msg.
            msg:tonumber().
        }
        
        // Get the next line from the global lines iterator
        function nextLine {
            parameter canEnd.
        
            local hasNext to lines:next. 
            if not hasNext and not canEnd {
                print("Unexpected EOF").
            }else {
                return lines:value.
            }
        }
        
        // parse all attributes from a string
        function parse_attributes {
            parameter line.
        
            local iter to line:split(" "):iterator.
        
            local attributes to Lexicon().
            until not iter:next() {
                // Split the attribute into key value pairs
                local part to iter:value:split("=").
                if part[0]:trim():length = 0 {
                    crash("Found zero size attribute key").
                }
                // Found key value pair
                if part:length = 2 {
                    local value to part[1].
        
                    // Do seperat parsing of strings
                    // This allows for strings to contain spaces
                    local start_quote to value:find("'").
                    local end_quote to value:findlast("'").
                    if start_quote <> -1 {
                        local current to "".
                        until end_quote or not iter:next() {
                            set current to iter:value.
                            set end_quote to current:findlast("'").
                            set value to value + " " + current.
                        }
                    }
        
                    // add the key and value to the list of attributes
                    attributes:add(part[0]:trim(), value).
                // Found just key
                }else {
                    if part[0]:trim():length <> 0 {
                        // add the key to the list of attributes
                        attributes:add(part[0], "").
                    }
                }
            }
            
            return attributes.
        }
        
        // Parse a single line
        function parse_line {
            parameter line.
            
            // Clean up line
            local trimmed to line:trim().
            
            // Determin if the line is a start or end tag
            local isEnd to trimmed[1] = "/".
            local isBlockEnd to trimmed[trimmed:length - 2] = "/".
        
            local start to 1.
            if isEnd {
                set start to start + 1.
            }
            local end to trimmed:length - 2.
            if isBlockEnd {
                set end to end - 1.
            }
        
            // Get the inner content of the line
            local inner_line to trimmed:substring(start, end).
            local tag_start to inner_line:find(" ").
            
            // Default values for a tag with no attributes
            local attributes to Lexicon().
            local tag to inner_line:trim().
        
            if tag_start <> -1 {
                // Extract the tag
                set tag to inner_line:substring(0, tag_start):trim().
        
                // Extract the attributes    
                local tag_length to end - tag_start.
                local attr_line to inner_line:substring(tag_start, tag_length):trim().
                set attributes to parse_attributes(attr_line).
            }
        
            // Return the resulting tag
            return Lexicon(
                "isEnd", isEnd,
                "tag", tag,
                "attributes", attributes,
                "isBlockEnd", isBlockEnd
            ).
        }
        
        // Parse the content of a file xml
        // The parser is made as a sax parser
        // When an element is encounterede onStartRootElement, onStartChildElement or onEndElement is called
        // The internal state can be changed by returning a new state in any of the given functions
        function parse_xml {
            parameter file.
            parameter state.
            parameter onStartRootElement. // (state, element) -> state
            parameter onStartChildElement. // (state, element) -> state
            parameter onEndElement. // (state, element) -> state
        
            local current_state to state.
            local file to open(file).
            local lines to file:readall():iterator().
            local xmlStack to Stack().
            // Parse all the lines in the file
            until not lines:next() {
                local line to lines:value.
                // Filter out empty lines
                if line:length <> 0 {
                    local element to parse_line(line).
                    // Validate the parsed element
                    if element:isEnd and element:isBlockEnd {
                        crash("Found double end element").
                    }
                    if element:tag:length = 0 {
                        crash("Found element without tag").
                    }
                    if xmlStack:length = 0 and element:isEnd {
                        crash("Tried to get parent from empty stack").
                    }
                    // Do xml stuff
                    if element:isEnd {
                        set current_state to onEndElement(current_state, element).
        
                        local parent to xmlStack:pop().
                        if not element:tag = parent:tag{
                            crash("End tag does not match start tag").
                        }
                    }else {
                        // Create the new element
                        if xmlStack:length <> 0 {
                            set current_state to onStartChildElement(current_state, element).
                        }else {
                            set current_state to onStartRootElement(current_state, element).
                        }
        
                        if not element:isBlockEnd {
                            xmlStack:push(element).
                        }
                    }
                }
            }
            if xmlStack:length() <> 0 {
                crash("Missing closing tags").
            }
            return current_state.
        }
        
        // Cast for scalar values
        function toScalar {
            parameter value.
            return value:toScalar().
        }
        
        // Cast for numbers values
        function toNumber {
            parameter value.
            return value:toScalar().
        }
        
        // Cast for string values
        function toString {
            parameter value.
            return value:substring(1, value:length - 2).
        }
        
        // Cast for boolean values
        function toBoolean {
            parameter value.
            return value:tolower() = "true".
        }
        
        // Cast for list values
        function toList {
            parameter value.
            local items to value:split(",").
            local l to List().
            for item in items {
                l:add(item:trim()).
            }
            return l.
        }
        
        // Cast allowing for any value to pass
        function accept {
            parameter value.
            return value.
        }
        
        // Set casting used by GUI element
        global guiCast to Lexicon(
            "gui", Lexicon(
                "width", toScalar@,
                "height", toScalar@,
                "x", toScalar@,
                "y", toScalar@,
                "draggable", toBoolean@,
                "extradelay", toScalar@,
                "show", accept@,
                "hide", accept@,
                "onradiochange", accept@
            )
        ).
        
        // Set casting for any child elements of the gui element
        global childCast to Lexicon(
            "label", Lexicon(
                "text", toString@,
                "image", toString@,
                "tooltip", toString@
            ),
            "button", Lexicon(
                "text", toString@,
                "onclick", accept@,
                "ontoggle", accept@
            ),
            "checkbox", Lexicon(
                "text", toString@,
                "on", toBoolean@,
                "onclick", accept@,
                "ontoggle", accept@
            ),
            "radiobutton", Lexicon(
                "text", toString@,
                "on", toBoolean@,
                "onclick", accept@,
                "ontoggle", accept@
            ),
            "textfield", Lexicon(
                "text", toString@,
                "onchange", accept@,
                "onconfirm", accept@,
                "tooltip", toString@
            ),
            "popupmenu", Lexicon(
                "options", toList@,
                "onchange", accept@,
                "maxvisible", toScalar@
            ),
            "hslide", Lexicon(
                "init", toScalar@,
                "min", toScalar@,
                "max", toScalar@,
                "onchange", accept@
            ),
            "vslide", Lexicon(
                "init", toScalar@,
                "min", toScalar@,
                "max", toScalar@,
                "onchange", accept@
            ),
            "hlayout", Lexicon(
                "onradiochange", accept@
            ),
            "vlayout", Lexicon(
                "onradiochange", accept@
            ),
            "hbox", Lexicon(
                "onradiochange", accept@
            ),
            "vbox", Lexicon(
                "onradiochange", accept@
            ),
            "stack", Lexicon(
                "onradiochange", accept@
            ),
            "scrollbox", Lexicon(
                "halways", toBoolean@,
                "valways", toBoolean@,
                "onradiochange", accept@
            ),
            "spacing", Lexicon(
                "amount", accept@
            )
        ).
        
        // Container for initialzing child values based on provided attributes
        global childInit to Lexicon(
            "label", {
                parameter parent, attr.
        
                global label to haskey(
                    "text",
                    attr,
                    {return parent:addLabel(attr:text).},
                    {crash("Label missing text attribute").}
                ).
                haskey("tooltip", attr, {set label:tooltip to attr:tooltip.}).
                haskey("image", attr, {set label:image to attr:image.}).
        
                return label.
            },
            "button", {
                parameter parent, attr.
        
                global button to haskey(
                    "text",
                    attr,
                    {return parent:addButton(attr:text).},
                    {crash("button missing text attribute").}
                ).
                haskey("onclick", attr, {set button:onclick to uiFunctions[attr:onclick]@.}).
                haskey("ontoggle", attr, {set button:ontoggle to uiFunctions[attr:ontoggle]@.}).
        
                return button.
            },
            "checkbox", {
                parameter parent, attr.
        
                global checkbox to haskey(
                    "text",
                    attr,
                    {return haskey(
                        "on",
                        attr,
                        {return parent:addCheckbox(attr:text, attr["on"]).},
                        {crash("checkbox missing on attribute").}
                    ).},
                    {crash("checkbox missing text attribute").}
                ).
                haskey("onclick", attr, {set checkbox:onclick to uiFunctions[attr:onclick]@.}).
                haskey("ontoggle", attr, {set checkbox:ontoggle to uiFunctions[attr:ontoggle]@.}).
        
                return checkbox.
            },
            "radiobutton", {
                parameter parent, attr.
        
                global radiobutton to haskey(
                    "text",
                    attr,
                    {return haskey(
                        "on",
                        attr,
                        {return parent:addRadiobutton(attr:text, attr["on"]).},
                        {crash("radiobutton missing on attribute").}
                    ).},
                    {crash("radiobutton missing text attribute").}
                ).
                haskey("onclick", attr, {set radiobutton:onclick to uiFunctions[attr:onclick]@.}).
                haskey("ontoggle", attr, {set radiobutton:ontoggle to uiFunctions[attr:ontoggle]@.}).
        
                return radiobutton.
            },
            "textfield", {
                parameter parent, attr.
        
                global textfield to haskey(
                    "text",
                    attr,
                    {return parent:addTextfield(attr:text).},
                    {crash("textfield missing text attribute").}
                ).
                haskey("onchange", attr, {set textfield:onchange to uiFunctions[attr:onchange]@.}).
                haskey("onconfirm", attr, {set textfield:onconfirm to uiFunctions[attr:onconfirm]@.}).
                haskey("tooltip", attr, {set textfield:tooltip to uiFunctions[attr:tooltip]@.}).
        
                return textfield.
            },
            "popupmenu", {
                parameter parent, attr.
        
                global popupmenu to parent:addPopupmenu().
        
                haskey("options", attr, {set textfield:options to attr:options.}).
                haskey("maxvisible", attr, {set textfield:maxvisible to attr:maxvisible.}).
                haskey("onchange", attr, {set textfield:onchange to uiFunctions[attr:onchange]@.}).
        
                return popupmenu.
            },
            "hslider", {
                parameter parent, attr.
        
                global hslider to haskey(
                    "init",
                    attr,
                    {return haskey(
                        "min",
                        attr,
                        {return haskey(
                            "max",
                            attr,
                            {return parent:addRadiobutton(attr:text, attr:min, attr:max).},
                            {crash("hslider missing max attribute").}
                        ).},
                        {crash("hslider missing min attribute").}
                    ).},
                    {crash("hslider missing text attribute").}
                ).
                haskey("onchange", attr, {set hslider:onchange to uiFunctions[attr:onchange]@.}).
        
                return hslider.
            },
            "vslider", {
                parameter parent, attr.
        
                global vslider to haskey(
                    "init",
                    attr,
                    {return haskey(
                        "min",
                        attr,
                        {return haskey(
                            "max",
                            attr,
                            {return parent:addRadiobutton(attr:text, attr:min, attr:max).},
                            {crash("vslider missing max attribute").}
                        ).},
                        {crash("vslider missing min attribute").}
                    ).},
                    {crash("vslider missing text attribute").}
                ).
                haskey("onchange", attr, {set vslider:onchange to uiFunctions[attr:onchange]@.}).
        
                return vslider.
            },
            "hlayout", {
                parameter parent, attr.
        
                global box to parent:addHLayout.
        
                haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).
        
                return box.
            },
            "vlayout", {
                parameter parent, attr.
                global box to parent:addVLayout.
                haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).
        
                return box.
            },
            "hbox", {
                parameter parent, attr.
                global box to parent:addHBox.
                haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).
        
                return box.
            },
            "vbox", {
                parameter parent, attr.
                global box to parent:addVBox.
                haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).
        
                return box.
            },
            "stack", {
                parameter parent, attr.
                global box to parent:addVBox.
                haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).
        
                return box.
            },
            "scrollbox", {
                parameter parent, attr.
                global box to parent:addVBox.
                haskey("valways", attr, {set vslider:valways to attr:valways.}).
                haskey("halways", attr, {set vslider:halways to attr:halways.}).
                haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).
        
                return box.
            },
            "spacing", {
                parameter parent, attr.
        
                global spacing to haskey(
                    "amount",
                    attr,
                    {return parent:addSpacing(attr:amount).},
                    {crash("Spacing missing amount attribute").}
                ).
        
                return spacing.
            }
        ).
        
        global uiFunctions to Lexicon().
        
        function registerFunction {
            parameter name.
            parameter func.
            uiFunctions:add(name + "@", func).
        }
        
        // Allow for generic casting of attributes using the attribute name
        function cast {
            parameter tag.
            parameter attr.
            parameter casts.
        
            local c to casts[tag].
            for k in attr:keys {
                if c:hassuffix(k) {
                    set attr[k] to c[k](attr[k]).
                }
            }
            return attr.
        }
        
        // Generic if else statement
        function haskey {
            parameter tag.
            parameter attr.
            parameter action.
            parameter elseAction is {}.
            if attr:haskey(tag) {
                return action().
            }else {
                return elseAction().
            }
        }
        
        // Create a child element for a given gui element
        function createChild {
            parameter parent.
            parameter child.
            local attr to cast(child:tag, child:attributes, childCast).
            return childInit[child:tag](parent, attr).
        }
        
        // Create the base gui element
        function createRoot {
            parameter elm.
        
            if not elm:tag = "gui" {
                crash("Only gui tag can be root level").
            }
            local attr to cast(elm:tag, elm:attributes, guiCast).
            set attr:width to 100.
            global ui to haskey(
                "height",
                attr,
                {return Gui(attr:width, attr:height).},
                {return Gui(attr:width).}
            ).
            haskey("x", attr, {set ui:x to attr:x.}).
            haskey("y", attr, {set ui:y to attr:y.}).
            haskey("draggable", attr, {set ui:draggable to attr:draggable.}).
            haskey("extradelay", attr, {set ui:extradelay to attr:extradelay.}).
            haskey("tooltip", attr, {set ui:tooltip to attr:tooltip.}).
            haskey("show", attr, {ui:show().}).
            haskey("hide", attr, {ui:hide().}).
            haskey("onradiochange", attr, {set ui:onradiochange to uiFunctions[attr:onradiochange]@.}).
            
            return ui.
        }
        
        // Create a gui from a xml file
        function createGUI {
            parameter uiPath.
            return parse_xml(
                uiPath,
                Lexicon(
                    "elements", List(),
                    "elmStack", Stack()
                ),
                { // Start root element
                    parameter state.
                    parameter element.
        
                    print(element).
                    local elm to createRoot(element).
                    state:elements:add(elm).
        
                    if not element:isBlockEnd {
                        state:elmStack:push(elm).
                    }
                    return state.
                },
                { // Start child element
                    parameter state.
                    parameter element.
                    
                    // Find the parent o the element
                    local parent to state:elmStack:peek().
        
                    local elm to createChild(parent, element).
                    state:elements:add(elm).
        
                    if not element:isBlockEnd {
                        state:elmStack:push(elm).
                    }
                    return state.
                },
                { // End element
                    parameter state.
                    parameter element.
                    
                    state:elmStack:pop().
        
                    return state.
                }
            ):elements.
        }
        
        
        global isDone to False.
        function close {
            set isDone to True.
        }
        
        // Register a function to allow the gui to acces it
        registerFunction("close", close@).
        
        // Create the gui
        global ui to createGUI("0:/ui/test_gui.xml").
        
        // Store the root in a variable
        // This is important as the ui will otherwise disapear after 5-10 seconds
        global u to ui[0].
        
        // Wait until the quit button is pressed
        wait until isDone.
        
        // Close the ui
        u:hide().