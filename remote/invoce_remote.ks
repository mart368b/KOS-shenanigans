// Clear the result associated with the specified namespace
function clearResult {
    parameter name.
    local p to "0:/out/results/" + name + ".json".
    if not exists(p) {
        create(p).
    }
    open(p):clear().
}

// Get the result stored in the specified namespace
function getResult {
    parameter name.
    local p to "0:/out/results/" + name + ".json".
    if open(p):size > 0 {
        return readJson(p).
    }
}

// Set the result stored in the specified namespace
function returnResult {
    parameter name.
    parameter keyValues.
    local p to "0:/out/results/" + name + ".json".
    WRITEJSON(Lexicon(keyValues), p).
}

// Call another file as if it was a function
// arguments are sent as a single list, 
// and results are returned using the provided namespace
function remoteInvocation {
    parameter name.
    parameter file.
    parameter args is List().

    clearResult(name).
    runPath(file, args).
    return getResult(name).
}