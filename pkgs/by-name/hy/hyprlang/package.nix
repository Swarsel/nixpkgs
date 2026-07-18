{
  lib,
  fetchFromGitHub,
  cmake,
  gcc15Stdenv,
  hyprutils,
  pkg-config,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprlang";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprlang";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZGzcH3gKD9nj8oDLV1+o6ice6kMHZRXkNx24cfyPkRs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    hyprutils
  ];

  doCheck = true;
  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;

  meta = {
    description = "Official implementation library for the hypr config language";
    homepage = "https://github.com/hyprwm/hyprlang";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.hyprland ];
  };
})
