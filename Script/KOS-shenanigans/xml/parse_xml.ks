import 0:/KOS-shenanigans/remote/invoce_remote.ks.
import 0:/KOS-shenanigans/err.ks.

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

// Parse the content of a file xml into kos gui elements
function sax_parser {
    parameter file.
    parameter createChild.
    parameter createRoot.

    local elements to List().
    local file to open(file).
    local lines to file:readall():iterator().
    local xmlStack to Stack().
    local elmStack to Stack().
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
                elmStack:pop().
                local parent to xmlStack:pop().
                if not element:tag = parent:tag{
                    crash("End tag does not match start tag").
                }
            }else {
                // Create the new element
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
    }
    if elmStack:length() <> 0 or xmlStack:length() <> 0 {
        crash("Missing closing tags").
    }
    return elements.
}

