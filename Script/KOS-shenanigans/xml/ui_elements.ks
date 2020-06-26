// Cast for scalar values
function toScalar {
    parameter value.
    return value:toScalar().
}

// Cast for numbers values
function toNumber {
    parameter value.
    return value:toScalar().
}

// Cast for string values
function toString {
    parameter value.
    return value:substring(1, value:length - 2).
}

// Cast for boolean values
function toBoolean {
    parameter value.
    return value:tolower() = "true".
}

// Cast for list values
function toList {
    parameter value.
    local items to value:split(",").
    local l to List().
    for item in items {
        l:add(item:trim()).
    }
    return l.
}

// Cast allowing for any value to pass
function accept {
    parameter value.
    return value.
}

// Set casting used by GUI element
global guiCast to Lexicon(
    "gui", Lexicon(
        "width", toScalar@,
        "height", toScalar@,
        "x", toScalar@,
        "y", toScalar@,
        "draggable", toBoolean@,
        "extradelay", toScalar@,
        "show", accept@,
        "hide", accept@,
        "onradiochange", accept@
    )
).

// Set casting for any child elements of the gui element
global childCast to Lexicon(
    "label", Lexicon(
        "text", toString@,
        "image", toString@,
        "tooltip", toString@
    ),
    "button", Lexicon(
        "text", toString@,
        "onclick", accept@,
        "ontoggle", accept@
    ),
    "checkbox", Lexicon(
        "text", toString@,
        "on", toBoolean@,
        "onclick", accept@,
        "ontoggle", accept@
    ),
    "radiobutton", Lexicon(
        "text", toString@,
        "on", toBoolean@,
        "onclick", accept@,
        "ontoggle", accept@
    ),
    "textfield", Lexicon(
        "text", toString@,
        "onchange", accept@,
        "onconfirm", accept@,
        "tooltip", toString@
    ),
    "popupmenu", Lexicon(
        "options", toList@,
        "onchange", accept@,
        "maxvisible", toScalar@
    ),
    "hslide", Lexicon(
        "init", toScalar@,
        "min", toScalar@,
        "max", toScalar@,
        "onchange", accept@
    ),
    "vslide", Lexicon(
        "init", toScalar@,
        "min", toScalar@,
        "max", toScalar@,
        "onchange", accept@
    ),
    "hlayout", Lexicon(
        "onradiochange", accept@
    ),
    "vlayout", Lexicon(
        "onradiochange", accept@
    ),
    "hbox", Lexicon(
        "onradiochange", accept@
    ),
    "vbox", Lexicon(
        "onradiochange", accept@
    ),
    "stack", Lexicon(
        "onradiochange", accept@
    ),
    "scrollbox", Lexicon(
        "halways", toBoolean@,
        "valways", toBoolean@,
        "onradiochange", accept@
    ),
    "spacing", Lexicon(
        "amount", accept@
    )
).

