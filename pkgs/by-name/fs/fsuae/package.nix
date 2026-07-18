{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  autoreconfHook,
  freetype,
  gettext,
  glib,
  gtk2,
  libGL,
  libGLU,
  libmpeg2,
  lua,
  nix-update-script,
  openal,
  pkg-config,
  strip-nondeterminism,
  zip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fs-uae";
  version = "3.2.35";

  src = fetchFromGitHub {
    owner = "FrodeSolheim";
    repo = "fs-uae";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e+Q+PC6Kpq3OBKsgoRvmu2p9dQfJeRCdFO1agXIGcU8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    strip-nondeterminism
    zip
  ];

  buildInputs = [
    SDL2
    freetype
    gettext
    glib
    gtk2
    libGL
    libGLU
    libmpeg2
    lua
    openal
    zlib
  ];

  # Make sure that the build timestamp is not included in the archive
  postFixup = ''
    strip-nondeterminism --type zip $out/share/fs-uae/fs-uae.dat
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Accurate, customizable Amiga Emulator";

    longDescription = ''
      FS-UAE integrates the most accurate Amiga emulation code available from
      WinUAE. FS-UAE emulates A500, A500+, A600, A1200, A1000, A3000 and A4000
      models, but you can tweak the hardware configuration and create customized
      Amigas.
    '';

    homepage = "https://fs-uae.net";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      c4patino
    ];

    platforms = with lib.systems.inspect; patternLogicalAnd patterns.isx86 patterns.isLinux;
    mainProgram = "fs-uae";
  };
})
