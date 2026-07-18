{
  lib,
  stdenv,
  buildPackages,
  cmake,
  fetchFromGitea,
  kdePackages,
  qt6,
  toml11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "budgie-desktop-services";
  version = "1.0.2";

  src = fetchFromGitea {
    owner = "BuddiesOfBudgie";
    repo = "budgie-desktop-services";
    tag = finalAttrs.version;
    hash = "sha256-YOa2pUePp33d1xKF7HrBX2EkjEQsRmzoiJMq72fl3CE=";
    domain = "forge.moderndesktop.dev";
  };

  postPatch = ''
    substituteInPlace cmake/ECMFindModuleHelpersStub.cmake --replace-fail \
      '/usr/share/ECM/modules//ECMFindModuleHelpers.cmake' \
      '${buildPackages.kdePackages.extra-cmake-modules}/share/ECM/modules/ECMFindModuleHelpers.cmake'
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.kwayland
    qt6.qtbase
    toml11
  ];

  meta = {
    description = "Future central hub and orchestrator for Budgie Desktop";
    homepage = "https://forge.moderndesktop.dev/BuddiesOfBudgie/budgie-desktop-services";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "org.buddiesofbudgie.Services";
    teams = [ lib.teams.budgie ];
  };
})
