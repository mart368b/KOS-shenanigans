core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
copyPath("0:/", "1:/").

// Load the ui module
runPath("0:/KOS-shenanigans/remote/load_module.ks", "0:/ui.ks", "0:/out/ui.ks").
// Load the xml module
runPath("0:/KOS-shenanigans/remote/load_module.ks", "0:/KOS-shenanigans/xml/parse_xml.ks", "0:/out/xml.ks").

// Load the xml module
runPath("0:/KOS-shenanigans/remote/load_module.ks", "0:/KOS-shenanigans/xml/create_ui.ks", "0:/out/xml_ui.ks").

runPath("0:/out/ui").
