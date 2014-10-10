
include Makefile.config

TOOLCHAIN = $(HOST_ARCH)-4.8
ANDROID_OCAML_ARCH = $(ANDROID_ARCH)
ifeq ($(ABI),armeabi-v7a)
  HOST_ARCH = arm-linux-androideabi
  ANDROID_ARCH = arm
  ANDROID_MODEL = armv7
  ANDROID_SYSTEM = linux_eabihf
else ifeq ($(ABI),armeabi)
  HOST_ARCH = arm-linux-androideabi
  ANDROID_ARCH = arm
  ANDROID_MODEL = armv5te
  ANDROID_SYSTEM = linux_eabi
else ifeq ($(ABI),x86)
  HOST_ARCH = i686-linux-android
  TOOLCHAIN = x86-4.8
  ANDROID_ARCH = x86
  ANDROID_OCAML_ARCH = i386
  ANDROID_MODEL = default
  ANDROID_SYSTEM = linux_elf
else
  $(error Unknown ABI $(ABI))
endif

ifeq ($(ABI),armeabi-v7a)
  ANDROID_CFLAGS = -march=armv7-a -mfpu=vfpv3-d16 -mhard-float \
                   -D_NDK_MATH_NO_SOFTFP=1
  ANDROID_LDFLAGS = -march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-warn-mismatch
  ANDROID_MATHLIB = -lm_hard
else
  ANDROID_CFLAGS =
  ANDROID_LDFLAGS =
  ANDROID_MATHLIB = -lm
endif

SRC = ocaml-src

ARCH=$(shell uname | tr A-Z a-z)
ANDROID_PATH = $(ANDROID_NDK)/toolchains/$(TOOLCHAIN)/prebuilt/$(ARCH)-x86/bin

CORE_OTHER_LIBS = unix str num dynlink
STDLIB=$(shell $(ANDROID_BINDIR)/ocamlc -config | \
               sed -n 's/standard_library: \(.*\)/\1/p')

all: stamp-install

stamp-install: stamp-build
# Install the compiler
	cd $(SRC) && make install
# Put links to binaries in $ANDROID_BINDIR
	rm -f $(ANDROID_BINDIR)/$(HOST_ARCH)/ocamlbuild
	rm -f $(ANDROID_BINDIR)/$(HOST_ARCH)/ocamlbuild.byte
	for i in $(ANDROID_BINDIR)/$(HOST_ARCH)/*; do \
	  ln -sf $$i $(ANDROID_BINDIR)/$(HOST_ARCH)-`basename $$i`; \
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
	      -e 's%HOST_ARCH%$(HOST_ARCH)%g' \
	      -e 's%ANDROID_CFLAGS%$(ANDROID_CFLAGS)%g' \
	      -e 's%ANDROID_LDFLAGS%$(ANDROID_LDFLAGS)%g' \
	      -e 's%ANDROID_MATHLIB%$(ANDROID_MATHLIB)%g' \
	      -e 's%ANDROID_ARCH%$(ANDROID_ARCH)%g' \
	      -e 's%ANDROID_OCAML_ARCH%$(ANDROID_OCAML_ARCH)%g' \
	      -e 's%ANDROID_MODEL%$(ANDROID_MODEL)%g' \
	      -e 's%ANDROID_SYSTEM%$(ANDROID_SYSTEM)%g' \
	      -e 's%ANDROID_PLATFORM%$(ANDROID_PLATFORM)%g' \
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
		-bindir $(ANDROID_BINDIR)/$(HOST_ARCH) \
	        -mandir $(shell pwd)/no-man \
		-cc "gcc -m32" -as "gcc -m32 -c" -aspp "gcc -m32 -c" \
		-no-pthread
	sed -i s/CAMLP4=camlp4/CAMLP4=/ $(SRC)/config/Makefile
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
