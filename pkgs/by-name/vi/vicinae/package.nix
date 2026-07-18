{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cmark-gfm,
  coreutils,
  fetchNpmDeps,
  glaze,
  kdePackages,
  libqalculate,
  libxml2,
  minizip,
  ninja,
  nodejs,
  npmHooks,
  pkg-config,
  qt6,
  udevCheckHook,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vicinae";
  version = "0.22.3";

  src = fetchFromGitHub {
    owner = "vicinaehq";
    repo = "vicinae";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1c6rl+PMI61l3H2a8Ks1qbFGW2psHs0FamJd/Vzq6NY=";
  };

  postPatch = ''
    # Toggle telemetry from opt-out to opt-in
    substituteInPlace extra/config.jsonc \
      --replace-fail '"system_info": true' '"system_info": false'

    local postPatchHooks=()
    source ${npmHooks.npmConfigHook}/nix-support/setup-hook
    npmRoot=src/typescript/api npmDeps=${finalAttrs.apiDeps} npmConfigHook
    npmRoot=src/typescript/extension-manager npmDeps=${finalAttrs.extensionManagerDeps} npmConfigHook
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    nodejs
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    cmark-gfm
    glaze
    kdePackages.layer-shell-qt
    kdePackages.qtkeychain
    kdePackages.syntax-highlighting
    libqalculate
    minizip
    nodejs
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    wayland
    libxml2
  ];

  cmakeFlags = lib.mapAttrsToList lib.cmakeFeature {
    "CMAKE_INSTALL_BINDIR" = "bin";
    "CMAKE_INSTALL_DATAROOTDIR" = "share";
    "CMAKE_INSTALL_LIBDIR" = "lib";
    "CMAKE_INSTALL_PREFIX" = placeholder "out";
    "INSTALL_BROWSER_NATIVE_HOST" = "OFF";
    "INSTALL_NODE_MODULES" = "OFF";
    "USE_SYSTEM_GLAZE" = "ON";
    "VICINAE_GIT_TAG" = "v${finalAttrs.version}";
    "VICINAE_PROVENANCE" = "nix";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ udevCheckHook ];

  postFixup = ''
    substituteInPlace $out/share/systemd/user/vicinae.service \
      --replace-fail "/bin/kill" "${lib.getExe' coreutils "kill"}"\
      --replace-fail "ExecStart=vicinae" "ExecStart=$out/bin/vicinae"
  '';

  apiDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/src/typescript/api";
    hash = "sha256-Im8fSG9sbaSynrN5gLsWVaPgH5g4Zp+x+FUPIBXrKjg=";
  };

  extensionManagerDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/src/typescript/extension-manager";
    hash = "sha256-pEgqFgvdz7Bcc+LznCI+KlD1XEfUuWFWjS24MJ7sx3k=";
  };

  qtWrapperArgs = [
    "--prefix PATH :  ${
      lib.makeBinPath [
        nodejs
        (placeholder "out")
      ]
    }"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Native, fast, extensible launcher for the desktop";
    homepage = "https://github.com/vicinaehq/vicinae";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      whispersofthedawn
      zstg
    ];

    platforms = lib.platforms.linux;
    mainProgram = "vicinae";
  };
})
