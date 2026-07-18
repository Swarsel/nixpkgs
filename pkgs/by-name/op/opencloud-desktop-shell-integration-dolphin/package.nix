{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  opencloud-desktop-shell-integration-resources,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencloud-desktop-shell-integration-dolphin";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "opencloud-eu";
    repo = "desktop-shell-integration-dolphin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Bu/kN4RvR/inWQHYcfWOF6BWHTFm5jlea/QeT4NhFQ=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qt6.qtbase
    kdePackages.extra-cmake-modules
    kdePackages.kbookmarks
    kdePackages.kcoreaddons
    kdePackages.kio
    opencloud-desktop-shell-integration-resources
  ];

  dontWrapQtApps = true;

  meta = {
    description = "OpenCloud Desktop shell integration for the great KDE Dolphin in KDE Frameworks 6";
    homepage = "https://github.com/opencloud-eu/desktop-shell-integration-dolphin";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ k900 ];
    platforms = lib.platforms.all;
    mainProgram = "opencloud-desktop-shell-integration-dolphin";
  };
})
