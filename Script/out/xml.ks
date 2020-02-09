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
                set start to start + 1.
            }
            local end to trimmed:length - 2.
            if isBlockEnd {
                set end to end - 1.
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
                        until current:contains("'") or not iter:next() {
                            set current to iter:value.
                            set value to value + " " + current.
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
        