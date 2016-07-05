# Lor 

<a href="./README_zh.md" style="font-size:13px">中文</a> <a href="./README.md" style="font-size:13px">English</a> 


A fast and minimalist web framework based on [OpenResty](http://openresty.org).

[![https://travis-ci.org/sumory/lor.svg?branch=master](https://travis-ci.org/sumory/lor.svg?branch=master)](https://travis-ci.org/sumory/lor) 



```lua
local lor = require("lor.index")
local app = lor()

app:get("/", function(req, res, next)
    res:send("hello world!")
end)

app:run()
```

## Examples

- [lor-example](https://github.com/lorlabs/lor-example)
- [openresty-china](https://github.com/sumory/openresty-china)


## Installation


```
git clone https://github.com/sumory/lor
cd lor
sh install.sh /opt/lua # install lor in /opt/lua/lor
# or
sh install.sh # install lor in /usr/local/lor
```



## Features

- Routing like [Sinatra](http://www.sinatrarb.com/) which is a famous Ruby framework
- Similar API with [Express](http://expressjs.com), good experience for Node.js or Javascript developers
- Middleware support
- Group router support
- Session/Cookie/Views supported and could be redefined with `Middleware`
- Easy to build HTTP APIs, web site, or single page applications



## Docs & Community

- [Website and Documentation](http://lor.sumory.com).
- [Github Organization](https://github.com/lorlabs) for Official Middleware & Modules.




## Quick Start

A quick way to get started with lor is to utilize the executable cli tool `lord` to generate an scaffold application.

`lord` is installed with `lor` framework. it looks like:

```bash
$ lord -h
lor ${version}, a Lua web framework based on OpenResty.

Usage: lor COMMAND [OPTIONS]

Commands:
 new [name]             Create a new application
 start                  Starts the server
 stop                   Stops the server
 restart                Restart the server
 version                Show version of lor
 help                   Show help tips
```

Create the app:

```
$ lord new lor_demo
```

Start the server:

```
$ cd lor_demo & lord start
```

Visit [http://localhost:8888](http://localhost:8888).



## Tests

Install [busted](http://olivinelabs.com/busted/), then run test

```
busted test/*.test.lua
```


### Contributors

- [@wanghaisheng](https://github.com/wanghaisheng)
- [@lihuibin](https://github.com/lihuibin)
- [@ms2008](https://github.com/ms2008)


## License

[MIT](./LICENSE)