# ----------------------
# $Log: Makefile,v $
# Revision 1.6  1999/01/12 20:37:13  turbo
# * Don't make the 'debian' dir, it get's created by 'dh_make'.
# * CAT the old changelog to the 'debian/changelog' file..
# * Don't use hardcoded path to emacs (We shouldn't use emacs
#   specificaly, but $EDITOR or something)..
#
# Revision 1.5  1999/01/12 20:30:46  turbo
# * Copy (!) all the files to '~/src/DEBIAN/xezmlm-VERSION' before
#   beginning the debianization process...
#
# Revision 1.4  1999/01/12 20:00:07  turbo
# * Copy the '.readme' as 'README.Debian'...
#
# Revision 1.3  1998/08/30 23:48:02  turbo
# * Remove all the CVS directories when creating the debian package.
# * Also copy our own changelog to the debian directory, so we can
#   continue building on that one...
# * Tell user to use 'dpkg-buildpackage -rsudo' instead of 'sudo build'.
#
# Revision 1.2  1998/08/23 12:19:51  turbo
# When creating the tar file, remove the directory 'var/', it contains
# the 'virtual FS' (for test purposes).
#
# Revision 1.1  1998/08/02 07:36:51  turbo
# When installing, only install the Perl-TK binary, the Perl-GTK doesn't work.
#
# Revision 1.0.0.1  1998/08/02 06:36:35  turbo
# This is the first revision of the xezmlm mailinglist creator for XWindows.
# It is written usin Perl-TK, with a non working version in Perl-GTK in the
# works.
#
#

PACKAGE=xezmlm
PREFIX_DIR=/usr

# This variable is just here to make the
# Debian package creation happy, messes
# the whole makefile up.. yikes, please
# ignore...
DESTDIR=
PREFIX_DIR=$(DESTDIR)/usr

ifdef DESTDIR
# We should install in '/usr'
BINDIR=/usr/X11R6/bin
MANDIR=/usr/X11R6/man

INSBIN=$(DESTDIR)/usr/X11R6/bin
INSMAN=$(DESTDIR)/usr/X11R6/man
else
# We should install in '/usr/local'
BINDIR=/usr/local/bin/X11
MANDIR=/usr/local/X11R6/man

INSBIN=$(DESTDIR)/usr/local/bin/X11
INSMAN=$(DESTDIR)/usr/local/X11R6/man
endif

SRCDIR=`pwd`
PERL=`which perl`

all:

install:	create_dirs install_bin install_man

commit:		clean remove
	# Save changes done...
	cvs commit .

diff:
	# Make a unified diff over the changes from the last commit...
	cvs diff -uN .

checkout:
	# Get the changes done...
	cd ..; rm -R xezmlm; cvs checkout -kkvl xezmlm

update:
	# Check if there is any changes...
	cd ..; cvs update xezmlm

create_dirs:
	@( \
	  echo "Installing in $(PREFIX_DIR)..."; \
	  echo -n "Creating directories... "; \
	  if [ ! -d $(INSBIN) ]; then mkdir -p $(INSBIN); fi; \
	  echo "done."; \
	)

install_bin:
	# Install the files in its proper place...
	@( \
	echo -n "Copying main binary...  "; \
	install -m 755 xezmlm.ptk $(INSBIN)/xezmlm; \
	echo "done."; \
	)

install_man:
	@( \
	  if [ ! -d $(INSMAN)/man1 ]; then \
	    mkdir $(INSMAN)/man1; \
	  fi; \
	  for file in `find -name '*.1x' -type f -maxdepth 1`; do \
	    install -m 644 $$file $(INSMAN)/man1; \
	  done; \
	) 

uninstall:
	# Uninstall all files installed...
	@( \
	if [ -x $(INSBIN)/xezmlm ]; then \
		echo -n "Removing main binary... "; \
		rm $(INSBIN)/xezmlm; \
	fi; \
	)

