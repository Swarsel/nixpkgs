{
  lib,
  fetchFromGitLab,
  mkKdeDerivation,
  mpv-unwrapped,
  qtbase,
  qtdeclarative,
}:

mkKdeDerivation rec {
  pname = "mpvqt";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "libraries";
    repo = "mpvqt";
    tag = "v${version}";
    hash = "sha256-qscubUiej/OqQI+V9gxQb7eVa3L2FJ5koqgXFoBw8tU=";
    domain = "invent.kde.org";
  };

  extraBuildInputs = [ qtdeclarative ];
  extraCmakeFlags = [ "-DQt6_DIR=${qtbase}/lib/cmake/Qt6" ];
  extraPropagatedBuildInputs = [ mpv-unwrapped ];

  meta.license = with lib.licenses; [
    bsd2
    bsd3
    cc-by-sa-40
    cc0
    lgpl21Only
    lgpl3Only
    lgpl3Plus
    mit
  ];
}
