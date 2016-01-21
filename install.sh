#!/bin/sh

PACKAGE_PATH="$1"
LOR_PATH="/usr/local/bin/"

echo "start installing lord..."

if [ -n "$PACKAGE_PATH" ];then
   echo "use defined PATH: "${PACKAGE_PATH}
else
   PACKAGE_PATH="/tmp/lua_framework"
   echo "use default PATH: ${PACKAGE_PATH}"
fi

mkdir -p $PACKAGE_PATH
mkdir -p $LOR_PATH

rm -rf $LOR_PATH/lor
rm -rf $PACKAGE_PATH/*


echo "install lor cli to $LOR_PATH"

echo "#!/bin/sh" > tmp_lor_bin
echo "LOR_PACKAGE_PATH=$PACKAGE_PATH" >> tmp_lor_bin
echo "if [ \"\$1\" == \"--path\" ] " >> tmp_lor_bin #space should be @ both side of ==
echo "then " >> tmp_lor_bin
echo "echo \"\$LOR_PACKAGE_PATH\" " >> tmp_lor_bin
echo "else" >> tmp_lor_bin
echo "exec 'luajit' -e 'package.path=\"$PACKAGE_PATH/?.lua;$PACKAGE_PATH/?/init.lua\"; package.cpath=\"$PACKAGE_PATH/?.so\"' '$PACKAGE_PATH/bin/lord' \"\$@\"">>tmp_lor_bin
echo "fi ">> tmp_lor_bin

mv tmp_lor_bin $LOR_PATH/lord
chmod 711 $LOR_PATH/lord

echo "install lor package to $PACKAGE_PATH"
cp -a ./* $PACKAGE_PATH/

echo "lord(lor framework cli tool) installed."