debian:		rtag clean
	# Make a debian package of the source tree...
	@( \
	VERSION=`cat .version`; \
	mkdir -p $$HOME/src/DEBIAN/xezmlm-$$VERSION; \
	find | cpio -p $$HOME/src/DEBIAN/xezmlm-$$VERSION; \
	cd $$HOME/src/DEBIAN/xezmlm-$$VERSION; \
	echo "Removing crappy files... "; \
	echo "  (Errors like \`No such file or directory' is expected)"; \
	find -type d -name CVS -exec rm -Rf {} \;; \
	dh_make; \
	cat changelog >> debian/changelog; \
	cd debian; \
	echo "Changing and removing some files in the debian directory..."; \
	rm *.ex; \
	cat ../.copyright >> copyright; \
	cp ../.readme   README.Debian; \
	cp ../.dirs     dirs; \
	cp ../.control  control; \
	cp ../.menu     menu; \
	cp ../.rules    rules; \
	emacs -nw control copyright; \
	echo; \
	echo "Now type \`cd $$HOME/src/DEBIAN/xezmlm-$$VERSION && dpkg-buildpackage -rsudo'";\
	echo "and the package will be made..."; \
	echo; \
	)

newversion:
	@( \
	VERSION=`cat .version`; \
	MAJOR=`expr substr $$VERSION 1 1`; \
	MINOR=`expr substr $$VERSION 3 1`; \
	LEVEL=`expr substr $$VERSION 5 1`; \
	LEVEL=`expr $$LEVEL + 1`; \
	echo "$$MAJOR.$$MINOR.$$LEVEL" > .version; \
	echo "We are at now version: $$MAJOR.$$MINOR.$$LEVEL"; \
	)

rtag:
	@( \
	  cp .version .version.old; \
	  VERSION=`cat .version`; \
	  MAJOR=`expr substr $$VERSION 1 1`; \
	  MINOR=`expr substr $$VERSION 3 1`; \
	  LEVEL=`expr substr $$VERSION 5 2`; \
	  NEWLV=`expr $$LEVEL + 1`; \
	  echo "$$MAJOR.$$MINOR.$$NEWLV" > .version; \
	  echo -n "We are now at version "; \
	  cat  < .version; \
	  TAG="`echo $(PACKAGE)`_`echo $$MAJOR`_`echo $$MINOR`_`echo $$LEVEL`"; \
	  echo cvs rtag: $$TAG; \
	  cvs rtag -RF $$TAG $(PACKAGE); \
	  cvs commit .version .version.old; \
	)

rdiff:
	@( \
	VERSION=`cat .version.old`; \
	MAJOR=`expr substr $$VERSION 1 1`; \
	MINOR=`expr substr $$VERSION 3 1`; \
	LEVEL=`expr substr $$VERSION 5 3`; \
	TAG="`echo xezmlm`_`echo $$MAJOR`_`echo $$MINOR`_`echo $$LEVEL`"; \
	echo "Makeing a unified diff over the changes from the last version ($$MAJOR.$$MINOR.$$LEVEL)..."; \
	cvs rdiff -ur $$TAG xezmlm; \
	)

clean:		
	# Remove all crappy files that my lay around...
	find . -name '*~'       -type f -exec rm -f {} \;
	find . -name '.*~'      -type f -exec rm -f {} \;
	find . -name '#*#'      -type f -exec rm -f {} \;
	find . -name 'core'     -type f -exec rm -f {} \;
	find . -name '*strace*' -type f -exec rm -f {} \;
	find . -name '*.bak'    -type f -exec rm -f {} \;
	find . -name '*.new'    -type f -exec rm -f {} \;
	find . -name '*.orig'   -type f -exec rm -f {} \;
	find . -name '*.o'      -type f -exec rm -f {} \;

char:
	# Archive the source tree...
	@( \
	mkdir /tmp/xezmlm; \
	echo -n "Copying files... "; \
	find | cpio -p /tmp/xezmlm; \
	cd /tmp/xezmlm; \
	echo "Removing crappy files... "; \
	echo "  (Errors like \`No such file or directory' is expected)"; \
	find -type d -name CVS -exec rm -Rf {} \;; \
	find -type f -name '*.org' -exec rm -Rf {} \;; \
	rm -Rf temp out* how_to_* var; \
	cd ..; \
	echo -n "Creating archive... "; \
	tar czf xezmlm-`date +%y%m%d`.tgz xezmlm; \
	echo "done."; \
	)

#cvs-create:	clean remove
#	cvs import -b 1.0.0 /usr/lib/cvs/root/xezmlm xezmlm xezmlm
#	cd ..; rm -R xezmlm; cvs checkout -kkvl xezmlm
