{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "krunner-vscodeprojects";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "alex1701c";
    repo = "krunner-vscodeprojects";
    rev = finalAttrs.version;
    hash = "sha256-a24MFSXYFR4VVUVMOAY0n0sKqY0L9lUhnpgSeDFtceI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  buildInputs = with kdePackages; [
    ki18n
    krunner
    kconfig
  ];

  cmakeFlags = [
    "-DBUILD_WITH_QT6=ON"
    "-DQT_MAJOR_VERSION=6"
  ];

  dontWrapQtApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (kdePackages.krunner.meta) platforms;
    description = "Krunner Plugin which allows you to open your VSCode Project Manager projects";
    homepage = "https://github.com/alex1701c/krunner-vscodeprojects";
    license = lib.licenses.lgpl3Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ js6pak ];
  };
})
