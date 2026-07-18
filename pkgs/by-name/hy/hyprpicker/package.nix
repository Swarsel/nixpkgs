{
  lib,
  fetchFromGitHub,
  cairo,
  cmake,
  gcc15Stdenv,
  hyprutils,
  hyprwayland-scanner,
  libGL,
  libjpeg,
  libxdmcp,
  libxkbcommon,
  nix-update-script,
  pango,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
  debug ? false,
}:
gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprpicker" + lib.optionalString debug "-debug";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprpicker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ABumeksE8Bvtdb6g4vJ2jA9BLlYHnXU86VAuKJhBPoY=";
  };

  nativeBuildInputs = [
    cmake
    hyprwayland-scanner
    pkg-config
  ];

  buildInputs = [
    cairo
    hyprutils
    libGL
    libjpeg
    libxkbcommon
    pango
    wayland
    wayland-protocols
    wayland-scanner
    libxdmcp
  ];

  postInstall = ''
    mkdir -p $out/share/licenses
    install -Dm644 $src/LICENSE -t $out/share/licenses/hyprpicker
  '';

  cmakeBuildType = if debug then "Debug" else "RelWithDebInfo";
  dontStrip = debug;
  separateDebugInfo = !debug;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wlroots-compatible Wayland color picker that does not suck";
    homepage = "https://github.com/hyprwm/hyprpicker";
    changelog = "https://github.com/hyprwm/hyprpicker/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    platforms = wayland.meta.platforms;
    mainProgram = "hyprpicker";
    teams = [ lib.teams.hyprland ];
  };
})
