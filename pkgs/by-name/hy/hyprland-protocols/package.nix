{
  lib,
  fetchFromGitHub,
  gcc15Stdenv,
  meson,
  ninja,
}:
gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprland-protocols";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-protocols";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+KEVnKBe8wz+a6dTLq8YDcF3UrhQElwsYJaVaHXJtoI=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = {
    description = "Wayland protocol extensions for Hyprland";
    homepage = "https://github.com/hyprwm/hyprland-protocols";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.hyprland ];
  };
})
