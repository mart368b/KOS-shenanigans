// List of names of keywords that are being looked for
global idents to Lexicon(
    // Import the content of one file into another
    "import", {
        parameter line.
        
        local parts to line:split(" ").
        if parts:length < 2 {
            print("import missing from_url argument").
            return "".
        }else {
            if parts[1]:findlast(".") <> (parts[1]:length - 1) {
                print("missing eol on line: " + line + " in file: " + from_url).
                return "".
            }else {
                return parse(parts[1]:substring(0, parts[1]:length - 1)).
            }
        }
    }
).

// Parse the content of a file using the keywords found in idents
// This is a recursive process as the imported module migth also have dependencies
// NOTE: Currently no check is peformed to see for cyclic dependancies
function parse {
    parameter url.

    local file to List().

    if not exists(url) {
        print("failed to find module " + url).
    } else {
        local content to open(url):readall().
        for line in content {
            local trimmed to line:trim().
            local isAdded to false.
            for key in idents:keys {
                local i to trimmed:find(key).
                if i = 0 {
                    set isAdded to true.
                    local action to idents[key](trimmed).
                    if not action:length = 0 {
                        file:add(action).
                    }
                    break.
                }
            }
            if not isAdded {
                file:add(line).
            }
        }
    }
    return file:join("
").
}

// Source path
parameter from_url.
// Taret path
parameter to_url.
// Indicate wether the file also should be compiled
parameter compiled is false.

// Container for the new files content
global file to List().

// Parse the provided file
local new_file to parse(from_url).
if not exists(to_url) {
    create(to_url).
}

// Write the content of the new file
local f to open(to_url).
f:clear().
f:write(new_file).

// Compile the file
if compiled {
    compuile(to_url).
}