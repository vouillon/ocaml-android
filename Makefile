
include Makefile.config

# Do not export config variables to sub-make instances.
unexport BINDIR PREFIX

SRC = ocaml-src

ARCH=$(shell uname | tr A-Z a-z)
ANDROID_PATH = $(ANDROID_NDK)/toolchains/arm-linux-androideabi-4.7/prebuilt/$(ARCH)-x86/bin

CORE_OTHER_LIBS = unix str num dynlink

all: stamp-install

stamp-install: stamp-build
# Install the compiler
	cd $(SRC) && make install
# Put links to binaries in $BINDIR
	for i in $(PREFIX)/bin/*; do \
	  ln -sf $$i $(BINDIR)/arm-linux-androideabi-`basename $$i`; \
	done
# Install the Android ocamlrun binary
	mkdir -p $(PREFIX)/arm-linux-androideabi/bin
	cd $(SRC) && \
	cp byterun/ocamlrun.target $(PREFIX)/arm-linux-androideabi/bin/ocamlrun
	touch stamp-install

stamp-build: stamp-runtime
# Restore the ocamlrun binary for the local machine
	cd $(SRC) && cp byterun/ocamlrun.local byterun/ocamlrun
# Compile the libraries for Android
	cd $(SRC) && make coreall opt-core otherlibraries otherlibrariesopt
	cd $(SRC) && make ocamltoolsopt
# Restore file memory.h 
	cd $(SRC) && mv byterun/memry.h byterun/memory.h
	touch stamp-build

stamp-runtime: stamp-prepare
# Recompile the runtime for Android
	cd $(SRC) && make -C byterun all
# Save the ARM ocamlrun binary
	cd $(SRC) && cp byterun/ocamlrun byterun/ocamlrun.target
	touch stamp-runtime

stamp-prepare: stamp-core
# Apply patches
	set -e; for p in patches/*.txt; do \
	(cd $(SRC) && \
	 sed -e 's%ANDROID_NDK%$(ANDROID_NDK)%' \
	     -e 's%ANDROID_PATH%$(ANDROID_PATH)%g' ../$$p | \
	 patch -p 0); \
	done
# Save the ocamlrun binary for the local machine
	cd $(SRC) && cp byterun/ocamlrun byterun/ocamlrun.local
# Clean-up runtime and libraries
	cd $(SRC) && make -C byterun clean
	cd $(SRC) && make -C stdlib clean
	set -e; cd $(SRC) && \
	for i in $(CORE_OTHER_LIBS); do \
	  make -C otherlibs/$$i clean; \
	done
# HACK: we remove memory.h into memry.h to avoid a name clash with
# the Android NDK (stdlib.h includes memory.h).
	cd $(SRC) && mv byterun/memory.h byterun/memry.h
	cd $(SRC) && find asmrun byterun otherlibs -name "*.[ch]" -print | \
	xargs sed -i -e 's/"memory.h"/"memry.h"/' -e 's/<memory.h>/<memry.h>/'
	cd $(SRC) && find . -name ".depend" -print | \
	xargs sed -i -e 's/memory.h/memry.h/'
	touch stamp-prepare

stamp-core: stamp-configure
# Build the bytecode compiler and other core tools
	cd $(SRC) && make OTHERLIBRARIES="$(CORE_OTHER_LIBS)" world
	touch stamp-core

stamp-configure: stamp-copy
# Configuration...
	cd $(SRC) && \
	./configure -prefix $(PREFIX) -host armv5te-unknown-linux-gnueabi \
		-cc "gcc -m32" -as "as --32" -aspp "gcc -m32 -c" \
	 	-no-shared-libs -no-pthread
	touch stamp-configure

stamp-copy:
# Copy the source code
	@if ! [ -d $(OCAML_SRC)/byterun ]; then \
	  echo Error: OCaml sources not found. Check OCAML_SRC variable.; \
	  exit 1; \
	fi
	@if ! [ -d $(ANDROID_PATH) ]; then \
	  echo Error: Android NDK not found. Check ANDROID_NDK variable.; \
	  exit 1; \
	fi
	cp -a $(OCAML_SRC) $(SRC)
	touch stamp-copy

clean:
	rm -rf $(SRC) stamp-*
