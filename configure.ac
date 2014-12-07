# -*-m4-*- Process this file with autoconf to produce a configure script.


###########################################################################
#
# General system tests required for building platform independent stuff.
#
#
AC_INIT([Bubbling Load Monitor],[3.0],[johan.walles@gmail.com],[bubblemon],
  [https://github.com/walles/bubblemon])
AC_CONFIG_SRCDIR(src/bubblemon.h)
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.5 foreign subdir-objects])
AC_PREREQ([2.69])

AC_CONFIG_HEADERS([config.h])

AC_PROG_INSTALL
AC_PROG_MKDIR_P
AC_PROG_SED
IT_PROG_INTLTOOL([0.35])
LT_INIT
PKG_PROG_PKG_CONFIG

# Compiler setup.
# --------------
AC_PROG_CC
AS_IF([test "x$GCC" = "xyes"],
  # -Wno-missing-field-initializers is because of
  # http://bugs.debian.org/509663
  #
  # -Wno-unused-parameter is because in *-ui.c our function prototypes
  # are decided by the panel API, and we have to accept
  # some parameters we never use.
  #
  # -Werror is set below, see `Output Our Test Results' section for details.
  CFLAGS="-g -O2 -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers"
  AC_SUBST(CFLAGS)
)
AM_PROG_CC_C_O
AC_SEARCH_LIBS([strerror],[cposix])
# exp2() function needed to generate tooltip
AC_SEARCH_LIBS([exp2],[m],,AC_MSG_ERROR([exp2() function not found]))

# big- vs. little-endian matters for setting colors
AC_C_BIGENDIAN

# Configure i18n and l10n.
# -----------------------
ALL_LINGUAS="sv fr pl de ko fi da pt ro es no hu it is ru ca pt_BR nl"
AC_ARG_WITH(
  all-linguas,
  [  --with-all-linguas      Compile support for all avaliable languages],
  all_linguas=yes)
AS_IF([test "x$all_linguas" = "xyes"],
  LINGUAS=$ALL_LINGUAS)

AC_MSG_CHECKING([what languages to include])
AC_MSG_RESULT($LINGUAS)

GETTEXT_PACKAGE=AC_PACKAGE_TARNAME
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", [Gettext wants to know...])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.18])
AM_CONDITIONAL(USE_NLS, test "x$USE_NLS" = "xyes")


######################################################################
#
# Bubblemon specific tests.
#
#

PKG_CHECK_MODULES(libgtop, [glib-2.0 >= 2.0.0 libgtop-2.0 >= 2.0.0])

# Profiling build support.
# -----------------------
AC_ARG_ENABLE(
  profiling,
  [  --enable-profiling      Pass profiling options to the compiler],
  profiling=yes)

