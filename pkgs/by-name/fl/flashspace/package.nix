{
  lib,
  stdenv,
  fetchzip,
  nix-update-script,
}:

let
  version = "3.3.39";
in
stdenv.mkDerivation {
  inherit version;
  pname = "flashspace";

  src = fetchzip {
    url = "https://github.com/wojciech-kulik/FlashSpace/releases/download/v${version}/FlashSpace.app.zip";
    hash = "sha256-/mgdeRxaxq+oIjbbaxCSExHxyYqqWl80+6jPzPIhT4M=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications/FlashSpace.app $out/bin
    mv Contents $out/Applications/FlashSpace.app
    ln -s ../Applications/Flashspace.app/Contents/Resources/flashspace $out/bin/flashspace
    runHook postInstall
  '';

  doInstallCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Blazingly fast virtual workspace manager for macOS";
    homepage = "https://github.com/wojciech-kulik/FlashSpace";
    changelog = "https://github.com/wojciech-kulik/FlashSpace/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.marcusramberg ];
    platforms = lib.platforms.darwin;
  };
}
