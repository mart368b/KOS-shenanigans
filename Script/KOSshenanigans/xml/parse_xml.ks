import 0:/KOS-shenanigans/remote/remote.ks.
import 0:/KOS-shenanigans/err.ks

parameter args.

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
    local isBlockEnd to trimmed[trimmed[trimmed:length - 2]] = "/".

    local start to 1.
    if isEnd {
        set start to 2.
    }
    local end to trimmed:length - 1.
    if isEnd {
        set end to trimmed:length - 2.
    }
    local iter to trimmed:substring(start, end):split(" "):iterator.
    iter:next().
    local tag to iter:value.

    local attributes to Lexicon().

    until iter:next() {
        local part to iter:value.
        attributes:add(part[0], part[1]).
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

    local lines to open(file):readall():iterator.
    local stack to Stack().
    until lines:next() {
        local element to parse_line(lines:value).
        if element:isEnd and element:isBlockEnd {
            crash("Found double end element").
        }
        if stack:length = 0 and element:isEnd {
            crash("Tried to get parent from empty stack").
        }
        if element:isEnd {
            local parent to stack:pop().
            if not element:tag = parent:tag{
                crash().
            }
        }else {
            if stack{
                createChild(stack[stack:length - 1], element).
            } else{
                set element to createRoot(element).
            }
            if not element:isBlockEnd {
                stack.push(element).
            }
        }
    }
    if stack:length() <> 0 {
        crash("Missing closing tags").
    }
}

