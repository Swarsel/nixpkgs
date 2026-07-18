{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  copyDesktopItems,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "halloy";
  version = "2026.7.2";

  src = fetchFromGitHub {
    owner = "squidowl";
    repo = "halloy";
    tag = finalAttrs.version;
    hash = "sha256-+qFHwlwRxVN4W9DG+gY5N6um+JARD+3EiLlsD7R9Tpc=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libxkbcommon
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    libxcb
  ];

  cargoHash = "sha256-/nFtOJXpusIlc7orGv013qzad8fdfQr32c8DAlccHIA=";

  postInstall = ''
    install -Dm644 assets/linux/icons/hicolor/128x128/apps/org.squidowl.halloy.png \
      $out/share/icons/hicolor/128x128/apps/org.squidowl.halloy.png
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    APP_DIR="$out/Applications/Halloy.app/Contents"

    mkdir -p "$APP_DIR/MacOS"
    cp -r ${finalAttrs.src}/assets/macos/Halloy.app/Contents/* "$APP_DIR"

    substituteInPlace "$APP_DIR/Info.plist" \
      --replace-fail "{{ VERSION }}" "${finalAttrs.version}" \
      --replace-fail "{{ BUILD }}" "${finalAttrs.version}-nixpkgs"

    makeWrapper "$out/bin/halloy" "$APP_DIR/MacOS/halloy"
  '';

  postFixup = lib.optional stdenv.hostPlatform.isLinux (
    let
      rpathWayland = lib.makeLibraryPath [
        wayland
        vulkan-loader
        libxkbcommon
      ];
    in
    ''
      rpath=$(patchelf --print-rpath $out/bin/halloy)
      patchelf --set-rpath "$rpath:${rpathWayland}" $out/bin/halloy
    ''
  );

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "IRCClient"
      ];

      comment = "IRC client written in Rust";
      desktopName = "Halloy";
      exec = finalAttrs.meta.mainProgram;
      icon = "org.squidowl.halloy";

      keywords = [
        "IM"
        "Chat"
      ];

      mimeTypes = [
        "x-scheme-handler/irc"
        "x-scheme-handler/ircs"
        "x-scheme-handler/halloy"
      ];

      name = "org.squidowl.halloy";
      startupWMClass = "org.squidowl.halloy";
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "IRC application";
    homepage = "https://github.com/squidowl/halloy";
    changelog = "https://github.com/squidowl/halloy/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fab
      iivusly
      ivyfanchiang
    ];

    mainProgram = "halloy";
  };
})
