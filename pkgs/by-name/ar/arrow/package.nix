{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  godot_4_4,
  libGL,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  udev,
  vulkan-loader,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "arrow";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "mhgolkar";
    repo = "Arrow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Tlqh0Xn2xnF2AWv9u5xIWo6Mvg/uEsqqxWx70kd3+k=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    writableTmpDirAsHomeHook
    godot_4_4
    copyDesktopItems
  ];

  buildPhase = ''
    runHook preBuild

    ln -s "${godot_4_4.export-templates-bin}" $HOME/.local

    mkdir -p build
    godot4 --headless --export-release Linux ./build/Arrow

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 755 -t $out/libexec ./build/Arrow
    install -D -m 644 -t $out/libexec ./build/Arrow.pck

    install -d -m 755 $out/bin
    ln -s $out/libexec/Arrow $out/bin/Arrow

    install -vD icon.svg $out/share/icons/hicolor/scalable/apps/Arrow.svg

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Application" ];
      comment = "Game Narrative Design Tool";
      desktopName = "Arrow";
      exec = "Arrow";
      icon = "Arrow";
      name = "Arrow";
      terminal = false;
      type = "Application";
    })
  ];

  runtimeDependencies = map lib.getLib [
    alsa-lib
    libGL
    libpulseaudio
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    udev
    vulkan-loader
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Game Narrative Design Tool";
    homepage = "https://mhgolkar.github.io/Arrow/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ miampf ];
    platforms = lib.platforms.linux;
    mainProgram = "Arrow";
  };
})
