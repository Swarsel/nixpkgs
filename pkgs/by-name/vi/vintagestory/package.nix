{
  lib,
  stdenv,
  fetchurl,
  cairo,
  copyDesktopItems,
  dotnet-runtime_10,
  libGLU,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcursor,
  libxi,
  makeDesktopItem,
  makeWrapper,
  pipewire,
  versionCheckHook,
  libxkbcommon ? null,
  wayland ? null,
  waylandSupport ? false,
  x11Support ? true,
}:

assert x11Support || waylandSupport;
assert waylandSupport -> wayland != null;
assert waylandSupport -> libxkbcommon != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "vintagestory";
  version = "1.22.3";

  src = fetchurl {
    url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${finalAttrs.version}.tar.gz";
    hash = "sha256-sa4Pj1DwT6W6LJCAYznmbyqPtMUTaLSNTkXS1imQp04=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/vintagestory $out/bin $out/share/icons/hicolor/512x512/apps $out/share/fonts/truetype
    cp -r * $out/share/vintagestory
    install -Dm444 $out/share/vintagestory/assets/gameicon.png $out/share/icons/hicolor/512x512/apps/vintagestory.png
    cp $out/share/vintagestory/assets/game/fonts/*.ttf $out/share/fonts/truetype

    rm -rvf $out/share/vintagestory/{install,run,server}.sh

    runHook postInstall
  '';

  doInstallCheck = true;

  preFixup = ''
     makeWrapperArgs+=(--prefix LD_LIBRARY_PATH : "$runtimeLibraryPath")

     makeWrapper ${lib.meta.getExe dotnet-runtime_10} $out/bin/vintagestory \
      "''${makeWrapperArgs[@]}" \
       --add-flags $out/share/vintagestory/Vintagestory.dll

    makeWrapper ${lib.getExe dotnet-runtime_10} $out/bin/vintagestory-server \
      "''${makeWrapperArgs[@]}" \
      --add-flags $out/share/vintagestory/VintagestoryServer.dll

     find "$out/share/vintagestory/assets/" -not -path "*/fonts/*" -regex ".*/.*[A-Z].*" | while read -r file; do
       local filename="$(basename -- "$file")"
       ln -sf "$filename" "''${file%/*}"/"''${filename,,}"
     done
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Innovate and explore in a sandbox world";
      desktopName = "Vintage Story";
      exec = "vintagestory";
      icon = "vintagestory";
      name = "vintagestory";
    })

    (makeDesktopItem {
      comment = "Handler for vintagestorymodinstall:// URI scheme";
      desktopName = "Vintage Story 1-click Mod Install Handler";
      exec = "vintagestory -i %u";
      mimeTypes = [ "x-scheme-handler/vintagestorymodinstall" ];
      name = "vsmodinstall-handler";
      noDisplay = true;
      terminal = false;
    })
  ];

  installCheckInputs = [ versionCheckHook ];

  makeWrapperArgs = [
    "--set-default"
    "mesa_glthread"
    "true"
  ]
  ++ lib.optionals waylandSupport [
    "--set-default"
    "OPENTK_4_USE_WAYLAND"
    "1"
  ];

  runtimeLibraryPath = lib.makeLibraryPath finalAttrs.passthru.runtimeLibs;

  passthru = {
    runtimeLibs = [
      cairo
      libGLU
      libglvnd
      pipewire
      libpulseaudio
    ]
    ++ lib.optionals x11Support [
      libx11
      libxi
      libxcursor
    ]
    ++ lib.optionals waylandSupport [
      wayland
      libxkbcommon
    ];

    updateScript = ./update.sh;
  };

  meta = {
    description = "In-development indie sandbox game about innovation and exploration";
    homepage = "https://www.vintagestory.at/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      artturin
      gigglesquid
      dtomvan
      bubylou
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "vintagestory";
  };
})
