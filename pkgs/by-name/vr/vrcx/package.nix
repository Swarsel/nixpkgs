{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  buildNpmPackage,
  copyDesktopItems,
  dotnetCorePackages,
  electron_41,
  makeDesktopItem,
  makeWrapper,
  nodejs_24,
}:
let
  node = nodejs_24;
  electron = electron_41;
  dotnet = dotnetCorePackages.dotnet_9;
in
buildNpmPackage (finalAttrs: {
  pname = "vrcx";
  version = "2026.05.03";

  src = fetchFromGitHub {
    owner = "vrcx-team";
    repo = "VRCX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TIRX1DllUaq73Aue5/2mg98luBnDoptiiMDQcZ9aBTM=";
  };

  postPatch = ''
    # V2026.05.03 seems to have an out of date lockfile
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  npmDepsHash = "sha256-hOfbDvBJgoPQ6QxnZ77kpeSHDXH9dSnidmrx9Mp9q08=";

  buildPhase = ''
    runHook preBuild

    env PLATFORM=linux npm exec vite build src
    node ./src-electron/patch-package-version.js
    npm exec electron-builder -- --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}
    node ./src-electron/patch-node-api-dotnet.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/vrcx"
    cp -r build/*-unpacked/resources "$out/share/vrcx/"
    mkdir -p "$out/share/vrcx/resources/app.asar.unpacked/build/Electron"
    cp -r ${finalAttrs.passthru.backend}/build/Electron/* "$out/share/vrcx/resources/app.asar.unpacked/build/Electron/"

    makeWrapper '${electron}/bin/electron' "$out/bin/vrcx"  \
      --add-flags "--ozone-platform-hint=auto --no-updater" \
      --add-flags "$out/share/vrcx/resources/app.asar"      \
      --set NODE_ENV production                             \
      --set DOTNET_ROOT ${dotnet.runtime}/share/dotnet      \
      --prefix PATH : ${lib.makeBinPath [ dotnet.runtime ]}

    install -Dm644 images/VRCX.png "$out/share/icons/hicolor/256x256/apps/vrcx.png"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Application"
      ];

      comment = "Friendship management tool for VRChat";
      desktopName = "VRCX";
      exec = "vrcx %u";
      icon = "vrcx";
      mimeTypes = [ "x-scheme-handler/vrcx" ];
      name = "vrcx";
      terminal = false;
    })
  ];

  makeCacheWritable = true;
  nodejs = node;
  npmFlags = [ "--ignore-scripts" ];

  passthru = {
    backend = buildDotnetModule {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-backend";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/build/Electron
        cp -r build/Electron/* $out/build/Electron/

        runHook postInstall
      '';

      dotnet-runtime = dotnet.runtime;
      dotnet-sdk = dotnet.sdk;
      nugetDeps = ./deps.json;
      projectFile = "Dotnet/VRCX-Electron.csproj";
    };
  };

  meta = {
    description = "Friendship management tool for VRChat";

    longDescription = ''
      VRCX is an assistant/companion application for VRChat that provides information about and helps you accomplish various things
      related to VRChat in a more convenient fashion than relying on the plain VRChat client (desktop or VR), or website alone.
    '';

    homepage = "https://github.com/vrcx-team/VRCX";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ShyAssassin
      ImSapphire
    ];

    platforms = lib.platforms.linux;
    broken = !stdenv.hostPlatform.isx86_64;
    downloadPage = "https://github.com/vrcx-team/VRCX/releases";
  };
})
