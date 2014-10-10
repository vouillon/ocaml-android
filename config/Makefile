PREFIX=ANDROID_PREFIX
BINDIR=ANDROID_BINDIR/arm-linux-androideabi
LIBDIR=$(PREFIX)/lib/ocaml
STUBLIBDIR=$(LIBDIR)/stublibs
MANDIR=OCAML_SRC/no-man
MANEXT=1
SYSROOT=ANDROID_NDK/platforms/android-14/arch-arm
RANLIB=ANDROID_PATH/arm-linux-androideabi-ranlib
RANLIBCMD=ANDROID_PATH/arm-linux-androideabi-ranlib
ARCMD=ANDROID_PATH/arm-linux-androideabi-ar
SHARPBANGSCRIPTS=true
BNG_ARCH=generic
BNG_ASM_LEVEL=0
PTHREAD_LINK=
X11_INCLUDES=not found
X11_LINK=not found
TK_DEFS=
TK_LINK=
LIBBFD_LINK=-march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-warn-mismatch
BYTECC=ANDROID_PATH/arm-linux-androideabi-gcc --sysroot $(SYSROOT) -I $(PREFIX)/include -L $(PREFIX)/lib -O2
BYTECCCOMPOPTS=-fno-defer-pop -Wall -D_FILE_OFFSET_BITS=64 -march=armv7-a -mfpu=vfpv3-d16 -mhard-float -D_NDK_MATH_NO_SOFTFP=1
BYTECCLINKOPTS= -Wl,-E -march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-warn-mismatch
BYTECCLIBS= -lm_hard  -ldl
BYTECCRPATH=-Wl,-rpath,
EXE=
SUPPORTS_SHARED_LIBRARIES=true
SHAREDCCCOMPOPTS=-fPIC
MKSHAREDLIBRPATH=-Wl,-rpath,
NATDYNLINKOPTS=-Wl,-E
SYSLIB=-l$(1)
#ml let syslib x = "-l"^x;;

### How to build a static library
MKLIB=ANDROID_PATH/arm-linux-androideabi-ar rc $(1) $(2); ANDROID_PATH/arm-linux-androideabi-ranlib $(1)
#ml let mklib out files opts = Printf.sprintf "ANDROID_PATH/arm-linux-androideabi-ar rc %s %s %s; ANDROID_PATH/arm-linux-androideabi-ranlib %s" out opts files out;;
ARCH=arm
MODEL=armv7
SYSTEM=linux_eabihf
NATIVECC=$(BYTECC)
NATIVECCCOMPOPTS=-Wall -D_FILE_OFFSET_BITS=64 -march=armv7-a -mfpu=vfpv3-d16 -mhard-float -D_NDK_MATH_NO_SOFTFP=1
NATIVECCPROFOPTS=$(NATIVECCCOMPOPTS)
NATIVECCLINKOPTS=-march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-warn-mismatch
NATIVECCRPATH=-Wl,-rpath,
NATIVECCLIBS= -lm_hard  -ldl
ASM=ANDROID_PATH/arm-linux-androideabi-as
ASPP=$(BYTECC) -c
ASPPPROFFLAGS=-DPROFILING
PROFILING=prof
DYNLINKOPTS= -ldl
OTHERLIBRARIES=unix str num dynlink bigarray threads
DEBUGGER=ocamldebugger
CC_PROFILE=-pg
SYSTHREAD_SUPPORT=false
PARTIALLD=ld -r
PACKLD=$(PARTIALLD) $(NATIVECCLINKOPTS) -o\ 
DLLCCCOMPOPTS=
IFLEXDIR=
O=o
A=a
SO=so
EXT_OBJ=.o
EXT_ASM=.s
EXT_LIB=.a
EXT_DLL=.so
EXTRALIBS=
CCOMPTYPE=cc
TOOLCHAIN=cc
NATDYNLINK=false
CMXS=cmxa
MKEXE=$(BYTECC) -march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-warn-mismatch
MKEXEDEBUGFLAG=-g
MKDLL=$(BYTECC) -shared -march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-warn-mismatch
MKMAINDLL=$(MKDLL)
RUNTIMED=noruntimed
CAMLP4=
ASM_CFI_SUPPORTED=false
WITH_FRAME_POINTERS=false
