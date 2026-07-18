{ gcc13, wrapCC }:
wrapCC (
  gcc13.cc.override {
    langC = false;
    langCC = false;
    langFortran = true;
    name = "gfortran";
    profiledCompiler = false;
  }
)
