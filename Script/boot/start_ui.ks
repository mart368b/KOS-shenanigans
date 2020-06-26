core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
copyPath("0:/", "1:/").

// Load the ui module
runPath("0:/KOS-shenanigans/remote/compiler.ks", "0:/ui_test.ks", "0:/out/ui_test.ks").

runPath("0:/out/ui_test").
