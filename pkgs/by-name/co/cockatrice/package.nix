{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  protobuf_21,
  qt5,
}:
let
  protobuf = protobuf_21;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cockatrice";
  version = "2026-02-22-Release-2.10.3";

  src = fetchFromGitHub {
    owner = "Cockatrice";
    repo = "Cockatrice";
    rev = finalAttrs.version;
    sha256 = "sha256-GQVdn6vUW0B9vSk7ZvSDqMNhLNe86C+/gE1n6wfQIMw=";
  };

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtmultimedia
    protobuf
    qt5.qttools
    qt5.qtwebsockets
  ];

  meta = {
    description = "Cross-platform virtual tabletop for multiplayer card games";
    homepage = "https://github.com/Cockatrice/Cockatrice";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ evanjs ];
    platforms = with lib.platforms; linux;
  };
})
