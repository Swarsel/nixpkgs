{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cargo-tauri,
  desktop-file-utils,
  fetchYarnDeps,
  glib-networking,
  installShellFiles,
  jq,
  libayatana-appindicator,
  makeBinaryWrapper,
  moreutils,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
  webkitgtk_4_1,
  wrapGAppsHook3,
  yarnConfigHook,
}:

let
  version = "0.6.15";

  src = fetchFromGitHub {
    owner = "loft-sh";
    repo = "devpod";
    tag = "v${version}";
    hash = "sha256-fLUJeEwNDyzMYUEYVQL9XGQv/VAxjH4IZ1SJa6jx4Mw=";
  };

  meta = {
    description = "Codespaces but open-source, client-only and unopinionated: Works with any IDE and lets you use any cloud, kubernetes or just localhost docker";
    homepage = "https://devpod.sh";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.tomasajt ];
    mainProgram = "devpod";
  };

  devpod = buildGoModule (finalAttrs: {
    inherit version src meta;
    pname = "devpod";
    nativeBuildInputs = [ installShellFiles ];
    vendorHash = null;
    env.CGO_ENABLED = 0;

    postInstall = ''
      $out/bin/devpod completion bash >devpod.bash
      $out/bin/devpod completion fish >devpod.fish
      $out/bin/devpod completion zsh >devpod.zsh
      installShellCompletion devpod.{bash,fish,zsh}
    '';

    excludedPackages = [ "./e2e" ];

    ldflags = [
      "-X github.com/loft-sh/devpod/pkg/version.version=v${version}"
    ];

    passthru.tests.version = testers.testVersion {
      version = "v${version}";
      command = "devpod version";
      package = finalAttrs.finalPackage;
    };
  });

  devpod-desktop = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "devpod-desktop";

    patches = [
      # don't create a .desktop file automatically registered to open the devpod:// URI scheme
      # we edit the in-store .desktop file in postInstall to support opening the scheme,
      # but users will have to configure the default handler manually
      ./dont-auto-register-scheme.patch

      # disable the button that symlinks the `devpod-cli` binary to ~/.local/bin/devpod
      # and don't show popup where it prompts you to press the above mentioned button
      # we'll symlink it manually to $out/bin/devpod in postInstall
      ./dont-copy-sidecar-out-of-store.patch

      # otherwise it's going to get stuck in an endless error cycle, quickly increasing the log file size
      ./exit-update-checker-loop.patch
    ];

    postPatch = ''
      ln -s ${lib.getExe devpod} src-tauri/bin/devpod-cli-${stdenv.hostPlatform.rust.rustcTarget}

      # disable upstream updater
      jq '.plugins.updater.endpoints = [ ] | .bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
        | sponge src-tauri/tauri.conf.json
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
        --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    '';

    nativeBuildInputs = [
      cargo-tauri.hook
      jq
      moreutils
      nodejs
      yarnConfigHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      desktop-file-utils
      pkg-config
      wrapGAppsHook3
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      makeBinaryWrapper
    ];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      libayatana-appindicator
      openssl
      webkitgtk_4_1
    ];

    cargoHash = "sha256-PSgBwa8sZ85W2kBrXkFVvnoYn5l1r3Jvn/LG8tITjbU=";

    postInstall =
      lib.optionalString stdenv.hostPlatform.isDarwin ''
        # replace sidecar binary with symlink
        ln -sf ${lib.getExe devpod} "$out/Applications/DevPod.app/Contents/MacOS/devpod-cli"

        makeWrapper "$out/Applications/DevPod.app/Contents/MacOS/DevPod Desktop" "$out/bin/DevPod Desktop"
      ''
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        # replace sidecar binary with symlink
        ln -sf ${lib.getExe devpod} "$out/bin/devpod-cli"

        # set up scheme handling
        desktop-file-edit "$out/share/applications/DevPod.desktop" \
          --set-key="Exec"     --set-value="\"DevPod Desktop\" %u" \
          --set-key="MimeType" --set-value="x-scheme-handler/devpod"

        # whitespace in the icon name causes gtk-update-icon-cache to fail
        desktop-file-edit "$out/share/applications/DevPod.desktop" \
          --set-key="Icon"     --set-value="DevPod-Desktop"

        for dir in "$out"/share/icons/hicolor/*/apps; do
          mv "$dir/DevPod Desktop.png" "$dir/DevPod-Desktop.png"
        done
      ''
      + ''
        # propagate the `devpod` command
        ln -s ${lib.getExe devpod} "$out/bin/devpod"
      '';

    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapGApp "$out/bin/DevPod Desktop"
    '';

    buildAndTestSubdir = "src-tauri";
    cargoPatches = [ ./cargo-lock.patch ];
    cargoRoot = "src-tauri";
    # we only want to wrap the main binary
    dontWrapGApps = true;

    offlineCache = fetchYarnDeps {
      hash = "sha256-0Ov+Ik+th2IiuuqJyiO9t8vTyMqxDa9juEwbwHFaoi4=";
      yarnLock = "${src}/desktop/yarn.lock";
    };

    sourceRoot = "${src.name}/desktop";

    meta = meta // {
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "DevPod Desktop";
    };
  };
in
{
  inherit devpod devpod-desktop;
}
