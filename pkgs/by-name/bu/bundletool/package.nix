{
  lib,
  fetchurl,
  jre_headless,
  makeBinaryWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bundletool";
  version = "1.18.3";

  src = fetchurl {
    url = "https://github.com/google/bundletool/releases/download/${finalAttrs.version}/bundletool-all-${finalAttrs.version}.jar";
    sha256 = "sha256-oJnPoVQ/VVk7wu0Wpwp8Z/5UsXR7tzAfN/39bZECjik=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall
    makeWrapper ${jre_headless}/bin/java $out/bin/bundletool --add-flags "-jar $src"
    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Command-line tool to manipulate Android App Bundles";
    homepage = "https://developer.android.com/studio/command-line/bundletool";
    changelog = "https://github.com/google/bundletool/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = jre_headless.meta.platforms;
    mainProgram = "bundletool";
  };
})
