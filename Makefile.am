# extra distributables defined w/i this directory
SUBDIRS = m4 po

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\"$(localedir)\" \
	-DBUBBLEMON_MENU_UI_DIR=\"$(uidir)\" \
	$(libgtop_CFLAGS) \
	$(LIBPANEL_CFLAGS)

DEFS = -DLOCALEDIR=\"$(localedir)\" @DEFS@

# ---------------------------------------------------------------------

BUBBLEMON_APPLET_DIR = @BUBBLEMON_APPLET_DIR@
BUBBLEMON_APPLET_NAME = @BUBBLEMON_APPLET_NAME@

bubblemondir       = @BUBBLEMON_APPLET_DIR@
# bubblemon_PROGRAMS must be bubblemon-applet so that auto bubblemon_applet
# rules below will work properly. It will be renamed @BUBBLEMON_APPLET_NAME@
# by install-data-hook below.
bubblemon_PROGRAMS = bubblemon-applet

# NB. bubblemon_PROGRAMS does not contain 'exec', run this w/ install-data-hook
bubblemon-rename-PROGRAMS:
	cd $(DESTDIR)@BUBBLEMON_APPLET_DIR@ &&\
	mv -f bubblemon-applet @BUBBLEMON_APPLET_NAME@


# static b/c "configure substitutions are not allowed in _SOURCES variables"
# http://www.gnu.org/software/automake/manual/html_node/Conditional-Sources.html
bubblemon_applet_SOURCES = \
	src/bubblemon.c src/bubblemon.h \
	src/accumulator.c src/accumulator.h \
	src/libgtop2-meter.c src/meter.h \
	src/unix-mail.c src/mail.h
if MATE_BUILD
bubblemon_applet_SOURCES += panel/mate/ui.c panel/mate/ui.h
endif
if GNOME3_BUILD
bubblemon_applet_SOURCES += panel/gnome3/ui.c panel/gnome3/ui.h
endif
if XFCE4_BUILD
bubblemon_applet_SOURCES += panel/xfce4/ui.c panel/xfce4/ui.h
endif
AM_CPPFLAGS += -I$(top_srcdir)/src -I$(top_srcdir)/panel/@BUBBLEMON_PANEL@

bubblemon_applet_LDADD = \
	$(libgtop_LIBS) \
	$(LIBPANEL_LIBS)

# ---------------------------------------------------------------------

PANELFILE_SUBSTS = -e "s|\@APPLET_FILETYPE\@|$(APPLET_FILETYPE)|" \
                   -e "s|\@APPLET_SCHEMA_ORG\@|$(APPLET_SCHEMA_ORG)|" \
                   -e "s|\@BUBBLEMON_APPLET_DIR\@|$(BUBBLEMON_APPLET_DIR)|" \
                   -e "s|\@BUBBLEMON_APPLET_NAME\@|$(BUBBLEMON_APPLET_NAME)|" \
	           -e "s|\@BUBBLEMON_DESCRIPTION\@|$(BUBBLEMON_DESCRIPTION)|" \
	           -e "s|\@BUBBLEMON_FULL_NAME\@|$(BUBBLEMON_FULL_NAME)|"
TEMPLATE_RENAMES = -e "s/\[@]/@/g" $(PANELFILE_SUBSTS) -e "s/\.in$$//"

if DBUS_APPLET
APPLET_PANELFILE = $(shell echo $(APPLET_TEMPLATE) |$(SED) $(TEMPLATE_RENAMES))

appletdir        = @LIBPANEL_APPLET_DIR@
applet_in_files  = $(top_builddir)/panel/dbus/$(APPLET_TEMPLATE)
applet_DATA      = $(top_builddir)/panel/$(APPLET_PANELFILE)

