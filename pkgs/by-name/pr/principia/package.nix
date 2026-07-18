{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  freetype,
  gtk3,
  libGL,
  libjpeg,
  libpng,
  pkg-config,
  sdl3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "principia";
  version = "2026.07.09";

  src = fetchFromGitHub {
    owner = "Bithack";
    repo = "principia";
    tag = finalAttrs.version;
    hash = "sha256-DlAhlbJjVCWpcwa6WDRU3Vms3AgDZdjZjBuBy9MOPh4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    curl
    freetype
    gtk3
    libGL
    libjpeg
    libpng
    sdl3
  ];

  cmakeFlags = [
    # Remove when https://github.com/NixOS/nixpkgs/issues/144170 is fixed
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
  ];

  meta = {
    description = "Physics-based sandbox game";
    homepage = "https://principia-web.se/";

    changelog = "https://principia-web.se/wiki/Changelog#${
      lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }";

    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.fgaz ];
    platforms = lib.platforms.linux;
    mainProgram = "principia";
    downloadPage = "https://principia-web.se/download";
  };
})
