{
  lib,
  fetchFromGitHub,
  cairo,
  cmake,
  gcc15Stdenv,
  hyprlang,
  librsvg,
  libzip,
  nix-update-script,
  pkg-config,
  tomlplusplus,
  xcur2png,
}:
gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprcursor";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprcursor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lIqabfBY7z/OANxHoPeIrDJrFyYy9jAM4GQLzZ2feCM=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cairo
    hyprlang
    librsvg
    libzip
    xcur2png
    tomlplusplus
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hyprland cursor format, library and utilities";
    homepage = "https://github.com/hyprwm/hyprcursor";
    changelog = "https://github.com/hyprwm/hyprcursor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      iynaix
    ];

    platforms = lib.platforms.linux;
    mainProgram = "hyprcursor-util";
    teams = [ lib.teams.hyprland ];
  };
})
