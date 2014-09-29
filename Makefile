
include Makefile.config

SRC = ocaml-src

ARCH=$(shell uname | tr A-Z a-z)
ANDROID_PATH = $(ANDROID_NDK)/toolchains/arm-linux-androideabi-4.8/prebuilt/$(ARCH)-x86/bin

CORE_OTHER_LIBS = unix str num dynlink
STDLIB=$(shell $(ANDROID_BINDIR)/ocamlc -config | \
               sed -n 's/standard_library: \(.*\)/\1/p')

all: stamp-install

stamp-install: stamp-build
# Install the compiler
	cd $(SRC) && make install
# Put links to binaries in $ANDROID_BINDIR
	for i in $(ANDROID_BINDIR)/arm-linux-androideabi/*; do \
	  ln -sf $$i $(ANDROID_BINDIR)/arm-linux-androideabi-`basename $$i`; \
	done
# Install the Android ocamlrun binary
	mkdir -p $(ANDROID_PREFIX)/bin
	cd $(SRC) && \
	cp byterun/ocamlrun.target $(ANDROID_PREFIX)/bin/ocamlrun
# Add a link to camlp4 libraries
	rm -rf $(ANDROID_PREFIX)/lib/ocaml/camlp4
	ln -sf $(STDLIB)/camlp4 $(ANDROID_PREFIX)/lib/ocaml/camlp4
	touch stamp-install

stamp-build: stamp-runtime
# Restore the ocamlrun binary for the local machine
	cd $(SRC) && cp byterun/ocamlrun.local byterun/ocamlrun
# Compile the libraries for Android
	cd $(SRC) && make coreall opt-core otherlibraries otherlibrariesopt
	cd $(SRC) && make ocamltoolsopt
	touch stamp-build

stamp-runtime: stamp-prepare
# Recompile the runtime for Android
	cd $(SRC) && make -C byterun all
# Save the ARM ocamlrun binary
	cd $(SRC) && cp byterun/ocamlrun byterun/ocamlrun.target
	touch stamp-runtime

stamp-prepare: stamp-core
# Update configuration files
	set -e; cd config; for f in *; do \
	  sed -e 's%ANDROID_NDK%$(ANDROID_NDK)%' \
	      -e 's%ANDROID_PATH%$(ANDROID_PATH)%g' \
	      -e 's%ANDROID_PREFIX%$(ANDROID_PREFIX)%g' \
	      -e 's%ANDROID_BINDIR%$(ANDROID_BINDIR)%g' \
	      -e 's%OCAML_SRC%$(OCAML_SRC)%g' \
	      $$f > ../$(SRC)/config/$$f; \
	done
# Apply patches
	set -e; for p in patches/*.txt; do \
	(cd $(SRC) && patch -p 0 < ../$$p); \
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
	touch stamp-prepare

stamp-core: stamp-configure
# Build the bytecode compiler and other core tools
	cd $(SRC) && \
	make OTHERLIBRARIES="$(CORE_OTHER_LIBS)" BNG_ASM_LEVEL=0 world
	touch stamp-core

stamp-configure: stamp-copy
# Configuration...
	cd $(SRC) && \
	./configure -prefix $(ANDROID_PREFIX) \
		-bindir $(ANDROID_BINDIR)/arm-linux-androideabi \
	        -mandir $(shell pwd)/no-man \
		-cc "gcc -m32" -as "gcc -m32" -aspp "gcc -m32 -c" \
	 	-no-pthread
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
	@if ! [ -f $(ANDROID_BINDIR)/ocamlc ]; then \
	  echo Error: $(ANDROID_BINDIR)/ocamlc not found. \
	    Check ANDROID_BINDIR variable.; \
	  exit 1; \
	fi
	cp -a $(OCAML_SRC) $(SRC)
	touch stamp-copy

clean:
	rm -rf $(SRC) stamp-*
