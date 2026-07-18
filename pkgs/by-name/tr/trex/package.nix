{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "trex";
  version = "2.0.0";

  src = fetchurl {
    url = "https://github.com/amebalabs/TRex/releases/download/v${finalAttrs.version}/TRex-${finalAttrs.version}.zip";
    hash = "sha256-To3vxoDapuCcstq6V2qiQ2g8d1uTqVEM5fElRNIi3k0=";
  };

  strictDeps = true;
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Copy any text on your screen using OCR";
    homepage = "https://github.com/amebalabs/TRex";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ Br1ght0ne ];
    platforms = lib.platforms.darwin;
  };
})
