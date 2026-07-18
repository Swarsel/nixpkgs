{
  lib,
  fetchurl,
  gitUpdater,
  jre,
  makeWrapper,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wiremock";
  version = "3.13.2";

  src = fetchurl {
    url = "mirror://maven/org/wiremock/wiremock-standalone/${finalAttrs.version}/wiremock-standalone-${finalAttrs.version}.jar";
    hash = "sha256-0Jexm9SDxQOEebE6XHHp+vjy9RBlhPDBIKd3CrC9s2c=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out"/{share/wiremock,bin}
    cp ${finalAttrs.src} "$out/share/wiremock/wiremock.jar"

    makeWrapper ${jre}/bin/java $out/bin/${finalAttrs.meta.mainProgram} \
      --add-flags "-jar $out/share/wiremock/wiremock.jar"
  '';

  dontUnpack = true;

  passthru = {
    tests.version = testers.testVersion {
      command = "${lib.getExe finalAttrs.finalPackage} --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = gitUpdater {
      ignoredVersions = "(alpha|beta|rc).*";
      url = "https://github.com/wiremock/wiremock.git";
    };
  };

  meta = {
    description = "Flexible tool for building mock APIs";
    homepage = "https://wiremock.org/";
    changelog = "https://github.com/wiremock/wiremock/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      bobvanderlinden
      anthonyroussel
    ];

    platforms = jre.meta.platforms;
    mainProgram = "wiremock";
  };
})
