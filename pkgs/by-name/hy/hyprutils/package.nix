{
  lib,
  fetchFromGitHub,
  cmake,
  gcc15Stdenv,
  nix-update-script,
  pixman,
  pkg-config,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprutils";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jAcsogZwWMfXT9MfXxZzkwliAqIuZUV0p71h6Ba9ReE=";
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
    pixman
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Small C++ library for utilities used across the Hypr* ecosystem";
    homepage = "https://github.com/hyprwm/hyprutils";
    changelog = "https://github.com/hyprwm/hyprutils/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ logger ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    teams = [ lib.teams.hyprland ];
  };
})
