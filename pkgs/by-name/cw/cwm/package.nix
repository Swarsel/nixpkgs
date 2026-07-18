{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  libx11,
  libxft,
  libxinerama,
  libxrandr,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "cwm";
  version = "7.9";

  src = fetchFromGitHub {
    owner = "leahneukirchen";
    repo = "cwm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YC+x4YSPAgZ47PFMbzICv9ixfDxA1PG3ncLiMahSoUc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    bison
  ];

  buildInputs = [
    libx11
    libxinerama
    libxrandr
    libxft
  ];

  __structuredAttrs = true;
  prePatch = ''sed -i "s@/usr/local@$out@" Makefile'';

  meta = {
    description = "Lightweight and efficient window manager for X11";
    homepage = "https://github.com/leahneukirchen/cwm";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      _0x4A6F
      iamanaws
    ];

    platforms = lib.platforms.linux;
    mainProgram = "cwm";
  };
})
