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
        function crash {
            parameter msg.
            msg:tonumber().
        }
        
        function nextLine {
            parameter canEnd.
        
            local hasNext to lines:next. 
            if not hasNext and not canEnd {
                print("Unexpected EOF").
            }else {
                return lines:value.
            }
        }
        
        function parse_line {
            parameter line.
            
            local trimmed to line:trim().
            
            local isEnd to trimmed[1] = "/".
            local isBlockEnd to trimmed[trimmed:length - 2] = "/".
        
            local start to 1.
            if isEnd {
                set start to 2.
            }
            local end to trimmed:length - 2.
            if isEnd {
                set end to trimmed:length - 3.
            }
            local iter to trimmed:substring(start, end):split(" "):iterator.
            iter:next().
            local tag to iter:value.
        
            local attributes to Lexicon().
        
            until not iter:next() {
                local part to iter:value:split("=").
                if part:length = 2 {
                    local value to part[1].
                    if value:contains("'") {
                        local current to "".
                        until not iter:next() or current:contains("'") {
                            set current to iter:value.
                            set value to value + current.
                        }
                    }
                    attributes:add(part[0], value).
                }else {
                    if part[0]:trim():length <> 0 {
                        attributes:add(part[0], "").
                    }
                }
                
            }
        
            return Lexicon(
                "isEnd", isEnd,
                "tag", tag,
                "attributes", attributes,
                "isBlockEnd", isBlockEnd
            ).
        }
        
        function sax_parser {
            parameter file.
            parameter createChild.
            parameter createRoot.
        
            local elements to List().
            local file to open(file).
            local lines to file:readall():iterator().
            local xmlStack to Stack().
            local elmStack to Stack().
            until not lines:next() {
                print(lines:value).
                local element to parse_line(lines:value).
                if element:isEnd and element:isBlockEnd {
                    crash("Found double end element").
                }
                if xmlStack:length = 0 and element:isEnd {
                    crash("Tried to get parent from empty stack").
                }
                if element:isEnd {
                    elmStack:pop().
                    local parent to xmlStack:pop().
                    if not element:tag = parent:tag{
                        crash().
                    }
                }else {
                    local elm to "".
                    if not xmlStack:empty{
                        set elm to createChild(elmStack:peek(), element).
                    } else{
                        set elm to createRoot(element).
                    }
                    elements:add(elm).
                    if not element:isBlockEnd {
                        xmlStack:push(element).
                        elmStack:push(elm).
                    }
                }
            }
            if elmStack:length() <> 0 or xmlStack:length() <> 0 {
                crash("Missing closing tags").
            }
            return elements.
        }
        
        
        parameter args.
        
        function toScalar {
            parameter value.
            return value:toScalar().
        }
        
        function toNumber {
            parameter value.
            return value:toScalar().
        }
        
        function toString {
            parameter value.
            return value:substring(1, value:length - 2).
        }
        
        function toBoolean {
            parameter value.
            return value:tolower() = "true".
        }
        function accept {
            parameter value.
            return value.
        }
        
        global guiCast to Lexicon(
            "gui", Lexicon(
                "width", toScalar@,
                "height", toScalar@,
                "x", toScalar@,
                "y", toScalar@,
                "draggable", toBoolean@,
                "extradelay", toScalar@,
                "show", accept@,
                "hide", accept@
            )
        ).
        
        global childCast to Lexicon(
            "label", Lexicon(
                "text", toString@,
                "image", toString@,
                "tooltip", toString@
            )
        ).
        
        global childInit to Lexicon(
            "label", {
                parameter parent.
                parameter attr.
        
                local label to haskey(
                    "text",
                    attr,
                    {return parent:addLabel(attr:text).},
                    {crash("Label missing test attribute").}
                ).
                haskey("tooltip", attr, {set label:tooltip to attr:tooltip.}).
                haskey("image", attr, {set label:image to attr:image.}).
        
                return label.
            }
        ).
        
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
        
        function haskey {
            parameter tag.
            parameter attr.
            parameter action.
            parameter elseAction is {}.
            print(tag).
            if attr:haskey(tag) {
                return action().
            }else {
                return elseAction().
            }
        }
        
        function createChild {
            parameter parent.
            parameter child.
        
            local attr to cast(child:tag, child:attributes, childCast).
            return childInit[child:tag](parent, attr).
        }
        
        function createRoot {
            parameter elm.
        
            if not elm:tag = "gui" {
                crash("Only gui tag can be root level").
            }
            local attr to cast(elm:tag, elm:attributes, guiCast).
            set attr:width to 100.
            local ui to haskey(
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
            
            return ui.
        }
        
        function createGUI {
            parameter uiPath.
            return sax_parser(uiPath, createChild@, createRoot@).
        }
        global ui to createGUI(args[0]).