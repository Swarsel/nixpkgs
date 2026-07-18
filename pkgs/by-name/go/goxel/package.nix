{
  lib,
  stdenv,
  fetchFromGitHub,
  glfw3,
  gtk3,
  libpng,
  pkg-config,
  scons,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goxel";
  version = "0.15.1-unstable-2024-12-27";

  src = fetchFromGitHub {
    owner = "guillaumechereau";
    repo = "goxel";
    rev = "60ec064a144295b17dfece85bb778dad19eaa8dc";
    hash = "sha256-H5ErFfYsGmU2KsWJyUoozlrpf/JhgFimMxyFHt+czdg=";
  };

  nativeBuildInputs = [
    scons
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glfw3
    gtk3
    libpng
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  buildFlags = [ "release" ];
  dontUseSconsBuild = true;
  dontUseSconsInstall = true;

  meta = {
    description = "Open Source 3D voxel editor";
    homepage = "https://guillaumechereau.github.io/goxel/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      tilpner
      fgaz
    ];

    platforms = lib.platforms.linux;
    mainProgram = "goxel";
  };
})
