{ gcc, wrapCC }:
# Use the same GCC version as the one from stdenv by default
wrapCC (
  gcc.cc.override {
    langC = false;
    langCC = false;
    langFortran = true;
    name = "gfortran";
    profiledCompiler = false;
  }
)
