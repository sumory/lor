local supported_http_methods = {
    get = true,
    post = true,
    head = true,
    options = true,
    put = true,
    patch = true,
    delete = true,
    trace = true,
    all = true -- appended
}

return supported_http_methods