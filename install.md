use `install.sh` to install `lor`

```
#set path to keep lor package. if not, /tmp/lua_framework will be used
sh install.sh /opt/lua/lor 
```

then the `lor` cli will be installed in /usr/local/bin, `which lor` to check:

```
root:/data/lua_framework/lor # which lor
/usr/local/bin/lor
```

and the `lor package` will be installed in /opt/lua/lor, `ll /opt/lua/lor` to check:

```
root:/data/lua_framework/lor # ll /opt/lua/lor
total 48
drwxr-xr-x  12 root  wheel   408B  1 16 20:28 .
drwxr-xr-x   3 root  wheel   102B  1 16 20:28 ..
-rw-r--r--   1 root  wheel     0B  1 16 16:00 CHANGELOG.md
-rw-r--r--   1 root  wheel   1.0K  1 16 16:06 LICENSE
-rw-r--r--   1 root  wheel     0B  1 14 21:09 Makefile
-rw-r--r--   1 root  wheel    52B  1 15 23:50 README.md
-rw-r--r--   1 root  wheel   314B  1 16 20:27 install.md
-rw-r--r--   1 root  wheel   1.0K  1 16 20:23 install.sh
drwxr-xr-x   8 root  wheel   272B  1 15 21:38 lor
drwxr-xr-x   4 root  wheel   136B  1 12 21:25 test
-rw-r--r--   1 root  wheel   130B  1 15 21:38 test.sh
-rw-r--r--   1 root  wheel     6B  1 15 23:43 version
```

after all the above, `lor` is successfully installed. now you can use `lor`, type `lor -h` for help:

```
root:/data/lua_framework/lor # lor -h
lor v0.0.1, a Lua web framework based on OpenResty.

Usage: lor COMMAND [OPTIONS]

Commands:
 new [name]             Create a new application
 start                  Starts the server
 stop                   Stops the server
 restart                Restart the server
 version                Show version of lor
 help                   Show help tips

Options:
 --debug                Show some runtime details
```