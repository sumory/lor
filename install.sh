#!/bin/sh

PACKAGE_PATH="$1"
LOR_PATH="/usr/local/bin/"

echo "start installing lor..."

if [ -n "$PACKAGE_PATH" ];then
   PACKAGE_PATH="${PACKAGE_PATH}/lor" #add sub folder for lor
   echo "use defined PATH: "${PACKAGE_PATH}
else
   PACKAGE_PATH="/usr/local/lor"
   echo "use default PATH: ${PACKAGE_PATH}"
fi

mkdir -p $PACKAGE_PATH
mkdir -p $LOR_PATH

rm -rf $LOR_PATH/lord
rm -rf $PACKAGE_PATH/*


echo "install lor cli to $LOR_PATH"

echo "#!/usr/bin/env resty" > tmp_lor_bin
echo "package.path=\""${PACKAGE_PATH}"/?.lua;;\"" >> tmp_lor_bin
echo "if arg[1] and arg[1] == \"path\" then" >> tmp_lor_bin
echo "    print(\"${PACKAGE_PATH}\")" >> tmp_lor_bin
echo "    return" >> tmp_lor_bin
echo "end" >> tmp_lor_bin
echo "require('bin.lord')(arg)" >> tmp_lor_bin

mv tmp_lor_bin $LOR_PATH/lord
chmod 755 $LOR_PATH/lord

echo "install lor package to $PACKAGE_PATH"

mkdir -p ./lor
cp -a ./lib/lor/* ./lor/
cp -a ./* $PACKAGE_PATH/
rm -rf $PACKAGE_PATH/lib
rm -rf ./lor

echo "lor framework installed."
