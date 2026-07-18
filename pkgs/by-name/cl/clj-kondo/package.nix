{
  lib,
  fetchurl,
  buildGraalvmNativeImage,
}:

buildGraalvmNativeImage (finalAttrs: {
  pname = "clj-kondo";
  version = "2026.05.25";

  src = fetchurl {
    url = "https://github.com/clj-kondo/clj-kondo/releases/download/v${finalAttrs.version}/clj-kondo-${finalAttrs.version}-standalone.jar";
    sha256 = "sha256-SzrfsIHUW+KzZITesZ9aS00Gx7S4hekLsXXdjQJJxLM=";
  };

  extraNativeImageBuildArgs = [
    "-H:+ReportExceptionStackTraces"
    "--no-fallback"
  ];

  meta = {
    description = "Linter for Clojure code that sparks joy";
    homepage = "https://github.com/clj-kondo/clj-kondo";
    changelog = "https://github.com/clj-kondo/clj-kondo/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      jlesquembre
      bandresen
    ];

    mainProgram = "clj-kondo";
  };
})
