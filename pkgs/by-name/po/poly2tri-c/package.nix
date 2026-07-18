{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  glib,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poly2tri-c";
  version = "0.1.0";

  src = fetchFromGitLab {
    owner = "jtojnar";
    repo = "poly2tri-c";
    rev = "p2tc-${finalAttrs.version}";
    sha256 = "158vm3wqfxs22b74kqc4prlvjny38qqm3kz5wrgasmx0qciwh0g8";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "--std=gnu99"
    "-Wno-error"
  ];

  meta = {
    description = "Library for generating, refining and rendering 2-Dimensional Constrained Delaunay Triangulations";
    homepage = "https://code.google.com/archive/p/poly2tri-c/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
    mainProgram = "p2tc";
  };
})
