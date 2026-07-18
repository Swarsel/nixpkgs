{
  lib,
  fetchFromGitHub,
  aquamarine,
  cairo,
  cmake,
  gcc15Stdenv,
  glaze,
  hyprgraphics,
  hyprtoolkit,
  hyprutils,
  libdrm,
  nix-update-script,
  pixman,
  pkg-config,
  versionCheckHook,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprshutdown";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprshutdown";
    tag = "v${finalAttrs.version}";
    hash = "sha256-msCMXV9k9+1siOPaxSzNJwx/o8pn2srCR4h0pxyW/WE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    hyprtoolkit
    hyprutils
    pixman
    libdrm
    aquamarine
    hyprgraphics
    cairo
    (glaze.override { enableSSL = false; })
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--help";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A graceful shutdown utility for Hyprland";
    homepage = "https://github.com/hyprwm/hyprshutdown";
    changelog = "https://github.com/hyprwm/hyprshutdown/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.mithicspirit ];
    platforms = lib.platforms.linux;
    mainProgram = "hyprshutdown";
    teams = [ lib.teams.hyprland ];
  };
})
