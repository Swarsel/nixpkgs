{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  fetchpatch,
  libxcb,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sxhkd";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "baskerville";
    repo = "sxhkd";
    rev = finalAttrs.version;
    hash = "sha256-kbjbTzYL2dz/RpG+SgBYy+XS3W9PBEWkg6ocqAFG3VQ=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
  ];

  buildInputs = [
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  passthru.tests = {
    inherit (nixosTests) startx;
  };

  meta = {
    inherit (libxcb.meta) platforms;
    description = "Simple X hotkey daemon";
    homepage = "https://github.com/baskerville/sxhkd";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      ncfavier
    ];

    mainProgram = "sxhkd";
  };
})