// Container for initialzing child values based on provided attributes
global childInit to Lexicon(
    "label", {
        parameter parent, attr.

        global label to haskey(
            "text",
            attr,
            {return parent:addLabel(attr:text).},
            {crash("Label missing text attribute").}
        ).
        haskey("tooltip", attr, {set label:tooltip to attr:tooltip.}).
        haskey("image", attr, {set label:image to attr:image.}).

        return label.
    },
    "button", {
        parameter parent, attr.

        global button to haskey(
            "text",
            attr,
            {return parent:addButton(attr:text).},
            {crash("button missing text attribute").}
        ).
        haskey("onclick", attr, {set button:onclick to uiFunctions[attr:onclick]@.}).
        haskey("ontoggle", attr, {set button:ontoggle to uiFunctions[attr:ontoggle]@.}).

        return button.
    },
    "checkbox", {
        parameter parent, attr.

        global checkbox to haskey(
            "text",
            attr,
            {return haskey(
                "on",
                attr,
                {return parent:addCheckbox(attr:text, attr["on"]).},
                {crash("checkbox missing on attribute").}
            ).},
            {crash("checkbox missing text attribute").}
        ).
        haskey("onclick", attr, {set checkbox:onclick to uiFunctions[attr:onclick]@.}).
        haskey("ontoggle", attr, {set checkbox:ontoggle to uiFunctions[attr:ontoggle]@.}).

        return checkbox.
    },
    "radiobutton", {
        parameter parent, attr.

        global radiobutton to haskey(
            "text",
            attr,
            {return haskey(
                "on",
                attr,
                {return parent:addRadiobutton(attr:text, attr["on"]).},
                {crash("radiobutton missing on attribute").}
            ).},
            {crash("radiobutton missing text attribute").}
        ).
        haskey("onclick", attr, {set radiobutton:onclick to uiFunctions[attr:onclick]@.}).
        haskey("ontoggle", attr, {set radiobutton:ontoggle to uiFunctions[attr:ontoggle]@.}).

        return radiobutton.
    },
    "textfield", {
        parameter parent, attr.

        global textfield to haskey(
            "text",
            attr,
            {return parent:addTextfield(attr:text).},
            {crash("textfield missing text attribute").}
        ).
        haskey("onchange", attr, {set textfield:onchange to uiFunctions[attr:onchange]@.}).
        haskey("onconfirm", attr, {set textfield:onconfirm to uiFunctions[attr:onconfirm]@.}).
        haskey("tooltip", attr, {set textfield:tooltip to uiFunctions[attr:tooltip]@.}).

        return textfield.
    },
    "popupmenu", {
        parameter parent, attr.

        global popupmenu to parent:addPopupmenu().

        haskey("options", attr, {set textfield:options to attr:options.}).
        haskey("maxvisible", attr, {set textfield:maxvisible to attr:maxvisible.}).
        haskey("onchange", attr, {set textfield:onchange to uiFunctions[attr:onchange]@.}).

        return popupmenu.
    },
    "hslider", {
        parameter parent, attr.

        global hslider to haskey(
            "init",
            attr,
            {return haskey(
                "min",
                attr,
                {return haskey(
                    "max",
                    attr,
                    {return parent:addRadiobutton(attr:text, attr:min, attr:max).},
                    {crash("hslider missing max attribute").}
                ).},
                {crash("hslider missing min attribute").}
            ).},
            {crash("hslider missing text attribute").}
        ).
        haskey("onchange", attr, {set hslider:onchange to uiFunctions[attr:onchange]@.}).

        return hslider.
    },
    "vslider", {
        parameter parent, attr.

        global vslider to haskey(
            "init",
            attr,
            {return haskey(
                "min",
                attr,
                {return haskey(
                    "max",
                    attr,
                    {return parent:addRadiobutton(attr:text, attr:min, attr:max).},
                    {crash("vslider missing max attribute").}
                ).},
                {crash("vslider missing min attribute").}
            ).},
            {crash("vslider missing text attribute").}
        ).
        haskey("onchange", attr, {set vslider:onchange to uiFunctions[attr:onchange]@.}).

        return vslider.
    },
    "hlayout", {
        parameter parent, attr.

        global box to parent:addHLayout.

        haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).

        return box.
    },
    "vlayout", {
        parameter parent, attr.
        global box to parent:addVLayout.
        haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).

        return box.
    },
    "hbox", {
        parameter parent, attr.
        global box to parent:addHBox.
        haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).

        return box.
    },
    "vbox", {
        parameter parent, attr.
        global box to parent:addVBox.
        haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).

        return box.
    },
    "stack", {
        parameter parent, attr.
        global box to parent:addVBox.
        haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).

        return box.
    },
    "scrollbox", {
        parameter parent, attr.
        global box to parent:addVBox.
        haskey("valways", attr, {set vslider:valways to attr:valways.}).
        haskey("halways", attr, {set vslider:halways to attr:halways.}).
        haskey("onradiochange", attr, {set box:onradiochange to uiFunctions[attr:onradiochange]@.}).

        return box.
    },
    "spacing", {
        parameter parent, attr.

        global spacing to haskey(
            "amount",
            attr,
            {return parent:addSpacing(attr:amount).},
            {crash("Spacing missing amount attribute").}
        ).

        return spacing.
    }
).