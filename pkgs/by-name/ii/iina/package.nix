{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "iina";
  version = "1.4.4";

  src = fetchurl {
    url = "https://github.com/iina/iina/releases/download/v${finalAttrs.version}/IINA.v${finalAttrs.version}.dmg";
    hash = "sha256-3Q/AvUs3+1ehyNMNbjIBs6ZLr9KZWf5WlTlkYTI3vrE=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/{bin,Applications/IINA.app}
    cp -R . "$out/Applications/IINA.app"
    ln -s "$out/Applications/IINA.app/Contents/MacOS/iina-cli" "$out/bin/iina"
  '';

  sourceRoot = "IINA.app";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern media player for macOS";
    homepage = "https://iina.io/";
    changelog = "https://github.com/iina/iina/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      arkivm
      _4evy
      kinnrai
      stepbrobd
    ];

    platforms = lib.platforms.darwin;
    mainProgram = "iina";
  };
})
