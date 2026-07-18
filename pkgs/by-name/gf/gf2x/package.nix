{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  buildPackages,
  fetchpatch,
  optimize ? false, # impure hardware optimizations
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gf2x";
  version = "1.3.0";

  src = fetchFromGitLab {
    owner = "gf2x";
    repo = "gf2x";
    rev = "gf2x-${finalAttrs.version}";
    sha256 = "04g5jg0i4vz46b4w2dvbmahwzi3k6b8g515mfw7im1inc78s14id";
    domain = "gitlab.inria.fr";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-Aj2KzWZMR24S04IbPOBPwacCU4rEiB+FFWxtRuF50LA=";
      name = "gf2x-1.3.0-configure-clang16.patch";
      url = "https://gitlab.inria.fr/gf2x/gf2x/-/commit/a2f0fd388c12ca0b9f4525c6cfbc515418dcbaf8.diff";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = lib.optionals (!optimize) [
    "--disable-hardware-specific-code"
  ];

  # no actual checks present yet (as of 1.2), but can't hurt trying
  # for an indirect test, run ntl's test suite
  doCheck = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    description = "Routines for fast arithmetic in GF(2)[x]";
    homepage = "https://gitlab.inria.fr/gf2x/gf2x/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.sage ];
  };
})
