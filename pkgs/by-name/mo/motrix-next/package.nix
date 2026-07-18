{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  desktop-file-utils,
  fetchPnpmDeps,
  glib-networking,
  jq,
  libayatana-appindicator,
  moreutils,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
  xdg-utils,
}:
let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "motrix-next";
  version = "3.9.6";

  src = fetchFromGitHub {
    owner = "AnInsomniacy";
    repo = "motrix-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ynLi+biCdjU7EOq556YuFonghWaxDV7UtHWiKImq7WE=";
  };

  # Deactivate the upstream update mechanism
  postPatch = ''
    jq '
      .bundle.createUpdaterArtifacts = false |
      .plugins.updater = {"active": false, "pubkey": "", "endpoints": []}
    ' \
    src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook

    pnpmConfigHook
    pnpm
    nodejs

    pkg-config
    jq
    moreutils
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
    libayatana-appindicator
  ];

  cargoHash = "sha256-c17GTD9Wcy9LYLfBcwECNS1Tek5hTWPmie2lXtrbtFc=";
  # Some tests on macOS attempt to retrieve system settings, such as the default browser and system proxy.
  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libayatana-appindicator
        ]
      }
      --suffix PATH : ${
        lib.makeBinPath [
          desktop-file-utils
          xdg-utils
        ]
      }
      # Tricky way to make the protocol handler desktop file point to the wrapper
      --set-default APPIMAGE motrix-next
    )
    wrapGApp $out/bin/motrix-next
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";
  # we don't want to wrap aria2c
  dontWrapGApps = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-WAuHoLAnFLP6i+rJSegt/hI6sb1SDhm7LWgsup70o9E=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Full-featured download manager, rebuilt from scratch with Tauri 2, Vue 3, and Rust";
    homepage = "https://github.com/AnInsomniacy/motrix-next";
    changelog = "https://github.com/AnInsomniacy/motrix-next/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      gpl2Plus
    ];

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # ships an upstream-provided aria2c binary (statically linked, max connections increased)
      # source for this binary: https://github.com/AnInsomniacy/aria2-builder
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "motrix-next";
  };
})
