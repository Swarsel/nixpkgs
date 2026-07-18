{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jetbrains-runner";
  version = "3.0.7";

  src = fetchFromGitHub {
    owner = "alex1701c";
    repo = "JetBrainsRunner";
    tag = finalAttrs.version;
    hash = "sha256-TaueSAxGiKiPVT26DSy1mzwsw2vBUK3D//vtOLtw2KQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  buildInputs = with kdePackages; [
    ki18n
    kservice
    krunner
    ktextwidgets
    kio
    kcmutils
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_WITH_QT6=ON"
    "-DQT_MAJOR_VERSION=6"
  ];

  dontWrapQtApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (kdePackages.krunner.meta) platforms;
    description = "Krunner Plugin which allows you to open your recent JetBrains projects";
    homepage = "https://github.com/alex1701c/JetBrainsRunner";
    license = lib.licenses.lgpl3Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ js6pak ];
  };
})
