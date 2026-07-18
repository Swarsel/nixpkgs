{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cargo-tauri,
  fetchPnpmDeps,
  glib-networking,
  gst_all_1,
  gtk3,
  jq,
  librsvg,
  moreutils,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_11,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "readest";
  version = "0.11.18";

  src = fetchFromGitHub {
    owner = "readest";
    repo = "readest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ate2vEYdE121wy3WUautpbIzfejbcaBZr/CnA6rf2Zw=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false' \
      --replace-fail '"Readest"' '"readest"'
    jq 'del(.plugins."deep-link")' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
    substituteInPlace src/services/constants.ts \
      --replace-fail "autoCheckUpdates: true" "autoCheckUpdates: false" \
      --replace-fail "telemetryEnabled: true" "telemetryEnabled: false"

    jq '.version = "${finalAttrs.version}"' package.json | sponge package.json

    mkdir -p src-tauri/plugins/tauri-plugin-turso/dist-js
    cp -r ${finalAttrs.passthru.tursoPlugin} src-tauri/plugins/tauri-plugin-turso/dist-js
    jq '.scripts.build = "true"' \
      src-tauri/plugins/tauri-plugin-turso/package.json | \
      sponge src-tauri/plugins/tauri-plugin-turso/package.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpmConfigHook
    pnpm_11
    pkg-config
    wrapGAppsHook3
    autoPatchelfHook
    moreutils
    jq
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    librsvg
    openssl
    glib-networking
    # TTS
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  cargoHash = "sha256-RgqkTttEScAp1R+CWE1ItD5yCDMtJ5tb3fjgkMi3x9E=";

  preBuild = ''
    # set up pdfjs and simplecc
    pnpm setup-vendors

    # `tauri-plugin-turso` expects frontend files to exist before the build, else it fails with:
    #
    # > > tauri-plugin-turso-api@0.1.0 build /build/source/apps/readest-app/src-tauri/plugins/tauri-plugin-turso
    # > > true
    # >
    # >   Error Unable to find your web assets, did you forget to build your web app?
    #     Your frontendDist is set to "../out" (which is `/build/source/apps/readest-app/out`).
    pnpm --filter @readest/readest-app build
  '';

  buildAndTestSubdir = "src-tauri";
  cargoRoot = "../..";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-wtWYdIfqytwn8PNahbQ/WxJuhhH1lbgNshQy6V0vvcA=";
    pnpm = pnpm_11;

    pnpmInstallFlags = [
      # Increase number of fetch attempts to work around timeout issues on slow
      # networks: "TimeoutError: The operation was aborted due to timeout".
      #
      # If this still happens on your network, consider changing some of the
      # fetch setting and opening a pull request:
      # https://pnpm.io/settings#request-settings
      "--fetch-retries=5"
    ];
  };

  pnpmRoot = "../..";

  postUnpack = ''
    # pnpm.configHook has to write to ../.., as our sourceRoot is set to
    # apps/readest-app
    chmod -R +w .
  '';

  sourceRoot = "${finalAttrs.src.name}/apps/readest-app";

  passthru.tursoPlugin = stdenv.mkDerivation {
    pname = "tauri-plugin-turso";
    version = finalAttrs.version;
    src = "${finalAttrs.src}/apps/readest-app/src-tauri/plugins/tauri-plugin-turso";

    nativeBuildInputs = [
      pnpm_11
      pnpmConfigHook
      nodejs
    ];

    buildPhase = ''
      pnpm build
    '';

    installPhase = ''
      cp -r dist-js $out
    '';

    pnpmDeps = finalAttrs.passthru.tursoPluginDeps;
  };

  passthru.tursoPluginDeps = fetchPnpmDeps {
    pname = "tauri-plugin-turso";
    version = finalAttrs.version;
    src = "${finalAttrs.src}/apps/readest-app/src-tauri/plugins/tauri-plugin-turso";
    fetcherVersion = 4;
    hash = "sha256-quVUYsT3u4UBhuJ75QQ4SEuW8MhGQ0vGhtwtUj/eKHs=";
    pnpm = pnpm_11;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern, feature-rich ebook reader";
    homepage = "https://github.com/readest/readest";
    changelog = "https://github.com/readest/readest/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      eljamm
      kasifrasi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "readest";
  };
})
