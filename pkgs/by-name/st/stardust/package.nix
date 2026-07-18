{
  lib,
  stdenv,
  fetchurl,
  libGL,
  libGLU,
  libtiff,
  libx11,
  libxext,
  libxi,
  libxml2,
  libxmu,
  sdl12-compat,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stardust";
  version = "0.1.13";

  src = fetchurl {
    url = "http://iwar.free.fr/spip/IMG/gz/stardust-${finalAttrs.version}.tar.gz";
    hash = "sha256-t5cykB5zHYYj4tlk9QDhL7YQVgEScBZw9OIVXz5NOqc=";
  };

  patches = [ ./pointer-fix.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    sdl12-compat
    libxml2
  ];

  buildInputs = [
    zlib
    libtiff
    libxml2
    sdl12-compat
    libx11
    libxi
    libxmu
    libxext
    libGLU
    libGL
  ];

  postConfigure = ''
    substituteInPlace config.h \
      --replace-fail '#define PACKAGE ""' '#define PACKAGE "stardust"'
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];
  installFlags = [ "bindir=${placeholder "out"}/bin" ];

  meta = {
    description = "Space flight simulator";
    homepage = "http://iwar.free.fr/spip/rubrique2.html";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
      marcin-serwin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "stardust";
  };
})
