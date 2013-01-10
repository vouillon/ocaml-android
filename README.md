ocaml-android
=============

Ocaml cross-compiler for Android

On a 64bit Debian or Ubuntu installation, you need to install
package `gcc-multilib`.

Follow the following steps to compile:
- download the Android NDK and the OCaml source code;
- edit `Makefile.config`;
- run `make`.

Binaries are put in `$BINDIR`, prefixed by `arm-linux-androideabi-`.
The Android OCaml runtime `ocamlrun` is in directory
`$PREFIX/arm-linux-androideabi/bin/`.
