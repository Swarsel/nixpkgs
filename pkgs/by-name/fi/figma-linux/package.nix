{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeBinaryWrapper,
  makeDesktopItem,
  p7zip,
  # there's a setting "use zenity for dialogs"
  zenity,
}:
buildNpmPackage (finalAttrs: {
  pname = "figma-linux";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "Figma-Linux";
    repo = "figma-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pa0GgAmi9Os4EtZpbo0hSgr4s+WX95zLUrZR8a33TeI=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
  ];

  npmDepsHash = "sha256-FqgcG52Nkj0wlwsHwIWTXNuIeAs7b+TPkHcg7m5D2og=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/figma-linux/resources

    rm -rf node_modules/7zip-bin

    cp -r node_modules $out/share/figma-linux/resources

    # transpose [name][size] into [size][name]
    for icon in resources/icons/*.png; do
      basename="$(basename "$icon")"
      size="''${basename%.png}"

      install -Dm444 "$icon" -T "$out/share/icons/hicolor/$size/apps/figma-linux.png"
    done

    cp -r dist $out/share/figma-linux/resources/app

    makeWrapper ${lib.getExe electron} $out/bin/figma-linux \
      --add-flag $out/share/figma-linux/resources/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime=true}}" \
      --prefix PATH : "${
        lib.makeBinPath [
          p7zip
          zenity
        ]
      }" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "Unofficial Figma desktop application for Linux";
      desktopName = "Figma Linux";
      exec = "figma-linux %U";
      icon = "figma-linux";
      name = "figma-linux";
      terminal = false;
    })
  ];

  meta = {
    description = "Unofficial Electron-based Figma desktop app for Linux";
    homepage = "https://github.com/Figma-Linux/figma-linux";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      kashw2
    ];

    platforms = lib.platforms.linux;
    mainProgram = "figma-linux";
  };
})
