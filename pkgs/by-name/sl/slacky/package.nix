{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "slacky";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "andirsun";
    repo = "Slacky";
    tag = "v${finalAttrs.version}";
    hash = "sha256-irZC09Nm/yrd7Z5av5HJo64gb1TEFzeJqe004GtmEpY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  npmDepsHash = "sha256-OtspJ1/QaUfXyBHt9hvx+d4JEfKe1X9w+IlMVtdoTiY=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postInstall = ''
    mkdir -p $out/share/icons
    ln -s $out/lib/node_modules/slacky/build/icons/icon.png $out/share/icons/slacky.png
    makeWrapper ${lib.getExe electron} $out/bin/slacky \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags $out/lib/node_modules/slacky/
  '';

  desktopItems = lib.singleton (makeDesktopItem {
    categories = [
      "Network"
      "InstantMessaging"
    ];

    comment = "An unofficial Slack desktop client for arm64 Linux";
    desktopName = "Slacky";
    exec = "slacky %u";
    icon = "slacky";

    mimeTypes = [
      "x-scheme-handler/slack"
    ];

    name = "slacky";
    startupWMClass = "com.andersonlaverde.slacky";
    type = "Application";
  });

  makeCacheWritable = true;

  npmFlags = [
    "--legacy-peer-deps"
  ];

  npmPackFlags = [
    "--ignore-scripts"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial Slack desktop client for arm64 Linux";
    homepage = "https://github.com/andirsun/Slacky";
    changelog = "https://github.com/andirsun/Slacky/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ da157 ];
    platforms = lib.platforms.linux;
    mainProgram = "slacky";
  };
})
