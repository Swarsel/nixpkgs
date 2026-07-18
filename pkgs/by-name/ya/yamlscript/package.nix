{
  lib,
  fetchurl,
  buildGraalvmNativeImage,
}:

buildGraalvmNativeImage (finalAttrs: {
  pname = "yamlscript";
  version = "0.2.27";

  src = fetchurl {
    url = "https://github.com/yaml/yamlscript/releases/download/${finalAttrs.version}/yamlscript.cli-${finalAttrs.version}-standalone.jar";
    hash = "sha256-d2kG10M+AeADVRzzjShx5CMTpsVgScF5NDimQm/B0DM=";
  };

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/ys -e 'say: (+ 1 2)' | fgrep 3

    runHook postInstallCheck
  '';

  extraNativeImageBuildArgs = [
    "--native-image-info"
    "--no-fallback"
    "--initialize-at-build-time"
    "--enable-preview"
    "-H:+ReportExceptionStackTraces"
    "-H:IncludeResources=SCI_VERSION"
    "-H:Log=registerResource:"
    "-J-Dclojure.spec.skip-macros=true"
    "-J-Dclojure.compiler.direct-linking=true"
  ];

  meta = {
    description = "Programming in YAML";
    homepage = "https://github.com/yaml/yamlscript";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ sgo ];
    mainProgram = "ys";
  };
})
