{
  lib,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  dotnetCorePackages,
  fetchzip,
  gtk3,
  libGL,
  makeDesktopItem,
  stdenvNoCC,
  wrapGAppsHook3,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "grooveauthor";
  version = "1.1.4";

  src = fetchzip {
    url = "https://github.com/PerryAsleep/GrooveAuthor/releases/download/v${finalAttrs.version}/GrooveAuthor-v${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-LjOOI1cUbYpl4tmY1eAZV3S99yQOb4V6LU9Gu/hTtnY=";
    stripRoot = false;
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapGAppsHook3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm444 grooveauthor/Icon.svg $out/share/icons/hicolor/scalable/apps/GrooveAuthor.svg
    mv grooveauthor $out/bin
    rm $out/bin/{GrooveAuthor.desktop,Icon.svg}
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set DOTNET_ROOT ${dotnetCorePackages.runtime_10_0}/share/dotnet
      --suffix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          alsa-lib
          libGL
        ]
      }"
    )
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "AudioVideoEditing"
      ];

      desktopName = "GrooveAuthor";
      exec = "GrooveAuthor";
      genericName = "Editor for StepMania";
      icon = "GrooveAuthor";

      keywords = [
        "GrooveAuthor"
        "StepMania"
        "ITG"
        "ITGmania"
        "DDR"
        "PIU"
        "Pump It Up"
        "Dance"
        "StepF2"
        "StepP1"
      ];

      name = finalAttrs.pname;
      prefersNonDefaultGPU = true;
      singleMainWindow = true;
      terminal = false;
    })
  ];

  runtimeDependencies = [ gtk3 ];

  meta = {
    description = "GrooveAuthor is an editor for authoring StepMania charts";
    homepage = "https://github.com/PerryAsleep/GrooveAuthor";

    license = with lib.licenses; [
      mit
      mspl
    ];

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ ungeskriptet ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "GrooveAuthor";
  };
})
