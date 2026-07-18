{ gcc15, wrapCC }:
wrapCC (
  gcc15.cc.override {
    langC = false;
    langCC = false;
    langFortran = true;
    name = "gfortran";
    profiledCompiler = false;
  }
)
