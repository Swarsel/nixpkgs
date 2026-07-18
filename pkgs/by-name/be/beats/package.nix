{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beats";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "j0hax";
    repo = "beats";
    rev = "v${finalAttrs.version}";
    sha256 = "1rdvsqrjpily74y8vwch711401585xckb4p41cfwrmj6vf44jhif";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "CC=cc"
  ];

  meta = {
    description = "Swatch Internet Time implemented as a C program";
    homepage = "https://github.com/j0hax/beats";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.j0hax ];
    platforms = lib.platforms.all;
    mainProgram = "beats";
  };
})
