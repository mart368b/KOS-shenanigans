
Welcome to my crazy testing library of the kos language
You're more than welcome to take whatever you want

# Overview
 * Simple kos to kos compiler (compiler.ks)
 * Files as functions (invoce_remote.ks)
 * ui library based on a xml format (create_ui.ks)

# Module compilation
To allow for more modular code i have made a simple kos to kos compiler
## Example usage
In order to use the different modules of the system. The modules have to be compiled first.
This is easily done by calling the compiller script with the path to the file and where to save the compiled version.
```kos
// Compile the ui file
runPath("0:/KOS-shenanigans/remote/compiler.ks", "0:/create_ui.ks", "0:/out/create_ui.ks").

// Run the compiled create_ui module
runPath("0:/out/create_ui").
```

The main contribution of the compiler as it is. Is that it allows for import of the content of other files.

```kos
import 0:/KOS-shenanigans/err.ks.
```
will import the content of err.ks

# Using files as functions
after compiling the invoce_remote use **remoteInvocation(namespace: string, file path: string, args: List)** to call another file like it is a function.

Inside the other file, arguments can be taken using the __parameter__ keyword as ususal.
To return a value use the returnResult function. This returns a serializable value to whoever called it using the removeInvocation function.

# UI library
KOS has a build-in GUI library. However making the ui is very clomsy and easily lead to unreadable code. To that end i have written a xml parser that can generate the you for you. The parser supports all types as given in the [official documentation](https://ksp-kos.github.io/KOS/structures/gui.html?highlight=gui)

## GUi example
This creates a simple ui with a single button
```xml
<gui width=200 height=300 show>
    <label text='Hello World!'/>
    <hlayout>
        <button text='Close' onclick=close@/>
    </hlayout>
</gui>
```

The gui can then be created using create_ui.ks
```kos
// Get the library
import 0:/KOS-shenanigans/xml/create_ui.ks.


global isDone to False.
function close {
    set isDone to True.
}

// Register a function to allow the gui to acces it
registerFunction("close", close@).

// Create the gui
global ui to createGUI("0:/ui/test_gui.xml").

// Store the root in a variable
// This is important as the ui will otherwise disapear after 5-10 seconds
global u to ui[0].

// Wait until the quit button is pressed
wait until isDone.

// Close the ui
u:hide().
```
The above example can also be found in test_ui.ks

# Supported UI Elements
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