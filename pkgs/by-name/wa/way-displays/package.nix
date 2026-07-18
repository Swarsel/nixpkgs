{
  lib,
  stdenv,
  fetchFromGitHub,
  libinput,
  pkg-config,
  wayland,
  wayland-scanner,
  yaml-cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "way-displays";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "alex-courtis";
    repo = "way-displays";
    rev = finalAttrs.version;
    sha256 = "sha256-M1d6o4mODnFNInSt0GL1aCUcRU9VBVhHFQuwTrw6zY4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    yaml-cpp
    libinput
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "PREFIX_ETC=${placeholder "out"}"
    "CC:=$(CC)"
    "CXX:=$(CXX)"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Auto Manage Your Wayland Displays";
    homepage = "https://github.com/alex-courtis/way-displays";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ simoneruffini ];
    platforms = lib.platforms.linux;
    mainProgram = "way-displays";
  };
})
