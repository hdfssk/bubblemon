#!/bin/sh

# Make sure we are in the script directory
cd $(dirname $0)

echo "Generating configuration files for bubblemon..."
echo

autopoint --force && AUTOPOINT='intltoolize --automake --copy' autoreconf -fiv -Wall || exit $?
# gettextize --copy --force && intltoolize --automake --copy --force && autoreconf -fiv -Wall || exit $?

# Fix `error: po/Makefile.in.in was not created by intltoolize' configure error
# NB. does not work for out-of-tree builds
[ ! -f po/Makefile.in ] && echo "# INTLTOOL_MAKEFILE" >po/Makefile.in

echo
echo "Done generating configuration files for bubblemon, now do \"./configure && make && make install\""
