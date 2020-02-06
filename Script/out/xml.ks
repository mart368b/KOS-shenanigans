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

parameter args.

global lines to open(args[0]):readall():iterator.

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
    local isBlockEnd to line[1] = "/".
    local isDeclarationEnd to line[line:length - 2] = "/".

    local offset to 1.
    if isBlockEnd {
        set offset to 2.
    }
    local countOffset to 1.
    if isDeclarationEnd {
        set countOffset to 2.
    }
    local body to line:substring(offset, line:length - offset - countOffset):split(" "):iterator.
    body:next.
    local name to body:value.
    local attributes to Lexicon().
    until not body:next {
        local part to body:value.
        local segments to part:split("=").
        if segments:length >= 2 {
            attributes:add(segments[0]:tolower, segments[1]).
        }else {
            attributes:add(segments[0]:tolower, "").
        }
    }

    return Lexicon(
        "isBlockEnd", isBlockEnd,
        "name", name,
        "attributes", attributes,
        "isDeclarationEnd", isDeclarationEnd
    ).
}

function toScalar {
    parameter value.
    return value:toScalar().
}

function toNumber {
    parameter value.
    return value:toScalar().
}

function toBoolean {
    parameter value.
    return value:tolower() = "true".
}
function accept {
    parameter value.
    return value.
}

global Casts to Lexicon(
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

function cast {
    parameter name.
    parameter attr.

    local c to Casts[name].
    for k in attr:keys {
        print(k).
        set attr[k] to c[k](attr[k]).
    }
    return attr.
}

function haskey {
    parameter name.
    parameter attr.
    parameter action.
    parameter elseAction is {}.
    if attr:haskey(name) {
        return action().
    }else {
        return elseAction().
    }
}

global UiCore to Lexicon("gui", {
    parameter parent.
    parameter elm.

    local attr to cast(elm:name, elm:attributes).
    local ui to haskey(
        "height",
        attr,
        {return GUI(attr:width, attr:height).},
        {return GUI(attr:width).}
    ).
    haskey("x", attr, {set ui:x to attr:x.}).
    haskey("y", attr, {set ui:y to attr:y.}).
    haskey("draggable", attr, {set ui:draggable to attr:draggable.}).
    haskey("extradelay", attr, {set ui:extradelay to attr:extradelay.}).
    haskey("tooltip", attr, {set ui:tooltip to attr:tooltip.}).
    haskey("show", attr, {ui:show.}).
    haskey("hide", attr, {ui:hide.}).
    return ui.
}).

global line to nextLine(false).

local line to parse_line(line).
UiCore[line:name](false, line).
