{
  lib,
  fetchurl,
  buildGraalvmNativeImage,
  fetchMavenArtifact,
  versionCheckHook,
}:

buildGraalvmNativeImage (finalAttrs: {
  pname = "cljstyle";
  version = "0.17.642";

  src = fetchurl {
    url = "https://github.com/greglook/cljstyle/releases/download/${finalAttrs.version}/cljstyle-${finalAttrs.version}.jar";
    hash = "sha256-AkCuTZeDXbNBuwPZEMhYGF/oOGIKq5zVDwL8xwnj+mE=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  extraNativeImageBuildArgs = [
    "-H:+ReportExceptionStackTraces"
    "--no-fallback"
    "-cp ${finalAttrs.finalPackage.passthru.graal-build-time.passthru.jar}"
  ];

  versionCheckProgramArg = [ "version" ];

  # must be on classpath to build native image
  passthru.graal-build-time = fetchMavenArtifact {
    version = "1.0.5";
    artifactId = "graal-build-time";
    groupId = "com.github.clj-easy";
    hash = "sha256-M6/U27a5n/QGuUzGmo8KphVnNa2K+LFajP5coZiFXoY=";
    repos = [ "https://repo.clojars.org/" ];
  };

  meta = {
    description = "Tool for formatting Clojure code";
    homepage = "https://github.com/greglook/cljstyle";
    changelog = "https://github.com/greglook/cljstyle/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ psyclyx ];
    mainProgram = "cljstyle";
  };
})
