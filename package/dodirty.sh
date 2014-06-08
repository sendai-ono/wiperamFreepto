#!/bin/bash
mkdir build
echo "2.0" > build/debian-binary
tar -zcf build/control.tar.gz -C control .
tar -cf build/data.tar -C data .
xz build/data.tar
ar q build/wiperam_0.1_all.deb build/debian-binary build/control.tar.gz build/data.tar.xz
find build/ -type f -not -name '*.deb' | xargs rm -f
