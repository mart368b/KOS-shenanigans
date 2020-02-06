import 0:/KOS-shenanigans/xml/parse_xml.ks

parameter args.

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
    parameter tag.
    parameter attr.

    local c to Casts[tag].
    for k in attr:keys {
        print(k).
        set attr[k] to c[k](attr[k]).
    }
    return attr.
}

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

global UiCore to Lexicon("gui", {
    parameter parent.
    parameter elm.

    local attr to cast(elm:tag, elm:attributes).
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

function createGUI {
    parameter uiPath.

    local createChild to {
        parameter parent.
        parameter child.
        print(child).
        return child.
    }.

    local createRoot to {
        parameter element.
        print(element).
        return element.
    }.
    sax_parser(uiPath, createChild, createRoot).
}

createGUI(args[0]).

