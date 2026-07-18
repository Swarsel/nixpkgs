{
  lib,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  gobject-introspection,
  lttng-ust,
  makeWrapper,
  mtdev,
  nix-update-script,
  openssl,
  pkgs,
  stdenvNoCC,
  xclip,
  xsel,
  zenity,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "archipelago";
  version = "0.6.7";

  src = fetchurl {
    url = "https://github.com/ArchipelagoMW/Archipelago/releases/download/${finalAttrs.version}/Archipelago_${finalAttrs.version}_linux-x86_64.AppImage";
    hash = "sha256-a5UazzqGu7q4Zg1AYHnbQjCTQNdcNaL/gZUjYV3Rk5Q=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = finalAttrs.runtimeDependencies;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${finalAttrs.appimageContents}/AppRun $out/bin/archipelago

    mkdir -p $out/lib/opt
    cp -r ${finalAttrs.appimageContents}/opt/* $out/lib/opt

    wrapProgram $out/bin/archipelago \
      --set APPDIR $out/lib \
      --prefix LD_LIBRARY_PATH : "${finalAttrs.libraryPath}" \
      --prefix PATH : "${finalAttrs.binPath}"

    install -Dm444 ${finalAttrs.appimageContents}/archipelago.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/archipelago.desktop \
      --replace-fail 'opt/Archipelago/ArchipelagoLauncher' "archipelago"
    cp -r ${finalAttrs.appimageContents}/usr/share/icons $out/share

    runHook postInstall
  '';

  preFixup = ''
    patchelf \
      --replace-needed libcrypto.so.1.0.0 libcrypto.so \
      --replace-needed libssl.so.1.0.0 libssl.so \
      $out/lib/opt/Archipelago/EnemizerCLI/System.Security.Cryptography.Native.OpenSsl.so

    patchelf --replace-needed liblttng-ust.so.0 liblttng-ust.so \
      $out/lib/opt/Archipelago/EnemizerCLI/libcoreclrtraceptprovider.so
  '';

  appimageContents = appimageTools.extractType2 { inherit (finalAttrs) pname version src; };

  binPath = lib.makeBinPath [
    xsel
    xclip
    zenity
  ];

  dontUnpack = true;

  libraryPath = lib.makeLibraryPath [
    mtdev
  ];

  runtimeDependencies = [
    gobject-introspection
    lttng-ust
    openssl
  ]
  ++ appimageTools.defaultFhsEnvArgs.targetPkgs pkgs
  ++ appimageTools.defaultFhsEnvArgs.multiPkgs pkgs;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-Game Randomizer and Server";
    homepage = "https://archipelago.gg";
    changelog = "https://github.com/ArchipelagoMW/Archipelago/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pyrox0
      iqubic
    ];

    platforms = lib.platforms.linux;
    mainProgram = "archipelago";
  };
})
