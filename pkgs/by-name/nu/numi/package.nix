{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
  undmg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "numi";
  version = "3.32.721";

  src = fetchurl {
    url = "https://s3.numi.app/updates/${finalAttrs.version}/Numi.dmg";
    hash = "sha256-IbX4nsrPqwOSlYdNJLeaRQwIDVJrzfMXFqRqixHd2zA=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R *.app "$out/Applications"

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Beautiful calculator app for macOS";
    homepage = "https://numi.app/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ _4evy ];
    platforms = lib.platforms.darwin;
  };
})
