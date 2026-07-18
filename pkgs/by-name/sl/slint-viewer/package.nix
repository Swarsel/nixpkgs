{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchCrate,
  fontconfig,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  qt6,
  rustPlatform,
  versionCheckHook,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "slint-viewer";
  version = "1.17.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-Jo2nAYUx6N2fJvX4hHckRKr2gr6xsGW9lNMD45+/uNY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    fontconfig
    libGL
  ];

  cargoHash = "sha256-TsM2CFsNDu4SRPcDwAWoPOtWPMf/Z3R9HlSlh4Ly92s=";
  # There are no tests
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # stolen from the surfer package
  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    wayland
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Viewer for .slint files from the Slint Project";
    homepage = "https://crates.io/crates/slint-viewer";
    changelog = "https://github.com/slint-ui/slint/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "slint-viewer";
  };
})
