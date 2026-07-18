{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  itstool,
  kdePackages,
  libsForQt5,
  libxtst,
  pkg-config,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "antimicrox";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "AntiMicroX";
    repo = "antimicrox";
    rev = finalAttrs.version;
    sha256 = "sha256-ZIHhgyOpabWkdFZoha/Hj/1d8/b6qVolE6dn0xAFZVw=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
        --replace "/usr/lib/udev/rules.d/" "$out/lib/udev/rules.d/"
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    itstool
    udevCheckHook
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    SDL2
    libsForQt5.qttools
    libxtst
  ];

  doInstallCheck = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "GUI for mapping keyboard and mouse controls to a gamepad";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "antimicrox";
  };
})
