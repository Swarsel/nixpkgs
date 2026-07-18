{ gcc14, wrapCC }:
wrapCC (
  gcc14.cc.override {
    langC = false;
    langCC = false;
    langFortran = true;
    name = "gfortran";
    profiledCompiler = false;
  }
)
