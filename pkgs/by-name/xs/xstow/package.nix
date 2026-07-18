{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xstow";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "majorkingleo";
    repo = "xstow";
    tag = finalAttrs.version;
    hash = "sha256-c89+thw5N3Cgl1Ww+W7c3YsyhNJMLlreedvdWJFY3WY=";
    fetchSubmodules = true;
  };

  # Upstream seems to try to support building both static and dynamic version
  # of executable on dynamic systems, but fails with link error when attempting
  # to cross-build "xstow-static" to the system where "xstow" proper is static.
  postPatch = lib.optionalString stdenv.hostPlatform.isStatic ''
    substituteInPlace src/Makefile.am --replace xstow-static ""
    substituteInPlace src/Makefile.am --replace xstow-stow ""
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    ncurses
  ];

  meta = {
    description = "Replacement of GNU Stow written in C++";
    homepage = "https://github.com/majorkingleo/xstow";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ nzbr ];
    platforms = lib.platforms.unix;
  };
})
