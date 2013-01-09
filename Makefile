
include Makefile.config

SRC = ocaml

########################################

ARCH=$(shell uname | tr A-Z a-z)
ANDROID_PATH = $(ANDROID_NDK)/toolchains/arm-linux-androideabi-4.7/prebuilt/$(ARCH)-x86/bin

CORE_OTHER_LIBS = unix str num dynlink

all: stamp-build
	cd $(SRC) && make install
	for i in $(PREFIX)/bin/*; do \
	  cp $$i $(BINDIR)/arm-linux-androideabi-`basename $$i`; \
	done

stamp-build: stamp-prepare
	cd $(SRC) && make -C byterun libcamlrun.a ld.conf
	cd $(SRC) && make coreall opt-core otherlibraries otherlibrariesopt
	cd $(SRC) && make ocaml ocamltoolsopt
	cd $(SRC) && mv byterun/memry.h byterun/memory.h
	touch stamp-build

stamp-prepare: stamp-core
	set -e; for p in patches/*.txt; do \
	(cd $(SRC) && \
	 sed -e 's%ANDROID_NDK%$(ANDROID_NDK)%' \
	     -e 's%ANDROID_PATH%$(ANDROID_PATH)%g' ../$$p | \
	 patch -p 0); \
	done
	cd $(SRC) && rm ocaml byterun/*.o
	cd $(SRC) && make -C stdlib clean
	set -e; cd $(SRC) && \
	for i in $(CORE_OTHER_LIBS); do \
	  make -C otherlibs/$$i clean; \
	done
# HACK: we remove memory.h into memry.h to avoid a name clash with
# the Android NDK (stdlib.h includes memory.h).
	cd $(SRC) && mv byterun/memory.h byterun/memry.h
	cd $(SRC) && find . -name "*.[ch]" -print | \
	xargs sed -i -e 's/"memory.h"/"memry.h"/' -e 's/<memory.h>/<memry.h>/'
	cd $(SRC) && find . -name ".depend" -print | \
	xargs sed -i -e 's/memory.h/memry.h/'
	touch stamp-prepare

stamp-configure: stamp-copy
	cd $(SRC) && \
	./configure -prefix $(PREFIX) -host armv5te-unknown-linux-gnueabi \
		-cc "gcc -m32" -as "as --32" -aspp "gcc -m32 -c" \
	 	-no-shared-libs -no-pthread
	touch stamp-configure

stamp-core: stamp-configure
	cd $(SRC) && make OTHERLIBRARIES="$(CORE_OTHER_LIBS)" world
	touch stamp-core

stamp-copy:
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
