{ gcc16, wrapCC }:
wrapCC (
  gcc16.cc.override {
    langC = false;
    langCC = false;
    langFortran = true;
    name = "gfortran";
    profiledCompiler = false;
  }
)
