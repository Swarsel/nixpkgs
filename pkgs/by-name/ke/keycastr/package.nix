{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "keycastr";
  version = "0.10.5";

  src = fetchurl {
    url = "https://github.com/keycastr/keycastr/releases/download/v${finalAttrs.version}/KeyCastr.app.zip";
    hash = "sha256-yXxj6tv0MEwEgCwMg3XJm1gIRYS+MU6WTINm7KMYt1I=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r KeyCastr.app $out/Applications/
    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open-source keystroke visualizer";
    homepage = "https://github.com/keycastr/keycastr";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ matteopacini ];
    platforms = lib.platforms.darwin;
  };
})
