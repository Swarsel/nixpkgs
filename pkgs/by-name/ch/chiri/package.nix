{
  lib,
  stdenv,
  fetchFromGitHub,
  # build tools
  cargo-tauri,
  fetchPnpmDeps,
  # Linux dependencies
  glib-networking,
  libayatana-appindicator,
  makeBinaryWrapper,
  nix-update-script,
  nodejs_26,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_11,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (
  finalAttrs:
  let
    # on macOS, Node.js worker threads default to `trackUnmanagedFds: true`
    # when used with pnpm's graceful-fs EAGAIN retry loop, this causes file descriptor
    # churn that leads to a crash during cleanup (presenting as `Killed: 9` / SIGKILL)
    # within the Nix sandbox. so we just disable `trackUnmanagedFds` to prevent this
    # see: https://github.com/NixOS/nixpkgs/issues/525627
    pnpm-patched = pnpm_11.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace dist/pnpm.mjs \
          --replace-fail \
            'resourceLimits: this._workerResourceLimits' \
            'resourceLimits: this._workerResourceLimits, trackUnmanagedFds: false'
      '';
    });
  in
  {
    pname = "chiri";
    version = "0.9.2";

    src = fetchFromGitHub {
      owner = "chiriapp";
      repo = "chiri";
      tag = "app-v${finalAttrs.version}";
      hash = "sha256-zBv/egEvmsZXklhKtN5fd2DOKH+UWcaGUUkFxz0G+JI=";
    };

    postPatch =
      lib.optionalString stdenv.hostPlatform.isLinux ''
        for libappindicatorRs in $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs; do
          if [[ -f "$libappindicatorRs" ]]; then
            substituteInPlace "$libappindicatorRs" \
              --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
          fi
        done
      ''
      + ''
        substituteInPlace src-tauri/tauri.conf.json \
          --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
      '';

    nativeBuildInputs = [
      cargo-tauri.hook
      nodejs_26
      pnpmConfigHook
      pnpm-patched
      pkg-config
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      wrapGAppsHook4
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      makeBinaryWrapper
    ];

    buildInputs = [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      libayatana-appindicator
      webkitgtk_4_1
    ];

    cargoHash = "sha256-69r9ILhSov7A9zdWcPphGMXur/8lYyZYo7qSGPW9IzM=";

    # This is needed since the signing keys are private, and are only used in CI during releases anyways. Regular users won't need this.
    preBuild = ''
      unset TAURI_SIGNING_PRIVATE_KEY
      unset TAURI_SIGNING_PUBLIC_KEY
      pnpm build
    '';

    doCheck = false;

    postInstall =
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/bin
          makeWrapper "$out/Applications/Chiri.app/Contents/MacOS/chiri" "$out/bin/chiri"
        ''
      else
        ''
          mv $out/bin/Chiri $out/bin/chiri
          for desktopFile in \
            $out/share/applications/Chiri.desktop \
            $out/share/applications/garden.chiri.Chiri.desktop
          do
            if [ -f "$desktopFile" ]; then
              substituteInPlace "$desktopFile" \
                --replace-fail "Exec=Chiri" "Exec=chiri"
            fi
          done
        '';

    buildAndTestSubdir = "src-tauri";
    cargoRoot = "src-tauri";

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-1S1XR/E611LGivXpIK0kvkvXWPNqDzvFKPT7a1Qu1zg=";
      pnpm = pnpm-patched;
    };

    passthru.updateScript = nix-update-script;

    meta = {
      description = "Cross-platform CalDAV task management app";
      homepage = "https://github.com/chiriapp/chiri";
      changelog = "https://github.com/chiriapp/chiri/releases/tag/app-v${finalAttrs.version}";
      license = lib.licenses.zlib;
      maintainers = with lib.maintainers; [ SapphoSys ];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "chiri";
    };
  }
)
