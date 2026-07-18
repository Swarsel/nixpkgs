{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  grim,
  hyprland,
  hyprland-protocols,
  hyprlang,
  hyprutils,
  hyprwayland-scanner,
  libdrm,
  libgbm,
  makeWrapper,
  nix-update-script,
  pipewire,
  pkg-config,
  qtbase,
  qttools,
  qtwayland,
  sdbus-cpp_2,
  slurp,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wrapQtAppsHook,
  debug ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-hyprland";
  version = "1.3.12";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "xdg-desktop-portal-hyprland";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B7nwX0PE0KBo1/ZtuwJtA7dBG6gdPW5tSBb0skY8DHA=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    wrapQtAppsHook
    hyprwayland-scanner
  ];

  buildInputs = [
    hyprland-protocols
    hyprlang
    hyprutils
    libdrm
    libgbm
    pipewire
    qtbase
    qttools
    qtwayland
    sdbus-cpp_2
    wayland
    wayland-protocols
    wayland-scanner
  ];

  postInstall = ''
    wrapProgramShell $out/bin/hyprland-share-picker \
      "''${qtWrapperArgs[@]}" \
      --prefix PATH ":" ${
        lib.makeBinPath [
          slurp
          hyprland
        ]
      }

    wrapProgramShell $out/libexec/xdg-desktop-portal-hyprland \
      --prefix PATH ":" ${
        lib.makeBinPath [
          (placeholder "out")
          grim
        ]
      }
  '';

  cmakeBuildType = if debug then "Debug" else "RelWithDebInfo";

  depsBuildBuild = [
    pkg-config
  ];

  dontStrip = debug;
  dontWrapQtApps = true;
  separateDebugInfo = !debug;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "xdg-desktop-portal backend for Hyprland";
    homepage = "https://github.com/hyprwm/xdg-desktop-portal-hyprland";
    changelog = "https://github.com/hyprwm/xdg-desktop-portal-hyprland/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "hyprland-share-picker";
    teams = [ lib.teams.hyprland ];
  };
})
