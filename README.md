ocaml-android
=============

Ocaml cross-compiler for Android.

Currently, only Linux is supported, but it should not be too difficult
to make it run under Mac OS X (contributions are welcome).

On a 64bit Debian or Ubuntu installation, you need to install package
`gcc-multilib`: we have to use 32 bit OCaml binaries when targeting
32 bit architectures.

Follow the following steps to compile:
- download the Android NDK and the OCaml source code;
- edit `Makefile.config`;
- run `make`.

For convenience, binaries (`ocamlc`, `ocamlopt`, ...) are put both in
   `$ANDROID_BINDIR`
prefixed by `arm-linux-androideabi-`, and in
   `$ANDROID_BINDIR/arm-linux-androideabi`
unprefixed.
The Android OCaml runtime `ocamlrun` is in directory
   `$ANDROID_PREFIX/bin/`.

There are a few pitfalls regarding bytecode programs.  First, if you
link them without the `-custom` directive, you will need to use
`ocamlrun` explicitly to run them. Second, the `ocamlmklib` command
produces shared libraries `dll*.so` which are not usable. Thus, you
need to use the `-custom` directive to successfully link bytecode
programs that uses libraries with mixed C / OCaml code. Shared
libraries should eventually be disabled, but at the moment, the
`ocamlbuild` plugin of `oasis` requires them to be created.

Many thanks to Keigo Imai for its OCaml 3.12 cross-compiler patches.
