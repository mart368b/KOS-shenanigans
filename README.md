
# Example
## startup file
```kos
// Compile the ui file
runPath("0:/KOS-shenanigans/remote/load_module.ks", "0:/ui.ks", "0:/out/ui.ks").

// Run the ui file
runPath("0:/out/ui").
```

## gui.xml
```xml
<gui width=200 height=300 show>
    <label text='Hello World!'/>
    <hlayout>
        <button text='Close' onclick=close@/>
    </hlayout>
</gui>
```

## ui.ks
```kos
// Get the library
import 0:/KOS-shenanigans/xml/create_ui.ks.


global isDone to False.
function close {
    print("-----------------------").
    print(u).
}

// Register a function to allow the gui to acces it
registerFunction("close", close@).

// Create the gui
global ui to createGUI("0:/gui.xml").

// Store the root in a variable
// This is important as the ui will othervise disapear after 5-10 seconds
global u to ui[0].

// Wait until the quit button is pressed
wait until isDone.
print("Complete").
```

# UI Elements
### Table of content
[Gui](#gui)\
[label](#label)\
[button](#button)\
[checkbox](#checkbox)\
[radiobutton](#radiobutton)\
[textfield](#textfield)\
[popupmenu](#popupmenu)\
[hslide](#hslide)\
[vslide](#vslide)\
[hlayout](#hlayout)\
[vlayout](#vlayout)\
[hbox](#hbox)\
[vbox](#vbox)\
[stack](#stack)\
[scrollbox](#scrollbox)\
[spacing](#spacing)

### [gui](https://ksp-kos.github.io/KOS/structures/gui_widgets/gui.html)
Allow children
| name          | type                                 |required |
|---------------|--------------------------------------|----------|
|width          |<span style="color:teal">scalar</span>|          |
|height         |<span style="color:teal">scalar</span>|          |
|x              |<span style="color:teal">scalar</span>|          |
|y              |<span style="color:teal">scalar</span>|          |
|draggable      |<span style="color:green">bool</span> |          |
|extradelay     |<span style="color:teal">scalar</span>|          |
|show           |<span style="color:yellow">func</span>|          |
|hide           |<span style="color:yellow">func</span>|          |
|onradiochange  |<span style="color:yellow">func</span>|          |
### [label](https://ksp-kos.github.io/KOS/structures/gui_widgets/label.html)
| name  | type                                 |required                        |
|-------|--------------------------------------|--------------------------------|
|text   |<span style="color:grey">string</span>|<span style="color:red">*</span>|
|image  |<span style="color:grey">string</span>|                                |
|tooltip|<span style="color:grey">string</span>|                                |
### [button](https://ksp-kos.github.io/KOS/structures/gui_widgets/button.html)
| name   | type                                 |required                        |
|--------|--------------------------------------|--------------------------------|
|text    |<span style="color:grey">string</span>|<span style="color:red">*</span>|
|onclick |<span style="color:yellow">func</span>|                                |
|ontoggle|<span style="color:yellow">func</span>|                                |
### [checkbox](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html?highlight=checkbox#BOX:ADDCHECKBOX)
| name   | type                                 |required                        |
|--------|--------------------------------------|--------------------------------|
|text    |<span style="color:grey">string</span>|<span style="color:red">*</span>|
|on      |<span style="color:green">bool</span> |<span style="color:red">*</span>|
|onclick |<span style="color:yellow">func</span>|                                |
|ontoggle|<span style="color:yellow">func</span>|                                |
### [radiobutton](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html?highlight=radiobutton#BOX:ADDRADIOBUTTON)
| name   | type                                 |required                        |
|--------|--------------------------------------|--------------------------------|
|text    |<span style="color:grey">string</span>|<span style="color:red">*</span>|
|on      |<span style="color:green">bool</span> |<span style="color:red">*</span>|
|onclick |<span style="color:yellow">func</span>|                                |
|ontoggle|<span style="color:yellow">func</span>|                                |
### [textfield](https://ksp-kos.github.io/KOS/structures/gui_widgets/textfield.html)
| name    | type                                 |required                        |
|---------|--------------------------------------|--------------------------------|
|text     |<span style="color:grey">string</span>|<span style="color:red">*</span>|
|onchange |<span style="color:yellow">func</span>|                                |
|onconfirm|<span style="color:yellow">func</span>|                                |
|tooltip  |<span style="color:grey">string</span>|                                |
### [popupmenu](https://ksp-kos.github.io/KOS/structures/gui_widgets/popupmenu.html)
| name     | type                                 |required                        |
|----------|--------------------------------------|--------------------------------|
|options   |list                                  |<span style="color:red">*</span>|
|onchange  |<span style="color:yellow">func</span>|                                |
|maxvisible|<span style="color:teal">scalar</span>|                                |
|onchange|<span style="color:yellow">func</span>  |                                |
### [hslide](https://ksp-kos.github.io/KOS/structures/gui_widgets/slider.html)
| name   | type                                 |required                        |
|--------|--------------------------------------|--------------------------------|
|init    |<span style="color:teal">scalar</span>|<span style="color:red">*</span>|
|min     |<span style="color:teal">scalar</span>|<span style="color:red">*</span>|
|max     |<span style="color:teal">scalar</span>|<span style="color:red">*</span>|
|onchange|<span style="color:yellow">func</span>|                                |
### [vslide](https://ksp-kos.github.io/KOS/structures/gui_widgets/slider.html)
| name   | type                                 |required                        |
|--------|--------------------------------------|--------------------------------|
|init    |<span style="color:teal">scalar</span>|<span style="color:red">*</span>|
|min     |<span style="color:teal">scalar</span>|<span style="color:red">*</span>|
|max     |<span style="color:teal">scalar</span>|<span style="color:red">*</span>|
|onchange|<span style="color:yellow">func</span>|                                |
### [hlayout](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html?highlight=hlayout#BOX:ADDHLAYOUT)
Allow children
| name        | type                                 |required|
|-------------|--------------------------------------|--------|
|onradiochange|<span style="color:yellow">func</span>|        |
### [vlayout](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html?highlight=hlayout#BOX:ADDVLAYOUT)
Allow children
| name        | type                                 |required|
|-------------|--------------------------------------|--------|
|onradiochange|<span style="color:yellow">func</span>|        |
### [hbox](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html?highlight=hlayout#BOX:ADDHBOX)
Allow children
| name        | type                                 |required|
|-------------|--------------------------------------|--------|
|onradiochange|<span style="color:yellow">func</span>|        |
### [vbox](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html?highlight=hlayout#BOX:ADDVBOX)
Allow children
| name        | type                                 |required|
|-------------|--------------------------------------|--------|
|onradiochange|<span style="color:yellow">func</span>|        |
### stack
| name        | type                                 |required|
|-------------|--------------------------------------|--------|
|onradiochange|<span style="color:yellow">func</span>|        |
### [scrollbox](https://ksp-kos.github.io/KOS/structures/gui_widgets/scrollbox.html)
Allow children
| name        | type                                 |required|
|-------------|--------------------------------------|--------|
|halways      |<span style="color:green">bool</span> |        |
|valways      |<span style="color:green">bool</span> |        |
|onradiochange|<span style="color:yellow">func</span>|        |

### [spacing](https://ksp-kos.github.io/KOS/structures/gui_widgets/spacing.html)
| name | type                                 |required                        |
|------|--------------------------------------|--------------------------------|
|amount|<span style="color:yellow">func</span>|<span style="color:red">*</span>|