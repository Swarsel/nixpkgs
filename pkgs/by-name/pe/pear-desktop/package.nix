{
  lib,
  stdenv,
  fetchFromGitHub,
  actool,
  copyDesktopItems,
  electron_42,
  fetchPnpmDeps,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pear-desktop";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "pear-devs";
    repo = "pear-desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RSQPwsED3YK5VScVAXH3f8Lz74v1b2448gro1Vo22hg=";
  };

  patches = [
    # MPRIS's DesktopEntry property needs to match the desktop entry basename
    ./fix-mpris-desktop-entry.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    python3
    nodejs
    pnpmConfigHook
    pnpm_11
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ actool ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ copyDesktopItems ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  postBuild = ''
    pnpm build

    cp -r ${electron_42.dist} electron-dist
    chmod -R u+w electron-dist

    ./node_modules/.bin/electron-builder \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron_42.version}
  '';

  installPhase = ''
    runHook preInstall

  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/{Applications,bin}
    mv pack/mac*/YouTube\ Music.app $out/Applications
    ln -s "$out/Applications/YouTube Music.app/Contents/MacOS/YouTube Music" $out/bin/pear-desktop
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mkdir -p "$out/share/pear-desktop"
    cp -r pack/*-unpacked/{locales,resources{,.pak}} "$out/share/pear-desktop"

    pushd assets/generated/icons/png
    for file in *.png; do
      install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/pear-desktop.png
    done
    popd
  ''
  + ''

    runHook postInstall
  '';

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    makeWrapper ${electron_42}/bin/electron $out/bin/pear-desktop \
      --add-flags $out/share/pear-desktop/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "AudioVideo" ];
      desktopName = "Pear Desktop";
      exec = "pear-desktop %u";
      icon = "pear-desktop";
      name = "com.github.th-ch.youtube-music";
      startupWMClass = "com.github.th-ch.youtube-music";
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-y4eLjikf9X/682RdK0ZvW7+GR1Ei82UJ5SVop09B9wg=";
    pnpm = pnpm_11;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Electron wrapper around YouTube Music";
    homepage = "https://github.com/pear-devs/pear-desktop";

    changelog = "https://github.com/pear-devs/pear-desktop/blob/master/changelog.md#${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.src.tag
    }";

    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aacebedo
      SuperSandro2000
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "pear-desktop";
  };
})