$(applet_in_files): $(applet_in_files:=.in) $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po)
	$(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< $@

$(applet_DATA): $(applet_in_files)
	$(SED) $(PANELFILE_SUBSTS) $< > $@

SERVICE_PANELFILE = $(shell echo $(SERVICE_TEMPLATE) |$(SED) $(TEMPLATE_RENAMES))

servicedir        = @DBUS_SERVICE_DIR@
service_in_files  = $(top_srcdir)/panel/dbus/$(SERVICE_TEMPLATE)
service_DATA      = $(top_builddir)/panel/$(SERVICE_PANELFILE)

$(service_DATA): $(service_in_files)
	$(SED) $(PANELFILE_SUBSTS) $< > $@

uidir = $(pkgdatadir)/ui
dist_ui_DATA = $(top_srcdir)/panel/dbus/bubblemon-menu.xml
endif

# ---------------------------------------------------------------------

if XFCE4_BUILD
desktopdir = @LIBPANEL_APPLET_DIR@
desktop_in_in_files = $(top_srcdir)/panel/xfce4/bubblemon.desktop.in.in
desktop_in_files = $(desktop_in_in_files:.desktop.in.in=.desktop.in)
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

$(desktop_in_files): $(desktop_in_in_files)
	$(SED) $(PANELFILE_SUBSTS) $< > $@

@INTLTOOL_DESKTOP_RULE@
endif

# ---------------------------------------------------------------------

man1_MANS = man/bubblemon-applet.1
man1paths = $(man1dir)

if USE_NLS
man1hudir	= $(mandir)/hu/man1
man1hu_MANS	= man/hu/bubblemon-applet.1
man1svdir	= $(mandir)/sv/man1
man1sv_MANS	= man/sv/bubblemon-applet.1
man1paths += $(man1hudir) $(man1svdir)

# needed for man pages to be installed, automake 1.13.4
man1hu_DATA = $(man1hu_MANS)
man1sv_DATA = $(man1sv_MANS)
endif

bubblemon-rename-MANS:
	for _dir in $(man1paths); do \
	 (cd $(DESTDIR)$$_dir && \
	  mv -f bubblemon-applet.1 @BUBBLEMON_APPLET_NAME@.1); \
	done


iconsdir = $(datadir)/icons
icons = bubblemon.48.png \
        bubblemon.32.png \
        bubblemon.24.png \
        bubblemon.22.png \
        bubblemon.16.png

install-icons:
	for icon in $(icons); do \
		SIZE=`echo $$icon | cut -d. -f2`; \
		FILE=`echo $$icon | cut -d. -f1,3`; \
		if [ "$$SIZE" = "svg" ]; then \
			SIZE="scalable"; \
			FILE="$$FILE.svg"; \
		else \
			SIZE="$${SIZE}x$${SIZE}"; \
		fi; \
		$(MKDIR_P) $(DESTDIR)$(iconsdir)/hicolor/$$SIZE/apps/; \
		$(INSTALL_DATA) $(top_srcdir)/pixmaps/$$icon $(DESTDIR)$(iconsdir)/hicolor/$$SIZE/apps/$$FILE; \
	done

uninstall-icons:
	for icon in $(icons); do \
		SIZE=`echo $$icon | cut -d. -f2`; \
		FILE=`echo $$icon | cut -d. -f1,3`; \
		if [ "$$SIZE" = "svg" ]; then \
			SIZE="scalable"; \
			FILE="$$FILE.svg"; \
		else \
			SIZE="$${SIZE}x$${SIZE}"; \
		fi; \
		rm -f $(DESTDIR)$(iconsdir)/hicolor/$$SIZE/apps/$$FILE; \
	done

gtk_update_icon_cache = gtk-update-icon-cache -q $(iconsdir)/hicolor

update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating Gtk icon cache."; \
		$(gtk_update_icon_cache); \
	else \
		echo "*** Icon cache not updated. After install, run this:"; \
		echo "***   $(gtk_update_icon_cache)"; \
	fi


# ---------------------------------------------------------------------

install-data-hook: bubblemon-rename-PROGRAMS bubblemon-rename-MANS

install-data-local: install-icons update-icon-cache

uninstall-local: uninstall-icons update-icon-cache


EXTRA_DIST = man/bubblemon-applet.1.in man/*/bubblemon-applet.1.in \
	man/hu/bubblemon-applet.1.in man/sv/bubblemon-applet.1.in \
	panel/dbus/*.in panel/dbus/*.xml \
	panel/xfce4/*.in \
	po/Makefile.in src/msgInBottle.c \
	intltool-extract.in intltool-merge.in intltool-update.in \
	pixmaps/*.png \
	FAQ PROFILING README.md TRANSLATIONS config.rpath
DISTCLEANFILES = intltool-extract intltool-merge intltool-update
if DBUS_APPLET
DISTCLEANFILES += \
	$(applet_DATA) \
	$(service_DATA)
endif
if XFCE4_BUILD
DISTCLEANFILES += \
	$(desktop_DATA)
endif

ACLOCAL_AMFLAGS = -I m4
