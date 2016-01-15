#!/bin/bash

rm -rf /usr/local/bin/lor


# PATH="$1"

# if [ -n "$PATH" ];then
#    echo "use defined PATH: "${PATH}
# else
#    PATH="\/data\/tmp\/lua_framework\/lor\/"
#    echo "use default PATH: ${PATH}"
# fi

# sed -i  's/${TO_REPLACE_PATH}/'${PATH}'/g' lor/bin/lor

cp lor/bin/lor /usr/local/bin/
