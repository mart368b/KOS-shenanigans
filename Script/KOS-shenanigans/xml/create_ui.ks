import 0:/KOS-shenanigans/xml/parse_xml.ks.
import 0:/KOS-shenanigans/xml/ui_elements.ks.

global uiFunctions to Lexicon().

function registerFunction {
    parameter name.
    parameter func.
    uiFunctions:add(name + "@", func).
}

// Allow for generic casting of attributes using the attribute name
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

// Generic if else statement
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

// Create a child element for a given gui element
function createChild {
    parameter parent.
    parameter child.
    local attr to cast(child:tag, child:attributes, childCast).
    return childInit[child:tag](parent, attr).
}

// Create the base gui element
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

// Create a gui from a xml file
function createGUI {
    parameter uiPath.
    return parse_xml(
        uiPath,
        Lexicon(
            "elements", List(),
            "elmStack", Stack()
        ),
        { // Start root element
            parameter state.
            parameter element.

            print(element).
            local elm to createRoot(element).
            state:elements:add(elm).

            if not element:isBlockEnd {
                state:elmStack:push(elm).
            }
            return state.
        },
        { // Start child element
            parameter state.
            parameter element.
            
            // Find the parent o the element
            local parent to state:elmStack:peek().

            local elm to createChild(parent, element).
            state:elements:add(elm).

            if not element:isBlockEnd {
                state:elmStack:push(elm).
            }
            return state.
        },
        { // End element
            parameter state.
            parameter element.
            
            state:elmStack:pop().

            return state.
        }
    ):elements.
}
