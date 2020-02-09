import 0:/KOS-shenanigans/xml/parse_xml.ks.

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
