import 0:/KOS-shenanigans/xml/parse_xml.ks.
import 0:/KOS-shenanigans/xml/ui_elements.ks.

parameter args.

global uiFunctions to Lexicon().

function registerFunction {
    parameter name.
    parameter func.
    uiFunctions:add(name + "@", func).
}

function cast {
    parameter tag.
    parameter attr.
    parameter casts.

    print(tag).
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
    if attr:haskey(tag) {
        return action().
    }else {
        return elseAction().
    }
}

function createChild {
    parameter parent.
    parameter child.

    print(child).
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

function createGUI {
    parameter uiPath.
    return sax_parser(uiPath, createChild@, createRoot@).
}

global isDone to False.
function click {
    print("-----------------------").
}

registerFunction("click", click@).
global ui to createGUI(args[0]).
global u to ui[0].
wait until isDone.
print("Complete").
