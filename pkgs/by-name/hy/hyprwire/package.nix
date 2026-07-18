{
  lib,
  fetchFromGitHub,
  cmake,
  gcc15Stdenv,
  hyprutils,
  libffi,
  pkg-config,
  pugixml,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprwire";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprwire";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AKPaKeLDy0QXRBk/XzR7RktX7CV63ejYsTUgsPdXKvg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    hyprutils
    libffi
    pugixml
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "A fast and consistent wire protocol for IPC ";
    license = lib.licenses.bsd3;
    platforms = with lib.platforms; linux ++ freebsd;
    mainProgram = "hyprwire";
    teams = [ lib.teams.hyprland ];
  };
})
