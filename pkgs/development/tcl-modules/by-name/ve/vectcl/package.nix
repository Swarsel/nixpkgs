{
  lib,
  fetchFromGitHub,
  mkTclDerivation,
  tcl,
}:

mkTclDerivation rec {
  pname = "vectcl";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "auriocus";
    repo = "VecTcl";
    tag = "v${version}";
    hash = "sha256-nPs16Jy6KMEdupWJNhgYqosuW5Dlpb/dxxTrLpRbYf0=";
  };

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration -std=gnu17";

  meta = {
    description = "Numeric array and linear algebra extension for Tcl";
    homepage = "https://auriocus.github.io/VecTcl/";
    license = lib.licenses.tcltk;
    maintainers = with lib.maintainers; [ fgaz ];
    broken = tcl.isTcl9;
  };
}
