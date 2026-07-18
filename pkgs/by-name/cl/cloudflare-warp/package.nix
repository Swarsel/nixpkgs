{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  common-updater-scripts,
  copyDesktopItems,
  cpio,
  curl,
  dbus,
  desktop-file-utils,
  dpkg,
  gtk3,
  jq,
  libpcap,
  makeDesktopItem,
  makeWrapper,
  nftables,
  nss,
  openssl,
  ripgrep,
  versionCheckHook,
  writeShellApplication,
  xar,
  headless ? false,
}:

let
  version = "2026.3.846.0";
  sources = {
    aarch64-darwin = fetchurl {
      hash = "sha256-cDmoM0nIYYQyurJeeiVSX0IWJdIY0pVLmjIae5mEXI4=";
      url = "https://downloads.cloudflareclient.com/v1/download/macos/version/${version}";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-0zYsyZbX8qq/P+GHW4UHSTy2OsDa4fJAVjHcRbpHtSc=";
      url = "https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_${version}_arm64.deb";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-1SKTK0QW+3CcqBLqHbIsPny/6ekyjZe9qRcjYOMnR58=";
      url = "https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_${version}_amd64.deb";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "cloudflare-warp" + lib.optionalString headless "-headless";

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xar
    cpio
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dpkg
    autoPatchelfHook
    versionCheckHook
  ]
  ++ lib.optionals (!headless && stdenv.hostPlatform.isLinux) [
    copyDesktopItems
    desktop-file-utils
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux (
    [
      dbus
      libpcap
      openssl
      nss
      (lib.getLib stdenv.cc.cc)
    ]
    ++ lib.optionals (!headless) [
      gtk3
    ]
  );

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall

        mkdir -p $out/Applications $out/bin

        cp -R "Cloudflare WARP.app" $out/Applications/

        for tool in warp-cli warp-dex warp-diag; do
          ln -s "$out/Applications/Cloudflare WARP.app/Contents/Resources/$tool" "$out/bin/$tool"
        done

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mv usr $out
        mv bin $out
        mv etc $out
        patchelf --replace-needed libpcap.so.0.8 ${libpcap}/lib/libpcap.so $out/bin/warp-dex
        mv lib/systemd/system $out/lib/systemd/
        substituteInPlace $out/lib/systemd/system/warp-svc.service \
          --replace-fail "ExecStart=" "ExecStart=$out"
        ${lib.optionalString (!headless) ''
          substituteInPlace $out/lib/systemd/user/warp-taskbar.service \
            --replace-fail "ExecStart=" "ExecStart=$out" \
            --replace-fail "BindsTo=" "PartOf="

          cat >>$out/lib/systemd/user/warp-taskbar.service <<EOF

          [Service]
          BindReadOnlyPaths=$out:/usr:
          EOF
        ''}
        ${lib.optionalString headless ''
          # For headless version, remove GUI components
          rm $out/bin/warp-taskbar
          rm -r $out/lib/systemd/user
          rm -r $out/etc
          rm -r $out/share/applications
          rm -r $out/share/icons
          rm -r $out/share/warp
        ''}

        runHook postInstall
      '';

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/warp-svc --prefix PATH : ${lib.makeBinPath [ nftables ]}
    ${lib.optionalString (!headless) ''
      wrapProgram $out/bin/warp-cli --prefix PATH : ${lib.makeBinPath [ desktop-file-utils ]}
    ''}
  '';

  doInstallCheck = stdenv.hostPlatform.isLinux;

  autoPatchelfIgnoreMissingDeps = [
    "libpcap.so.0.8"
  ];

  desktopItems = lib.optionals (!headless) [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Security"
        "ConsoleOnly"
      ];

      desktopName = "Cloudflare Zero Trust Team Enrollment";
      exec = "warp-cli --accept-tos registration token %u";
      mimeTypes = [ "x-scheme-handler/com.cloudflare.warp" ];
      name = "com.cloudflare.WarpCli";
      noDisplay = true;
      startupNotify = false;
      terminal = true;
    })
  ];

  # The Sparkle.framework in the upstream macOS package contains a broken symlink
  # (XPCServices -> Versions/Current/XPCServices) where the target doesn't exist.
  # This is present in the official installed app and doesn't affect functionality.
  dontCheckForBrokenSymlinks = stdenv.hostPlatform.isDarwin;

  unpackPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preUnpack

    xar -xf $src
    zcat < Cloudflare_WARP_${version}.pkg/Payload | cpio -i

    runHook postUnpack
  '';

  passthru = {
    inherit sources;

    updateScript = lib.getExe (writeShellApplication {
      name = "update-cloudflare-warp";

      runtimeInputs = [
        curl
        jq
        ripgrep
        common-updater-scripts
      ];

      text = ''
        new_version="$(
          curl --fail --silent -L ''${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} \
            -H 'Accept: application/vnd.github+json' \
            -H 'X-GitHub-Api-Version: 2022-11-28' \
            'https://api.github.com/repos/cloudflare/cloudflare-docs/git/trees/production?recursive=true' |
            jq -r '[.tree[].path | select(startswith("src/content/warp-releases/linux/ga/"))] | max_by(split("/")[-1] | split(".") | map(tonumber?))' |
            rg '([^/]+)\.yaml\b' --only-matching --replace '$1'
        )"

        for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
          update-source-version "${finalAttrs.pname}" "$new_version" --ignore-same-version --source-key="sources.$platform"
        done
      '';
    });
  };

  meta = {
    description =
      "Replaces the connection between your device and the Internet with a modern, optimized, protocol"
      + lib.optionalString headless " (headless version)";

    homepage = "https://pkg.cloudflareclient.com/";
    changelog = "https://github.com/cloudflare/cloudflare-docs/blob/production/src/content/warp-releases/linux/ga/${finalAttrs.version}.yaml";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      marcusramberg
      anish
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "warp-cli";
  };
})
