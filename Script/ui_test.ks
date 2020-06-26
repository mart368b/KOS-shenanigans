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