AS_IF([test "x$profiling" = "xyes"], [
  AC_MSG_CHECKING(what profiling flags to pass to the compiler)
  profilingFLAGS="-pg"
  CFLAGS="$CFLAGS $profilingFLAGS"
  AC_MSG_RESULT($profilingFLAGS)
  AC_DEFINE([ENABLE_PROFILING], [], [Build a bubblemon that bubbles a lot for a minute and then exits])

  AC_MSG_WARN()
  AC_MSG_WARN(You have enabled profiling by specifying the --enable-profiling switch.)
  AC_MSG_WARN(Please don't install the applet the usual way; read the file PROFILING)
  AC_MSG_WARN(for instructions.)
  AC_MSG_WARN()
])


####################################
# Panel specific settings & tests.

# Constants and settings,
# ----------------------
# NB. the *first* panel in bubblemon_panels_supported is the default build target
m4_define([bubblemon_panels_supported],
  [[mate], [gnome3], [xfce4]])
m4_define([bubblemon_panels_default],
  m4_argn(1, bubblemon_panels_supported))
m4_define([bubblemon_panels_nondefault],
  m4_expand(m4_cdr(bubblemon_panels_supported)))
m4_define([bubblemon_panels_described],
  m4_expand(m4_join([, @&t@], bubblemon_panels_nondefault)[ or (default) ]bubblemon_panels_default[ panel]))

# panel build target test,
# -----------------------
AC_ARG_WITH(
  [panel],
  [AS_HELP_STRING([--with-panel],
    [target ]m4_expand([bubblemon_panels_described]))],
  [AS_CASE([$with_panel],
    [m4_join([|], bubblemon_panels_supported)], [],
    [AC_MSG_WARN(bubblemon does not support the "$with_panel" panel)
     AC_MSG_WARN(defaulting to "bubblemon_panels_default")
     with_panel=bubblemon_panels_default])],
  [with_panel=bubblemon_panels_default])
BUBBLEMON_PANEL=$with_panel
AC_SUBST(BUBBLEMON_PANEL)

AC_MSG_CHECKING([panel build target])
AC_MSG_RESULT($BUBBLEMON_PANEL)

# per-panel settings function, 
#
# BUBBLEMON_PANEL_CASE(PANEL, MODULES, PC-VAR=prefix, SUBPATH,
#                      EXTRA-COMMANDS, FALLBACK-COMMANDS)
# ----------------------------------------------------------------------------
# MODULES is a PKG_CHECK_MODULES style list.
# The first module checked _must_ be the libpanel library for the target panel.
# Each call expands to a PATTERN and its IF-MATCHED for AS_CASE,
# so always follow with a comma:
#
#   BUBBLEMON_PANEL_CASE(panel, [libpanelapplet-1.0 >= 1.0.0], , [/sub/path]),
#
# EXTRA-COMMANDS are run if the MODULES are present on the build system.
# FALLBACK-COMMANDS are run if they are not; if not provided, the configuration
#  will fail with an error.
#
AC_DEFUN([BUBBLEMON_PANEL_CASE],
  [[$1], BUBBLEMON_PANEL_CHECK_MODULES($@)])
AC_DEFUN([BUBBLEMON_PANEL_CHECK_MODULES],
        [[PKG_CHECK_MODULES([LIBPANEL], [$2],
           [BUBBLEMON_APPLET_LIB=m4_bpatsubst([$2], [ .*$])
            AC_MSG_NOTICE([using $BUBBLEMON_APPLET_LIB build environment])
            LIBPANEL_APPLET_DIR=$($PKG_CONFIG --variable=m4_default([$3], [prefix]) $BUBBLEMON_APPLET_LIB)$4
	    LIBPANEL_CFLAGS="$LIBPANEL_CFLAGS -I./panel/$1 -I./src"
            $5],
           m4_default([$6], [AC_MSG_ERROR([$1 panel libraries not found.])])
          )]])

# set up panel build target,
# -------------------------
AS_CASE([$BUBBLEMON_PANEL],
  BUBBLEMON_PANEL_CASE([mate], [libmatepanelapplet-4.0 >= 1.6.0],
    , [/share/mate-panel/applets],
    [APPLET_TYPE="dbus"
     AC_DEFINE_DIR(MATELOCALEDIR, "${datadir}/locale", [locale directory])]),
  BUBBLEMON_PANEL_CASE([gnome3], [libpanelapplet-4.0 >= 3.0.0
                                  gtk+-3.0 >= 3],
    [libpanel_applet_dir], ,
    [APPLET_TYPE="dbus"]),
  BUBBLEMON_PANEL_CASE([xfce4], [libxfce4panel-1.0 >= 4.7.0
                                 libxfce4ui-1 >= 4.7.0],
    , [/share/xfce4/panel/plugins],
    [APPLET_TYPE="plugin"]),
  [AC_MSG_ERROR([Unknown panel type. Use bubblemon_panels_described.])]
)
AS_IF(
  [test x$BUBBLEMON_PANEL = xxfce4],
    [BUBBLEMON_APPLET_DIR=$($PKG_CONFIG --variable=libdir $BUBBLEMON_APPLET_LIB)/xfce4/panel/plugins]
    [BUBBLEMON_APPLET_NAME=bubblemon-plugin]
    ,
  [BUBBLEMON_APPLET_DIR=$($PKG_CONFIG --variable=prefix $BUBBLEMON_APPLET_LIB)/libexec]
  [BUBBLEMON_APPLET_NAME=$BUBBLEMON_PANEL-bubblemon-applet]
)
AC_SUBST([APPLET_TYPE])
AC_SUBST([BUBBLEMON_APPLET_DIR])
AC_SUBST([BUBBLEMON_APPLET_NAME])
AC_SUBST([LIBPANEL_CFLAGS])
AC_SUBST([LIBPANEL_LIBS])
AC_SUBST([LIBPANEL_APPLET_DIR])

# set panel-specific variables for automake.
# -----------------------------------------
AM_CONDITIONAL([GNOME3_BUILD], [test x$BUBBLEMON_PANEL = xgnome3])
AM_CONDITIONAL([MATE_BUILD], [test x$BUBBLEMON_PANEL = xmate])
AM_CONDITIONAL([XFCE4_BUILD], [test x$BUBBLEMON_PANEL = xxfce4])

AM_CONDITIONAL([DBUS_APPLET], [test x$APPLET_TYPE = xdbus])
AM_CONDITIONAL([PLUGIN_APPLET], [test x$APPLET_TYPE = xplugin])

AM_COND_IF([DBUS_APPLET],
           [AM_COND_IF([GNOME3_BUILD],
                       [APPLET_FILETYPE=panel-applet
                        APPLET_SCHEMA_ORG=gnome
                        PANEL_NAME=gnome-panel])
            AM_COND_IF([MATE_BUILD],
                       [APPLET_FILETYPE=mate-panel-applet
                        APPLET_SCHEMA_ORG=mate
                        PANEL_NAME=mate-panel])
            APPLET_TEMPLATE=org.@APPLET_SCHEMA_ORG@.panel.BubblemonApplet.@APPLET_FILETYPE@.in
            DBUS_SERVICE_DIR=`$PKG_CONFIG --variable=session_bus_services_dir dbus-1`
            SERVICE_TEMPLATE=org.@APPLET_SCHEMA_ORG@.panel.applet.BubblemonAppletFactory.service.in
            AC_SUBST([APPLET_FILETYPE])
            AC_SUBST([APPLET_TEMPLATE])
            AC_SUBST([APPLET_SCHEMA_ORG])
            AC_SUBST([DBUS_SERVICE_DIR])
            AC_SUBST([DBUS_PANELAPPLET_RULE])
            AC_SUBST([PANEL_NAME])
            AC_SUBST([SERVICE_TEMPLATE])
])


######################################################################
#
# Output test results
#
#
AS_IF([test "x$GCC" = "xyes"],
  # this causes some autoconf tests to fail if done earlier
  CFLAGS="$CFLAGS -Werror")

AC_CONFIG_FILES([
Makefile
man/bubblemon-applet.1
man/hu/bubblemon-applet.1
man/sv/bubblemon-applet.1
m4/Makefile
po/Makefile.in
])
AC_OUTPUT
