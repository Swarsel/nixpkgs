{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pandoc,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bino3d";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "bino";
    tag = "bino-${finalAttrs.version}";
    hash = "sha256-izgiAmMou/EW5KOzC8HuPaH4uVFLajoDhVwkJkzXdP0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    pandoc
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qttools
    # The optional QVR dependency is not currently packaged.
  ];

  meta = {
    description = "Video player with a focus on 3D and Virtual Reality";
    homepage = "https://bino3d.org/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "bino";
  };
})
