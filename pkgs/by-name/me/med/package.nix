{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  jsoncpp,
  pkg-config,
  qt6,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "med";
  version = "3.10.1";

  src = fetchFromGitHub {
    owner = "allencch";
    repo = "med";
    rev = finalAttrs.version;
    hash = "sha256-m2lVRSNaklB0Xfqgtyc0lNWXfTD8wTWsE06eGv4FOBE=";
  };

  postPatch = ''
    find . -type f -exec sed -i "s|/opt/med|$out/share/med|g" {} +
  '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    cmake
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    qt6.qtwayland
    jsoncpp
    readline
  ];

  meta = {
    description = "GUI game memory scanner and editor";
    homepage = "https://github.com/allencch/med";
    changelog = "https://github.com/allencch/med/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zebreus ];
    platforms = lib.platforms.linux;
    mainProgram = "med";
  };
})
