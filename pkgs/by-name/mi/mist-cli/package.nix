{
  lib,
  fetchurl,
  cpio,
  installShellFiles,
  nix-update-script,
  stdenvNoCC,
  xar,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mist-cli";
  version = "2.3";

  src = fetchurl {
    url = "https://github.com/ninxsoft/mist-cli/releases/download/v${finalAttrs.version}/mist-cli.${finalAttrs.version}.pkg";
    hash = "sha256-rUIA40JTXndE7W2wQiayhAP9RPTQMeJV8d6NUy/Immk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    xar
    cpio
  ];

  installPhase = ''
    runHook preInstall

    install -D usr/local/bin/mist "$out/bin/mist"

    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd mist \
      --bash <($out/bin/mist --generate-completion-script bash) \
      --fish <($out/bin/mist --generate-completion-script fish) \
      --zsh <($out/bin/mist --generate-completion-script zsh)
  '';

  __structuredAttrs = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    xar -xf "$src"
    gunzip -dc Payload | cpio -idmv

    runHook postUnpack
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool that downloads macOS firmwares and installers";
    homepage = "https://github.com/ninxsoft/mist-cli";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ojsef39 ];
    platforms = lib.platforms.darwin;
    mainProgram = "mist";
  };
})
