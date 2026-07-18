{
  lib,
  fetchFromGitHub,
  cmake,
  gcc15Stdenv,
  nix-update-script,
  pkg-config,
  pugixml,
}:
gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprwayland-scanner";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprwayland-scanner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Jxixw6wZphUp+nHYxOKUYSckL17QMBx2d5Zp0rJHr1g=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    pugixml
  ];

  doCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hyprland version of wayland-scanner in and for C++";
    homepage = "https://github.com/hyprwm/hyprwayland-scanner";
    changelog = "https://github.com/hyprwm/hyprwayland-scanner/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "hyprwayland-scanner";
    teams = [ lib.teams.hyprland ];
  };
})
