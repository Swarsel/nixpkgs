{
  lib,
  fetchFromGitHub,
  cmake,
  gcc15Stdenv,
  hyprland-protocols,
  hyprlang,
  hyprutils,
  hyprwayland-scanner,
  nix-update-script,
  pkg-config,
  sdbus-cpp_2,
  systemdLibs,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hypridle";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hypridle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YzRWE3rCnsY0WDRJcn4KvyWUoe+5zdkUYNIaHGP9BZ4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    hyprwayland-scanner
    wayland-scanner
    hyprland-protocols
    wayland-protocols
  ];

  buildInputs = [
    hyprlang
    hyprutils
    sdbus-cpp_2
    systemdLibs
    wayland
    wayland-protocols
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Hyprland's idle daemon";
    homepage = "https://github.com/hyprwm/hypridle";
    changelog = "https://github.com/hyprwm/hypridle/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "hypridle";
    teams = [ lib.teams.hyprland ];
  };
})
