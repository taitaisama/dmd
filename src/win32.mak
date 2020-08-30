#_ win32.mak
#
# Copyright (C) 1999-2019 by The D Language Foundation, All Rights Reserved
# written by Walter Bright
# http://www.digitalmars.com
# Distributed under the Boost Software License, Version 1.0.
# http://www.boost.org/LICENSE_1_0.txt
# https://github.com/dlang/dmd/blob/master/src/win32.mak
#
# Dependencies:
#
# Digital Mars C++ toolset
#   http://www.digitalmars.com/download/freecompiler.html
#
# win32.mak (this file) - requires Digital Mars Make ($DM_HOME\dm\bin\make.exe)
#   http://www.digitalmars.com/ctg/make.html
#
# Configuration:
#
# The easiest and recommended way to configure this makefile is to add
# $DM_HOME\dm\bin to your PATH environment to automatically find make.
# Set HOST_DC to point to your installed D compiler.
#
# Targets:
#
# defaulttarget - debug dmd
# release       - release dmd (with clean)
# trace         - release dmd with tracing options enabled
# clean         - delete all generated files except target binary
# install       - copy build targets to install directory
# install-clean - delete all files in the install directory
# zip           - create ZIP archive of source code
#
# dmd           - release dmd (legacy target)
# debdmd        - debug dmd
# reldmd        - release dmd

############################### Configuration ################################

# fixed model for win32.mak, overridden by win64.mak
MODEL=32
BUILD=release
OS=windows

##### Directories

# DMD source directories
D=dmd

# Generated files directory
GEN = ..\generated
G = $(GEN)\$(OS)\$(BUILD)\$(MODEL)

##### Tools

# Make program
MAKE=make
# Delete file(s)
DEL=del
# Remove directory
RD=rmdir

##### User configuration switches

# Target name
TARGET=$G\dmd
TARGETEXE=$(TARGET).exe

# Recursive make
DMDMAKE=$(MAKE) -fwin32.mak MAKE="$(MAKE)" HOST_DC="$(HOST_DC)" MODEL=$(MODEL) CC="$(CC)" VERBOSE=$(VERBOSE)

############################### Rule Variables ###############################

RUN_BUILD=$(GEN)\build.exe --called-from-make "OS=$(OS)" "BUILD=$(BUILD)" "MODEL=$(MODEL)" "HOST_DMD=$(HOST_DMD)" "HOST_DC=$(HOST_DC)" "MAKE=$(MAKE)" "VERBOSE=$(VERBOSE)" "ENABLE_RELEASE=$(ENABLE_RELEASE)" "ENABLE_DEBUG=$(ENABLE_DEBUG)" "ENABLE_ASSERTS=$(ENABLE_ASSERTS)" "ENABLE_UNITTEST=$(ENABLE_UNITTEST)" "ENABLE_PROFILE=$(ENABLE_PROFILE)" "ENABLE_COVERAGE=$(ENABLE_COVERAGE)" "DFLAGS=$(DFLAGS)"

############################## Release Targets ###############################

defaulttarget: $G debdmd

# FIXME: Windows test suite uses src/dmd.exe instead of $(GENERATED)/dmd.exe
auto-tester-build: $(GEN)\build.exe
	echo "Windows builds have been disabled"
	#$(RUN_BUILD) "ENABLE_RELEASE=1" "ENABLE_ASSERTS=1" $@
	#copy $(TARGETEXE) .

dmd: $G reldmd

$(GEN)\build.exe: build.d $(HOST_DMD_PATH)
	$(HOST_DC) -m$(MODEL) -of$@ -g build.d

release:
	$(DMDMAKE) clean
	$(DEL) $(TARGETEXE)
	$(DMDMAKE) reldmd
	$(DMDMAKE) clean

$G :
	if not exist "$G" mkdir $G

check-host-dc:
	@cmd /c if "$(HOST_DC)" == "" (echo Error: Environment variable HOST_DC is not set & exit 1)

debdmd: check-host-dc debdmd-make

debdmd-make:
	$(DMDMAKE) "ENABLE_DEBUG=1" "ENABLE_UNITTEST=1" $(TARGETEXE)

reldmd: check-host-dc reldmd-make

reldmd-make: $(GEN)\build.exe
	$(RUN_BUILD) "ENABLE_RELEASE=1" $(TARGETEXE)

reldmd-asserts: check-host-dc reldmd-asserts-make

reldmd-asserts-make: $(GEN)\build.exe
	$(RUN_BUILD) "ENABLE_RELEASE=1" "ENABLE_ASSERTS=1" $(TARGETEXE)

# Don't use ENABLE_RELEASE=1 to avoid -inline
profile:
	$(DMDMAKE) "ENABLE_PROFILE=1" "DFLAGS=-O -release" $(TARGETEXE)

trace: debdmd-make

unittest:
	$(DMDMAKE) "ENABLE_DEBUG=1" "ENABLE_UNITTEST=1" "ENABLE_COVERAGE=1" $(TARGETEXE)

################################ Libraries ##################################

$(TARGETEXE): $(GEN)\build.exe
	$(RUN_BUILD) $@
	copy $(TARGETEXE) .

############################ Maintenance Targets #############################

clean:
	$(RD) /s /q $(GEN)
	$(DEL) $D\msgs.h $D\msgs.c
	$(DEL) $(TARGETEXE) *.map *.obj *.exe

install: detab install-copy

install-copy: $(GEN)\build.exe
	$(RUN_BUILD) $@

install-clean:
	$(DEL) /s/q $(INSTALL)\*
	$(RD) /s/q $(INSTALL)

detab: $(GEN)\build.exe
	$(RUN_BUILD) $@

tolf: $(GEN)\build.exe
	$(RUN_BUILD) $@

zip: detab tolf $(GEN)\build.exe
	$(RUN_BUILD) $@

checkwhitespace: $(GEN)\build.exe
	$(RUN_BUILD) $@

######################################################

..\changelog.html: ..\changelog.dd
	$(HOST_DC) -Df$@ $<

############################## Generated Source ##############################

$G\VERSION : ..\VERSION $G
	copy ..\VERSION $@
