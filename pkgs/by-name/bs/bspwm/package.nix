{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcb,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  libxinerama,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bspwm";
  version = "0.9.12";

  src = fetchFromGitHub {
    owner = "baskerville";
    repo = "bspwm";
    tag = finalAttrs.version;
    hash = "sha256-sEheWAZgKVDCEipQTtDLNfDSA2oho9zU9gK2d6W6WSU=";
  };

  strictDeps = true;

  buildInputs = [
    libxcb
    libxinerama
    libxcb-util
    libxcb-keysyms
    libxcb-wm
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  __structuredAttrs = true;

  passthru.tests = {
    inherit (nixosTests) startx;
  };

  meta = {
    description = "Tiling window manager based on binary space partitioning";
    homepage = "https://github.com/baskerville/bspwm";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      meisternu
      ncfavier
    ];

    platforms = lib.platforms.linux;
  };
})
