{
  lib,
  stdenv,
  fetchurl,
  aapt,
  jre_minimal,
  makeWrapper,
}:

let
  jre = jre_minimal.override {
    modules = [
      "java.base"
      "java.desktop"
      "java.logging"
      "java.xml"
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "apktool";
  version = "3.0.2";

  src = fetchurl {
    hash = "sha256-7uRmmnBKFOBiNAfmcBsLkYh+YeHkBJy3qCgz4Urotf0=";

    urls = [
      "https://github.com/iBotPeaches/Apktool/releases/download/v${finalAttrs.version}/apktool_${finalAttrs.version}.jar"
    ];
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D ${finalAttrs.src} "$out/libexec/apktool/apktool.jar"
    mkdir -p "$out/bin"

    # Keep the default JVM flags from Apktool's upstream launcher script:
    # https://github.com/iBotPeaches/Apktool/blob/b4a8719101b250b6ad26a7829482c06767a7bbc4/scripts/linux/apktool#L57-L61
    makeWrapper "${jre}/bin/java" "$out/bin/apktool" \
      --add-flags "-Xmx1024M" \
      --add-flags "-Dfile.encoding=utf-8" \
      --add-flags "-Djdk.util.zip.disableZip64ExtraFieldValidation=true" \
      --add-flags "-Djdk.nio.zipfs.allowDotZipEntry=true" \
      --add-flags "-jar $out/libexec/apktool/apktool.jar" \
      --prefix PATH : ${lib.getBin aapt}
  '';

  dontUnpack = true;
  sourceRoot = ".";

  meta = {
    description = "Tool for reverse engineering Android apk files";
    homepage = "https://apktool.org";
    changelog = "https://github.com/iBotPeaches/Apktool/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ qrzbing ];
    platforms = with lib.platforms; unix;
    mainProgram = "apktool";
  };
})
