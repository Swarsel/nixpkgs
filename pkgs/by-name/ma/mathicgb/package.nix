{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtest,
  mathic,
  memtailor,
  onetbb,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mathicgb";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "Macaulay2";
    repo = "mathicgb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-34ASkRPNH6d8TSJmyZmYZVOi1p02nHgMVXXWVJMNZ1c=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config # clears up bad behavior of autoconf
  ];

  buildInputs = [
    mathic
    memtailor
    onetbb
  ];

  configureFlags = [
    (lib.withFeature finalAttrs.doCheck "gtest")
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Program for computing Groebner basis and signature Grobner bases";

    longDescription = ''
      Mathicgb is a program for computing Groebner basis and signature Grobner
      bases. Mathicgb is based on the fast data structures from mathic.
    '';

    homepage = "https://github.com/Macaulay2/mathicgb";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ coolcuber ];
    platforms = lib.platforms.unix;
    mainProgram = "mgb";
  };
})
