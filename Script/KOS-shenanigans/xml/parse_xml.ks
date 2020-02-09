import 0:/KOS-shenanigans/remote/invoce_remote.ks.
import 0:/KOS-shenanigans/err.ks.

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

